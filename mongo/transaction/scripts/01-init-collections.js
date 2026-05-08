// =======================================================================================
// PHẦN 1: KHỞI TẠO DATABASE VÀ DỌN DẸP
// =======================================================================================

db = db.getSiblingDB("cinema_db");

const collectionNames = ["users", "movies", "screenings", "bookings", "transaction_logs"];

print("Đang khởi tạo database 'cinema_db'...");
collectionNames.forEach(collectionName => db.getCollection(collectionName).drop());
print("Đã dọn dẹp các collection cũ.");

function createValidatedCollection(collectionName, schema) {
  db.createCollection(collectionName, {
    validator: { $jsonSchema: schema },
    validationAction: "warn"
  });
}

// =======================================================================================
// PHẦN 2: TẠO COLLECTIONS VỚI SCHEMA VALIDATION
// =======================================================================================

print("Đang tạo collections...");

createValidatedCollection("users", {
  bsonType: "object",
  required: ["email", "wallet"],
  additionalProperties: true,
  properties: {
    _id: { bsonType: "objectId" },
    email: { bsonType: "string" },
    name: { bsonType: "string" },
    phone: { bsonType: "string" },
    wallet: { bsonType: ["double", "int"] },
    role: { bsonType: "string" },
    createdAt: { bsonType: "date" },
    updatedAt: { bsonType: "date" }
  }
});

createValidatedCollection("movies", {
  bsonType: "object",
  required: ["title", "price"],
  additionalProperties: true,
  properties: {
    _id: { bsonType: "objectId" },
    title: { bsonType: "string" },
    description: { bsonType: "string" },
    duration: { bsonType: ["int", "double"] },
    genre: { bsonType: "string" },
    price: { bsonType: ["double", "int"] },
    createdAt: { bsonType: "date" }
  }
});

createValidatedCollection("screenings", {
  bsonType: "object",
  required: ["movieId", "screenTime"],
  additionalProperties: true,
  properties: {
    _id: { bsonType: "objectId" },
    movieId: { bsonType: "objectId" },
    screeningRoom: { bsonType: "string" },
    screenTime: { bsonType: "date" },
    totalSeats: { bsonType: ["int", "double"] },
    bookedSeats: { bsonType: "array", items: { bsonType: "string" } },
    createdAt: { bsonType: "date" }
  }
});

createValidatedCollection("bookings", {
  bsonType: "object",
  required: ["userId", "screeningId", "seats", "totalAmount", "status"],
  additionalProperties: true,
  properties: {
    _id: { bsonType: "objectId" },
    userId: { bsonType: "objectId" },
    screeningId: { bsonType: "objectId" },
    movieTitle: { bsonType: "string" },
    seats: { bsonType: "array", items: { bsonType: "string" } },
    totalAmount: { bsonType: ["double", "int"] },
    status: { bsonType: "string" },
    paymentMethod: { bsonType: "string" },
    bookingDate: { bsonType: "date" },
    screeningDate: { bsonType: "date" },
    createdAt: { bsonType: "date" }
  }
});

createValidatedCollection("transaction_logs", {
  bsonType: "object",
  required: ["bookingId", "status", "timestamp"],
  additionalProperties: true,
  properties: {
    _id: { bsonType: "objectId" },
    bookingId: { bsonType: "objectId" },
    userId: { bsonType: "objectId" },
    status: { bsonType: "string" },
    amount: { bsonType: ["double", "int"] },
    details: { bsonType: "string" },
    timestamp: { bsonType: "date" }
  }
});

// =======================================================================================
// PHẦN 3: TẠO INDEXES (TỐI ƯU HIỆU NĂNG TRUY VẤN)
// =======================================================================================

print("Đang tạo indexes...");
db.users.createIndex({ email: 1 }, { unique: true });
db.bookings.createIndex({ userId: 1 });
db.bookings.createIndex({ screeningId: 1 });
db.bookings.createIndex({ status: 1 });
db.screenings.createIndex({ movieId: 1 });
db.transaction_logs.createIndex({ bookingId: 1 });
db.transaction_logs.createIndex({ userId: 1 });

print("Collections and indexes created successfully!");
