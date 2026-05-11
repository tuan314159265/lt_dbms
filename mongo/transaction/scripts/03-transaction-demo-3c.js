// =======================================================================================
// SCENARIO 3C: THANH TOÁN ĐƠN CHỜ
// =======================================================================================
// Mô tả: User mở lại DON_HANG đang chờ thanh toán và thực hiện thanh toán. 
// Hệ thống kiểm tra đơn còn hợp lệ rồi cập nhật THANH_TOAN, VE_XEM_PHIM và DON_HANG 
// trong cùng transaction.
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
    bookingCount: db.bookings.countDocuments(),
    orderCount: db.don_hang.countDocuments(),
    ticketCount: db.ve_xem_phim.countDocuments()
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
// THỰC HIỆN SCENARIO
// =======================================================================================

// Trước tiên, tạo một đơn hàng chờ thanh toán
print("\n" + LINE);
print("SETUP: Tao don hang cho de test scenario 3C");
print(LINE);

const setupSession = db.getMongo().startSession();
const setupDb = setupSession.getDatabase("cinema_db");

try {
  setupSession.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" }
  });

  const userId = ObjectId("507f1f77bcf86cd799439012");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["E1", "E2"];
  const ticketPrice = 150000;
  const totalAmount = seats.length * ticketPrice;

  const screening = setupDb.screenings.findOne({ _id: screeningId });
  const movie = setupDb.movies.findOne({ _id: screening.movieId });

  // Dat ghe
  setupDb.screenings.updateOne(
    { _id: screeningId },
    { $push: { bookedSeats: { $each: seats } } }
  );

  // Tao don hang
  const orderId = ObjectId();
  setupDb.don_hang.insertOne({
    _id: orderId,
    userId: userId,
    screeningId: screeningId,
    totalAmount: totalAmount,
    status: "cho_thanh_toan",
    createdAt: new Date(),
    expireAt: new Date(Date.now() + 15 * 60 * 1000)
  });

  // Tao ve xem phim
  seats.forEach((seat) => {
    setupDb.ve_xem_phim.insertOne({
      _id: ObjectId(),
      orderId: orderId,
      userId: userId,
      screeningId: screeningId,
      ghe: seat,
      movieTitle: movie.title,
      status: "cho_thanh_toan",
      createdAt: new Date()
    });
  });

  setupSession.commitTransaction();
  print("✓ Setup hoan tat! Tao don hang CHO_THANH_TOAN\n");
} finally {
  setupSession.endSession();
}

// =======================================================================================
// SCENARIO 3C: THANH TOAN DON CHO
// =======================================================================================

printState("STATE TRUOC KHI CHAY SCENARIO 3C");

runTransactionScenario("SCENARIO 3C: Thanh toan don cho", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439012");
  const pendingOrder = sessionDb.don_hang.findOne({ userId: userId, status: "cho_thanh_toan" });
  const orderId = pendingOrder._id;

  print("\n1. Tim don hang cho thanh toan...");
  const order = sessionDb.don_hang.findOne({ _id: orderId });
  print("   Don ID: " + orderId.toString().substring(0, 8) + "  |  Tong tien: " + order.totalAmount + "d");

  if (order.status !== "cho_thanh_toan") {
    throw new Error("Order is not in CHO_THANH_TOAN status");
  }

  // Kiem tra don khong het han
  if (new Date() > order.expireAt) {
    throw new Error("Order expired");
  }

  print("\n2. Kiem tra vi co du tien khong...");
  const user = sessionDb.users.findOne({ _id: userId });
  print("   Wallet: " + user.wallet + "d  |  Can: " + order.totalAmount + "d");

  if (user.wallet < order.totalAmount) {
    throw new Error("Insufficient balance: " + user.wallet + "d < " + order.totalAmount + "d");
  }

  print("\n3. Tru tien vi...");
  sessionDb.users.updateOne(
    { _id: userId },
    { $inc: { wallet: -order.totalAmount }, $set: { updatedAt: new Date() } }
  );
  print("   Da tru " + order.totalAmount + "d");

  print("\n4. Cap nhat ve_xem_phim sang DA_THANH_TOAN...");
  sessionDb.ve_xem_phim.updateMany(
    { orderId: orderId },
    { $set: { status: "da_thanh_toan", paidAt: new Date() } }
  );
  const ticketCount = sessionDb.ve_xem_phim.countDocuments({ orderId: orderId });
  print("   Cap nhat " + ticketCount + " ve");

  print("\n5. Cap nhat DON_HANG sang DA_THANH_TOAN...");
  sessionDb.don_hang.updateOne(
    { _id: orderId },
    { $set: { status: "da_thanh_toan", paidAt: new Date() } }
  );
  print("   Don hang da thanh toan");

  print("\n6. Tao THANH_TOAN...");
  sessionDb.thanh_toan.insertOne({
    _id: ObjectId(),
    orderId: orderId,
    userId: userId,
    amount: order.totalAmount,
    paymentMethod: "wallet",
    status: "thanh_cong",
    createdAt: new Date(),
    paidAt: new Date()
  });
  print("   Thanh toan " + order.totalAmount + "d bang wallet");
});

printChangedState("STATE SAU SCENARIO 3C");

// ========================================
// FINAL SUMMARY
// ========================================
print("\n\nFINAL SUMMARY - SCENARIO 3C");
printSeparator();

// Orders
const orderRows = [];
db.don_hang.find().forEach(o => {
  orderRows.push([
    o._id.toString().substring(0, 8),
    o.status.toUpperCase(),
    o.totalAmount.toLocaleString() + "d",
    o.paidAt ? new Date(o.paidAt).toLocaleString() : "N/A"
  ]);
});

if (orderRows.length > 0) {
  printTable("DON_HANG", ["Order ID", "Status", "Amount", "Paid At"], orderRows);
}

// Tickets
const ticketRows = [];
db.ve_xem_phim.find().forEach(t => {
  ticketRows.push([
    t.ghe,
    t.status.toUpperCase(),
    t.movieTitle,
    t.paidAt ? new Date(t.paidAt).toLocaleString() : "N/A"
  ]);
});

if (ticketRows.length > 0) {
  printTable("VE_XEM_PHIM", ["Ghe", "Status", "Movie", "Paid At"], ticketRows);
}

// Payments
const paymentRows = [];
db.thanh_toan.find().forEach(p => {
  paymentRows.push([
    p._id.toString().substring(0, 8),
    p.status.toUpperCase(),
    p.amount.toLocaleString() + "d",
    new Date(p.paidAt).toLocaleString()
  ]);
});

if (paymentRows.length > 0) {
  printTable("THANH_TOAN", ["Payment ID", "Status", "Amount", "Paid At"], paymentRows);
}

print("\n✓ Scenario 3C HOAN TAT! Don hang da thanh toan thanh cong.\n");
