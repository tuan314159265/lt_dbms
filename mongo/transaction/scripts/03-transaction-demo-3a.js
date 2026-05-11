// =======================================================================================
// SCENARIO 3A: ĐẶT VÉ VÀ THANH TOÁN NGAY
// =======================================================================================
// Mô tả: User chọn suất chiếu, ghế và combo rồi tiến hành thanh toán ngay. 
// Hệ thống tạo DON_HANG, VE_XEM_PHIM, GOM và THANH_TOAN trong cùng transaction, 
// sau đó commit toàn bộ nếu thành công.
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

printState("STATE TRUOC KHI CHAY SCENARIO 3A");

runTransactionScenario("SCENARIO 3A: Dat ve va thanh toan ngay", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439011");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["C1", "C2"];
  const ticketPrice = 150000;
  const comboPrice = 80000;
  const totalAmount = seats.length * ticketPrice + comboPrice;

  print("\n1. Kiem tra vi so tien...");
  const userBefore = sessionDb.users.findOne({ _id: userId });
  print("   Wallet truoc: " + userBefore.wallet + "d  |  Can: " + totalAmount + "d");

  if (userBefore.wallet < totalAmount) {
    throw new Error("Insufficient balance: " + userBefore.wallet + "d < " + totalAmount + "d");
  }

  print("\n2. Tru tien vi...");
  sessionDb.users.updateOne(
    { _id: userId },
    { $inc: { wallet: -totalAmount }, $set: { updatedAt: new Date() } }
  );
  print("   Da tru " + totalAmount + "d");

  print("\n3. Kiem tra ghe khong bi dat...");
  const screening = sessionDb.screenings.findOne({ _id: screeningId });
  const conflict = seats.filter(seat => (screening.bookedSeats || []).includes(seat));

  if (conflict.length > 0) {
    throw new Error("Seats already booked: " + conflict.join(", "));
  }

  print("\n4. Dat ghe...");
  sessionDb.screenings.updateOne(
    { _id: screeningId },
    { $push: { bookedSeats: { $each: seats } } }
  );
  print("   Ghe " + seats.join(", ") + " da duoc dat");

  print("\n5. Tao DON_HANG...");
  const orderId = ObjectId();
  sessionDb.don_hang.insertOne({
    _id: orderId,
    userId: userId,
    screeningId: screeningId,
    totalAmount: totalAmount,
    status: "da_thanh_toan",
    createdAt: new Date(),
    paidAt: new Date()
  });
  print("   Don hang ID: " + orderId);

  print("\n6. Tao VE_XEM_PHIM...");
  const movie = sessionDb.movies.findOne({ _id: screening.movieId });
  seats.forEach((seat, idx) => {
    sessionDb.ve_xem_phim.insertOne({
      _id: ObjectId(),
      orderId: orderId,
      userId: userId,
      screeningId: screeningId,
      ghe: seat,
      movieTitle: movie.title,
      status: "da_thanh_toan",
      createdAt: new Date()
    });
  });
  print("   Tao " + seats.length + " ve (" + seats.join(", ") + ")");

  print("\n7. Tao GOM (combo)...");
  sessionDb.gom.updateOne(
    { type: "combo_pop" },
    { $inc: { soluong: -1 } },
    { upsert: true }
  );
  print("   Tru 1 combo pop, gia " + comboPrice + "d");

  print("\n8. Tao THANH_TOAN...");
  sessionDb.thanh_toan.insertOne({
    _id: ObjectId(),
    orderId: orderId,
    userId: userId,
    amount: totalAmount,
    paymentMethod: "wallet",
    status: "thanh_cong",
    createdAt: new Date(),
    paidAt: new Date()
  });
  print("   Thanh toan " + totalAmount + "d bang wallet");
});

printChangedState("STATE SAU SCENARIO 3A");

// ========================================
// FINAL SUMMARY
// ========================================
print("\n\nFINAL SUMMARY - SCENARIO 3A");
printSeparator();

// Orders
const orderRows = [];
db.don_hang.find().forEach(o => {
  orderRows.push([
    o._id.toString().substring(0, 8),
    o.status.toUpperCase(),
    o.totalAmount.toLocaleString() + "d",
    new Date(o.createdAt).toLocaleString()
  ]);
});

if (orderRows.length > 0) {
  printTable("DON_HANG", ["Order ID", "Status", "Amount", "Created"], orderRows);
}

// Tickets
const ticketRows = [];
db.ve_xem_phim.find().forEach(t => {
  ticketRows.push([
    t.ghe,
    t.status.toUpperCase(),
    t.movieTitle,
    new Date(t.createdAt).toLocaleString()
  ]);
});

if (ticketRows.length > 0) {
  printTable("VE_XEM_PHIM", ["Ghe", "Status", "Movie", "Created"], ticketRows);
}

// Payments
const paymentRows = [];
db.thanh_toan.find().forEach(p => {
  paymentRows.push([
    p._id.toString().substring(0, 8),
    p.status.toUpperCase(),
    p.amount.toLocaleString() + "d",
    new Date(p.createdAt).toLocaleString()
  ]);
});

if (paymentRows.length > 0) {
  printTable("THANH_TOAN", ["Payment ID", "Status", "Amount", "Created"], paymentRows);
}

print("\n✓ Scenario 3A HOAN TAT! Dat ve va thanh toan ngay thanh cong.\n");
