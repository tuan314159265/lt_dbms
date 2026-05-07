// ========================================
// mongodbTransactionService.js
// Backend service cho MongoDB transactions
// Dùng với Node.js + mongodb driver
// ========================================

const { MongoClient, ObjectId } = require("mongodb");

const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/?replicaSet=rs0";
const DB_NAME = "cinema_db";

let client = null;
let db = null;

// ========================================
// 1. CONNECTION
// ========================================
async function connectMongoDB() {
  try {
    client = new MongoClient(MONGO_URI, {
      // Thêm replicaSet vào URI hoặc options để driver biết dùng transactions
      serverSelectionTimeoutMS: 5000,
    });
    await client.connect();
    db = client.db(DB_NAME);
    console.log("✅ Connected to MongoDB");
    return db;
  } catch (error) {
    console.error("❌ MongoDB connection failed:", error);
    throw error;
  }
}

// ========================================
// 2. BOOK TICKET TRANSACTION
// ========================================
async function bookTicketWithTransaction(userId, screeningId, seats) {
  const session = client.startSession();
  const transactionLog = [];

  try {
    let bookingResult = null;

    await session.withTransaction(async () => {
      // Reset log mỗi lần retry (withTransaction có thể retry)
      transactionLog.length = 0;

      // Step 1: Lấy thông tin screening trước để biết movieId và price
      // FIX: Query screening → movie đúng thứ tự (không nhầm movieId với screeningId)
      const screening = await db.collection("screenings").findOne(
        { _id: new ObjectId(screeningId) },
        { session }
      );

      if (!screening) {
        throw new Error("Screening not found: " + screeningId);
      }

      // FIX BUG CHÍNH: Query movie qua screening.movieId, KHÔNG phải screeningId
      const movie = await db.collection("movies").findOne(
        { _id: screening.movieId },
        { session }
      );

      if (!movie) {
        throw new Error("Movie not found for screening: " + screeningId);
      }

      const totalAmount = seats.length * movie.price;

      // Step 2: Validate và deduct wallet
      const user = await db.collection("users").findOne(
        { _id: new ObjectId(userId) },
        { session }
      );

      if (!user) {
        throw new Error("User not found: " + userId);
      }

      if (user.wallet < totalAmount) {
        throw new Error(
          `Insufficient wallet: ${user.wallet}đ < ${totalAmount}đ (${seats.length} vé × ${movie.price}đ)`
        );
      }

      await db.collection("users").updateOne(
        { _id: new ObjectId(userId) },
        { $inc: { wallet: -totalAmount }, $set: { updatedAt: new Date() } },
        { session }
      );

      transactionLog.push({ step: 1, action: "wallet_deducted", amount: totalAmount });

      // Step 3: Check và update seats
      const bookedSeats = screening.bookedSeats || [];
      const conflict = seats.filter(seat => bookedSeats.includes(seat));

      if (conflict.length > 0) {
        throw new Error(`Seats already booked: ${conflict.join(", ")}`);
      }

      await db.collection("screenings").updateOne(
        { _id: new ObjectId(screeningId) },
        { $push: { bookedSeats: { $each: seats } } },
        { session }
      );

      transactionLog.push({ step: 2, action: "seats_updated", seats });

      // Step 4: Tạo booking record
      const booking = {
        _id:           new ObjectId(),
        userId:        new ObjectId(userId),
        screeningId:   new ObjectId(screeningId),
        movieTitle:    movie.title,
        seats:         seats,
        totalAmount:   totalAmount,
        status:        "confirmed",
        paymentMethod: "wallet",
        bookingDate:   new Date(),
        screeningDate: screening.screenTime,
        createdAt:     new Date()
      };

      const result = await db.collection("bookings").insertOne(booking, { session });
      transactionLog.push({ step: 3, action: "booking_created", bookingId: result.insertedId });

      // Step 5: Log transaction
      await db.collection("transaction_logs").insertOne(
        {
          _id:       new ObjectId(),
          bookingId: result.insertedId,
          userId:    new ObjectId(userId),
          status:    "committed",
          amount:    totalAmount,
          details:   `Booked seats ${seats.join(", ")} for ${movie.title}`,
          timestamp: new Date()
        },
        { session }
      );

      bookingResult = { bookingId: result.insertedId };
    });

    console.log("✅ Transaction committed successfully");
    return {
      status: "success",
      message: "Ticket booked successfully",
      bookingId: bookingResult.bookingId,
      transactionLog
    };

  } catch (error) {
    console.error("❌ Transaction failed:", error.message);
    transactionLog.push({ action: "rollback", error: error.message, timestamp: new Date() });
    return {
      status: "failed",
      message: error.message,
      transactionLog
    };
  } finally {
    await session.endSession();
  }
}

