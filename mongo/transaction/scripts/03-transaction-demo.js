// =======================================================================================
// PHẦN 1: KHỞI TẠO DATABASE VÀ HÀM HỖ TRỢ
// =======================================================================================

db = db.getSiblingDB("cinema_db");

const LINE = "=".repeat(78);

function printSection(title) {
  print("\n" + LINE);
  print(title);
  print(LINE);
}

function printSeparator() {
  print(LINE);
}

function printTable(title, headers, rows) {
  if (rows.length === 0) {
    return;
  }

  print("\n" + title);
  print("-".repeat(100));
  print("| " + headers.map(header => header.padEnd(20)).join(" | "));
  print("-".repeat(100));

  rows.forEach(row => {
    print("| " + row.map(cell => String(cell).padEnd(20)).join(" | "));
  });

  print("-".repeat(100));
}

function printSnapshotTable(label) {
  const userRows = [];
  db.users.find({}, { name: 1, wallet: 1 }).forEach(user => {
    userRows.push([user.name, user.wallet.toLocaleString() + "d"]);
  });

  const screeningRows = [];
  db.screenings.find({}, { screeningRoom: 1, bookedSeats: 1 }).forEach(screening => {
    screeningRows.push([
      screening.screeningRoom,
      (screening.bookedSeats || []).join(", ") || "(none)"
    ]);
  });

  const bookingRows = [];
  db.bookings.find({}, { movieTitle: 1, status: 1, totalAmount: 1 }).forEach(booking => {
    bookingRows.push([
      booking.movieTitle,
      booking.status,
      booking.totalAmount.toLocaleString() + "đ"
    ]);
  });

  printSection(label);
  printTable("USERS", ["Name", "Wallet"], userRows);
  printTable("SCREENINGS", ["Room", "Booked Seats"], screeningRows);
  printTable("BOOKINGS", ["Movie", "Status", "Amount"], bookingRows);
}

function snapshotState() {
  const users = {};
  const screenings = {};

  db.users.find({}, { wallet: 1 }).forEach(user => {
    users[user._id.toString()] = user.wallet;
  });

  db.screenings.find({}, { bookedSeats: 1 }).forEach(screening => {
    screenings[screening._id.toString()] = screening.bookedSeats || [];
  });

  return {
    users,
    screenings,
    bookingCount: db.bookings.countDocuments()
  };
}

let previousState = snapshotState();

function printState(label) {
  printSection(label);
  previousState = snapshotState();
  print("   (Initial state recorded)");
}

function printChangedState(label) {
  printSection(label);

  const userRows = [];
  db.users.find({}, { name: 1, wallet: 1 }).forEach(user => {
    const previousWallet = previousState.users[user._id.toString()] || 0;
    if (previousWallet !== user.wallet) {
      userRows.push([
        user.name,
        previousWallet.toLocaleString() + "d",
        "->",
        user.wallet.toLocaleString() + "d"
      ]);
    }
  });

  if (userRows.length > 0) {
    printTable("USERS (CHANGED)", ["Name", "Before", "", "After"], userRows);
  }

  const screenRows = [];
  db.screenings.find({}, { screeningRoom: 1, bookedSeats: 1 }).forEach(screening => {
    const previousSeats = previousState.screenings[screening._id.toString()] || [];
    const currentSeats = screening.bookedSeats || [];

    if (JSON.stringify(previousSeats) !== JSON.stringify(currentSeats)) {
      screenRows.push([
        screening.screeningRoom,
        previousSeats.join(", ") || "(none)",
        "->",
        currentSeats.join(", ") || "(none)"
      ]);
    }
  });

  if (screenRows.length > 0) {
    printTable("SCREENINGS (CHANGED)", ["Room", "Before", "", "After"], screenRows);
  }

  const currentBookingCount = db.bookings.countDocuments();
  if (currentBookingCount > previousState.bookingCount) {
    print(
      "\nBOOKINGS: " +
        previousState.bookingCount +
        " -> " +
        currentBookingCount +
        " (" +
        (currentBookingCount - previousState.bookingCount) +
        " new)"
    );
  }

  previousState = snapshotState();
}

