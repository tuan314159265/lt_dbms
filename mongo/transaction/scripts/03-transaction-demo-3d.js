// =======================================================================================
// SCENARIO 3D: HỦY ĐƠN CHỜ THANH TOÁN
// =======================================================================================
// Mô tả: User hủy DON_HANG chưa thanh toán. Transaction cập nhật trạng thái đơn, 
// giải phóng ghế và hoàn lại tồn kho combo nếu có rồi mới commit.
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
print("SETUP: Tao don hang cho de test scenario 3D");
print(LINE);

const setupSession = db.getMongo().startSession();
const setupDb = setupSession.getDatabase("cinema_db");

let pendingOrderId;
try {
  setupSession.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" }
  });

  const userId = ObjectId("507f1f77bcf86cd799439012");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["F1", "F2"];
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
  pendingOrderId = orderId;
  setupDb.don_hang.insertOne({
    _id: orderId,
    userId: userId,
    screeningId: screeningId,
    totalAmount: totalAmount,
    status: "cho_thanh_toan",
    createdAt: new Date(),
    expireAt: new Date(Date.now() + 15 * 60 * 1000),
    comboCount: 1
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

  // Reduce combo inventory
  setupDb.gom.updateOne(
    { type: "combo_pop" },
    { $inc: { soluong: -1 } },
    { upsert: true }
  );

  setupSession.commitTransaction();
  print("✓ Setup hoan tat! Tao don hang CHO_THANH_TOAN va tru inventory\n");
} finally {
  setupSession.endSession();
}

// =======================================================================================
// SCENARIO 3D: HUY DON CHO THANH TOAN
// =======================================================================================

printState("STATE TRUOC KHI CHAY SCENARIO 3D");

runTransactionScenario("SCENARIO 3D: Huy don cho thanh toan (giai phong ghe va hoan hang)", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439012");
  const orderId = pendingOrderId;

  print("\n1. Tim don hang de huy...");
  const order = sessionDb.don_hang.findOne({ _id: orderId });
  print("   Don ID: " + orderId.toString().substring(0, 8) + "  |  Tong tien: " + order.totalAmount + "d");

  if (order.status !== "cho_thanh_toan") {
    throw new Error("Order is not in CHO_THANH_TOAN status");
  }

  print("\n2. Tim toan bo ve xem phim cua don...");
  const bookingTickets = sessionDb.ve_xem_phim.find({ orderId: orderId }).toArray();
  const seatsToRelease = bookingTickets.map(v => v.ghe);
  print("   Tim thay " + bookingTickets.length + " ve: " + seatsToRelease.join(", "));

  print("\n3. Giai phong ghe...");
  const screeningId = order.screeningId;
  
  sessionDb.screenings.updateOne(
    { _id: screeningId },
    { $pullAll: { bookedSeats: seatsToRelease } }
  );
  print("   Ghe " + seatsToRelease.join(", ") + " da bi giai phong");

  print("\n4. Hoan lai inventory (combo)...");
  sessionDb.gom.updateOne(
    { type: "combo_pop" },
    { $inc: { soluong: order.comboCount || 1 } },
    { upsert: true }
  );
  print("   Hoan lai " + (order.comboCount || 1) + " combo pop");

  print("\n5. Cap nhat trang thai don sang DA_HUY...");
  sessionDb.don_hang.updateOne(
    { _id: orderId },
    { $set: { status: "da_huy", cancelledAt: new Date() } }
  );
  print("   Don hang da duoc huy");

  print("\n6. Cap nhat ve xem phim sang DA_HUY...");
  sessionDb.ve_xem_phim.updateMany(
    { orderId: orderId },
    { $set: { status: "da_huy", cancelledAt: new Date() } }
  );
  print("   " + bookingTickets.length + " ve da duoc huy");

  print("\n7. Ghi log huy...");
  sessionDb.transaction_logs.insertOne({
    _id: ObjectId(),
    orderId: orderId,
    userId: userId,
    status: "cancelled",
    details: "Order cancelled by user. Released seats: " + seatsToRelease.join(", "),
    amount: order.totalAmount,
    timestamp: new Date()
  });
  print("   Ghi log huy don hang");
});

printChangedState("STATE SAU SCENARIO 3D");

// ========================================
// FINAL SUMMARY
// ========================================
print("\n\nFINAL SUMMARY - SCENARIO 3D");
printSeparator();

// Orders
const orderRows = [];
db.don_hang.find().forEach(o => {
  orderRows.push([
    o._id.toString().substring(0, 8),
    o.status.toUpperCase(),
    o.totalAmount.toLocaleString() + "d",
    o.cancelledAt ? new Date(o.cancelledAt).toLocaleString() : "N/A"
  ]);
});

if (orderRows.length > 0) {
  printTable("DON_HANG", ["Order ID", "Status", "Amount", "Cancelled At"], orderRows);
}

// Tickets
const ticketRows = [];
db.ve_xem_phim.find().forEach(t => {
  ticketRows.push([
    t.ghe,
    t.status.toUpperCase(),
    t.movieTitle,
    t.cancelledAt ? new Date(t.cancelledAt).toLocaleString() : "N/A"
  ]);
});

if (ticketRows.length > 0) {
  printTable("VE_XEM_PHIM", ["Ghe", "Status", "Movie", "Cancelled At"], ticketRows);
}

// Inventory
const inventoryRows = [];
db.gom.find().forEach(g => {
  inventoryRows.push([
    g.type.toUpperCase(),
    g.soluong
  ]);
});

if (inventoryRows.length > 0) {
  printTable("GOM - INVENTORY", ["Type", "So luong"], inventoryRows);
}

// Transaction Logs
const logRows = [];
db.transaction_logs.find().forEach(l => {
  logRows.push([
    l.status.toUpperCase(),
    l.details,
    new Date(l.timestamp).toLocaleString()
  ]);
});

if (logRows.length > 0) {
  printTable("TRANSACTION_LOGS", ["Status", "Details", "Timestamp"], logRows);
}

print("\n✓ Scenario 3D HOAN TAT! Don hang da bi huy, ghe va hang hoa da duoc hoan lai.\n");