// ========================================
// 3. REFUND TRANSACTION
// ========================================
async function refundTicketWithTransaction(bookingId) {
  const session = client.startSession();
  const transactionLog = [];

  try {
    await session.withTransaction(async () => {
      transactionLog.length = 0;

      const booking = await db.collection("bookings").findOne(
        { _id: new ObjectId(bookingId) },
        { session }
      );

      if (!booking) throw new Error("Booking not found: " + bookingId);
      if (booking.status === "cancelled") throw new Error("Booking already cancelled");

      // Hoàn tiền
      await db.collection("users").updateOne(
        { _id: booking.userId },
        { $inc: { wallet: booking.totalAmount }, $set: { updatedAt: new Date() } },
        { session }
      );
      transactionLog.push({ step: 1, action: "wallet_returned", amount: booking.totalAmount });

      // Giải phóng ghế
      await db.collection("screenings").updateOne(
        { _id: booking.screeningId },
        { $pull: { bookedSeats: { $in: booking.seats } } },
        { session }
      );
      transactionLog.push({ step: 2, action: "seats_released", seats: booking.seats });

      // Cập nhật status booking
      await db.collection("bookings").updateOne(
        { _id: new ObjectId(bookingId) },
        { $set: { status: "cancelled", updatedAt: new Date() } },
        { session }
      );
      transactionLog.push({ step: 3, action: "booking_cancelled" });

      // Log
      await db.collection("transaction_logs").insertOne(
        {
          _id:       new ObjectId(),
          bookingId: new ObjectId(bookingId),
          userId:    booking.userId,
          status:    "committed",
          amount:    booking.totalAmount,
          details:   `Refunded booking ${bookingId}`,
          timestamp: new Date()
        },
        { session }
      );
    });

    return { status: "success", message: "Refund processed successfully", transactionLog };
  } catch (error) {
    console.error("❌ Refund failed:", error.message);
    transactionLog.push({ action: "rollback", error: error.message, timestamp: new Date() });
    return { status: "failed", message: error.message, transactionLog };
  } finally {
    await session.endSession();
  }
}

// ========================================
// 4. QUERY HELPERS
// ========================================
async function getUserBookings(userId) {
  return db.collection("bookings")
    .find({ userId: new ObjectId(userId) })
    .toArray();
}

async function getBookingDetails(bookingId) {
  return db.collection("bookings").findOne({ _id: new ObjectId(bookingId) });
}

async function getTransactionHistory(bookingId) {
  return db.collection("transaction_logs")
    .find({ bookingId: new ObjectId(bookingId) })
    .sort({ timestamp: 1 })
    .toArray();
}

async function getScreeningSeats(screeningId) {
  const s = await db.collection("screenings").findOne({ _id: new ObjectId(screeningId) });
  return s ? s.bookedSeats : [];
}

module.exports = {
  connectMongoDB,
  bookTicketWithTransaction,
  refundTicketWithTransaction,
  getUserBookings,
  getBookingDetails,
  getTransactionHistory,
  getScreeningSeats
};

/*
// ========================================
// EXAMPLE API ROUTES (Express)
// ========================================
const express = require('express');
const app = express();
app.use(express.json());

const {
  connectMongoDB,
  bookTicketWithTransaction,
  refundTicketWithTransaction
} = require('./mongodbTransactionService');

connectMongoDB();

app.post("/api/mongo/book-ticket", async (req, res) => {
  const { userId, screeningId, seats } = req.body;
  const result = await bookTicketWithTransaction(userId, screeningId, seats);
  res.status(result.status === "success" ? 201 : 400).json(result);
});

app.post("/api/mongo/refund", async (req, res) => {
  const { bookingId } = req.body;
  const result = await refundTicketWithTransaction(bookingId);
  res.status(result.status === "success" ? 200 : 400).json(result);
});
*/