function runTransactionScenario(title, runner) {
  printSection(title);

  const session = db.getMongo().startSession();
  const sessionDb = session.getDatabase("cinema_db");

  try {
    session.startTransaction({
      readConcern: { level: "snapshot" },
      writeConcern: { w: "majority" }
    });

    runner(sessionDb);
    session.commitTransaction();
    print("\nTRANSACTION COMMITTED!");
  } catch (error) {
    session.abortTransaction();
    print("\nTRANSACTION ROLLED BACK: " + error.message);
  } finally {
    session.endSession();
  }
}

// =======================================================================================
// PHẦN 2: GHI NHẬN TRẠNG THÁI BAN ĐẦU
// =======================================================================================

printState("STATE TRUOC KHI CHAY DEMO");

// =======================================================================================
// PHẦN 3: SCENARIO 1 - ĐẶT VÉ THÀNH CÔNG
// =======================================================================================

runTransactionScenario("SCENARIO 1: Dat ve thanh cong", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439011");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["C1", "C2"];
  const ticketPrice = 150000;
  const totalAmount = seats.length * ticketPrice;

  print("\n1. Deducting wallet...");
  const userBefore = sessionDb.users.findOne({ _id: userId });
  print("   Wallet truoc: " + userBefore.wallet + "d");

  if (userBefore.wallet < totalAmount) {
    throw new Error("Insufficient balance: " + userBefore.wallet + " < " + totalAmount);
  }

  sessionDb.users.updateOne(
    { _id: userId },
    { $inc: { wallet: -totalAmount }, $set: { updatedAt: new Date() } }
  );
  print("   Da tru " + totalAmount + "d");

  print("\n2. Reserving seats...");
  const screening = sessionDb.screenings.findOne({ _id: screeningId });
  const conflict = seats.filter(seat => (screening.bookedSeats || []).includes(seat));

  if (conflict.length > 0) {
    throw new Error("Seats already booked: " + conflict.join(", "));
  }

  sessionDb.screenings.updateOne(
    { _id: screeningId },
    { $push: { bookedSeats: { $each: seats } } }
  );
  print("   Ghe " + seats.join(", ") + " da duoc dat");

  print("\n3. Creating booking...");
  const movie = sessionDb.movies.findOne({ _id: screening.movieId });
  const bookingId = ObjectId();

  sessionDb.bookings.insertOne({
    _id: bookingId,
    userId: userId,
    screeningId: screeningId,
    movieTitle: movie.title,
    seats: seats,
    totalAmount: totalAmount,
    status: "confirmed",
    paymentMethod: "wallet",
    bookingDate: new Date(),
    screeningDate: screening.screenTime,
    createdAt: new Date()
  });
  print("   Booking ID: " + bookingId);

  sessionDb.transaction_logs.insertOne({
    _id: ObjectId(),
    bookingId: bookingId,
    userId: userId,
    status: "committed",
    amount: totalAmount,
    details: "Booked " + seats.join(", ") + " for " + movie.title,
    timestamp: new Date()
  });
});

printChangedState("STATE SAU SCENARIO 1");

// =======================================================================================
// PHẦN 4: SCENARIO 2 - THẤT BẠI DO KHÔNG ĐỦ TIỀN
// =======================================================================================

printSnapshotTable("STATE TRUOC SCENARIO 2: Dat ve that bai - Khong du tien");
runTransactionScenario("SCENARIO 2: Dat ve that bai - Khong du tien trong vi", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439012");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["D1", "D2", "D3", "D4", "D5"];
  const ticketPrice = 150000;
  const totalAmount = seats.length * ticketPrice;

  print("\n1. Checking wallet...");
  const user = sessionDb.users.findOne({ _id: userId });
  print("   Wallet: " + user.wallet + "d  |  Can: " + totalAmount + "d");

  if (user.wallet < totalAmount) {
    throw new Error("Insufficient balance: " + user.wallet + "d < " + totalAmount + "d");
  }

  sessionDb.users.updateOne({ _id: userId }, { $inc: { wallet: -totalAmount } });
  sessionDb.screenings.findOne({ _id: screeningId });
});

