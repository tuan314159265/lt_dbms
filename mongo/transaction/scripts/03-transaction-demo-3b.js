// =======================================================================================
// SCENARIO 3B: ĐẶT VÉ VÀ THANH TOÁN SAU
// =======================================================================================
// Mô tả: User chọn ghế và tạo đơn nhưng chưa thanh toán. Transaction sẽ tạo DON_HANG 
// và VE_XEM_PHIM để giữ ghế, sau đó commit để tránh người khác đặt trùng.
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

printState("STATE TRUOC KHI CHAY SCENARIO 3B");

runTransactionScenario("SCENARIO 3B: Dat ve va thanh toan sau (giu ghe)", sessionDb => {
  const userId = ObjectId("507f1f77bcf86cd799439012");
  const screeningId = ObjectId("707f1f77bcf86cd799439031");
  const seats = ["D1", "D2"];
  const ticketPrice = 150000;
  const totalAmount = seats.length * ticketPrice;

  print("\n1. Dat ghe (chua thanh toan)...");
  const screening = sessionDb.screenings.findOne({ _id: screeningId });
  const conflict = seats.filter(seat => (screening.bookedSeats || []).includes(seat));

  if (conflict.length > 0) {
    throw new Error("Seats already booked: " + conflict.join(", "));
  }

  sessionDb.screenings.updateOne(
    { _id: screeningId },
    { $push: { bookedSeats: { $each: seats } } }
  );
  print("   Ghe " + seats.join(", ") + " da duoc giu");

  print("\n2. Tao DON_HANG voi trang thai CHO_THANH_TOAN...");
  const orderId = ObjectId();
  const movie = sessionDb.movies.findOne({ _id: screening.movieId });
  
  sessionDb.don_hang.insertOne({
    _id: orderId,
    userId: userId,
    screeningId: screeningId,
    totalAmount: totalAmount,
    status: "cho_thanh_toan",
    createdAt: new Date(),
    expireAt: new Date(Date.now() + 15 * 60 * 1000)  // Het han sau 15 phut
  });
  print("   Don hang ID: " + orderId + " (CHO_THANH_TOAN)");

  print("\n3. Tao VE_XEM_PHIM voi trang thai CHO_THANH_TOAN...");
  seats.forEach((seat) => {
    sessionDb.ve_xem_phim.insertOne({
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
  print("   Tao " + seats.length + " ve (" + seats.join(", ") + ") voi trang thai CHO_THANH_TOAN");

  print("\n4. COMMIT - GIU GHE CHO USER");
  print("   (User co 15 phut de thanh toan, ghe khong bi dat boi user khac)");
});

printChangedState("STATE SAU SCENARIO 3B");

// ========================================
// FINAL SUMMARY
// ========================================
print("\n\nFINAL SUMMARY - SCENARIO 3B");
printSeparator();

// Orders
const orderRows = [];
db.don_hang.find().forEach(o => {
  orderRows.push([
    o._id.toString().substring(0, 8),
    o.status.toUpperCase(),
    o.totalAmount.toLocaleString() + "d",
    o.expireAt ? new Date(o.expireAt).toLocaleString() : "N/A"
  ]);
});

if (orderRows.length > 0) {
  printTable("DON_HANG", ["Order ID", "Status", "Amount", "Expire At"], orderRows);
}

// Pending Tickets
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

// Screenings with booked seats
const screenRows = [];
db.screenings.find().forEach(s => {
  if (s.bookedSeats && s.bookedSeats.length > 0) {
    screenRows.push([
      s.screeningRoom,
      s.bookedSeats.join(", ")
    ]);
  }
});

if (screenRows.length > 0) {
  printTable("SCREENINGS - GHE DA GIU", ["Room", "Booked Seats"], screenRows);
}

print("\n✓ Scenario 3B HOAN TAT! Ghe da bi giu, dang cho user thanh toan.\n");