print("Vi user2 van nguyen ven, ghe khong bi dat");
print("So tien trong vi con lại: " + db.users.findOne({ _id: ObjectId("507f1f77bcf86cd799439012") }).wallet + "d");

printSnapshotTable("STATE SAU SCENARIO 2: Dat ve that bai - Khong du tien");
printChangedState("STATE SAU SCENARIO 2 (KHONG CO THAY DOI)");

// =======================================================================================
// PHẦN 5: SCENARIO 3 - THẤT BẠI DO GHẾ ĐÃ BỊ ĐẶT
// =======================================================================================

printState("STATE TRUOC SCENARIO 3: Dat ve that bai - Ghe da bi nguoi khac dat");
runTransactionScenario("SCENARIO 3: Dat ve that bai - Ghe da bi nguoi khac dat", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439011");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["A1", "E5"];
  const ticketPrice = 150000;
  const totalAmount = seats.length * ticketPrice;

  print("\n1. Deducting wallet first (to demo rollback reverses this)...");
  const user = sessionDb.users.findOne({ _id: userId });
  print("   Wallet truoc tru: " + user.wallet + "d");

  if (user.wallet < totalAmount) {
    throw new Error("Insufficient balance");
  }

  sessionDb.users.updateOne(
    { _id: userId },
    { $inc: { wallet: -totalAmount }, $set: { updatedAt: new Date() } }
  );
  print("   Da tru " + totalAmount + "d (trong transaction, chua commit)");

  print("\n2. Checking seat availability...");
  const screening = sessionDb.screenings.findOne({ _id: screeningId });
  print("   Ghe da dat: [" + screening.bookedSeats.join(", ") + "]");
  print("   Ghe muon dat: [" + seats.join(", ") + "]");

  const conflict = seats.filter(seat => (screening.bookedSeats || []).includes(seat));
  if (conflict.length > 0) {
    throw new Error("Seat(s) already reserved: " + conflict.join(", "));
  }
});

print("Tien vi duoc hoan lai, ghe khong thay doi");

printChangedState("STATE SAU SCENARIO 3 (ROLLBACK - KHONG CO THAY DOI)");

// ========================================
// FINAL SUMMARY
// ========================================
print("\n\nFINAL SUMMARY");
printSeparator();

// Bookings Table
const bookingRows = [];
db.bookings.find().forEach(b => {
  bookingRows.push([
    b.movieTitle,
    b.seats.join(", "),
    b.totalAmount.toLocaleString() + "đ",
    b.status.toUpperCase(),
    new Date(b.bookingDate).toLocaleString()
  ]);
});

if (bookingRows.length > 0) {
  printTable("BOOKINGS", 
    ["Movie", "Seats", "Amount", "Status", "Date"],
    bookingRows
  );
} else {
  print("\nBOOKINGS\n   (No bookings yet)");
  print("\nBOOKINGS\n   (No bookings yet)");
}

// Transaction Logs Table
const logRows = [];
db.transaction_logs.find().forEach(l => {
  logRows.push([
    l.status.toUpperCase(),
    l.details,
    l.amount.toLocaleString() + "đ",
    new Date(l.timestamp).toLocaleString()
  ]);
});

if (logRows.length > 0) {
  printTable("TRANSACTION LOGS",
    ["Status", "Details", "Amount", "Timestamp"],
    logRows
  );
} else {
  print("\nTRANSACTION LOGS\n   (No logs yet)");
  print("\nTRANSACTION LOGS\n   (No logs yet)");
}

print("\nDemo hoan tat! MongoDB Transactions hoat dong dung ACID.\n");
