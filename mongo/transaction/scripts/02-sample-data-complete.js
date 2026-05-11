// =======================================================================================
// PHẦN 1: KHỞI TẠO DATABASE VÀ SCHEMA VALIDATION
// =======================================================================================

db = db.getSiblingDB("cinema_db");

const collectionNames = [
  "users", "movies", "screenings", "bookings", "transaction_logs",
  "don_hang", "ve_xem_phim", "gom", "thanh_toan"
];

print("Đang dọn dẹp dữ liệu cũ...");
collectionNames.forEach(collectionName => {
  try {
    db.getCollection(collectionName).drop();
  } catch (e) {
    // Collection may not exist
  }
});
print("✓ Đã xóa dữ liệu cũ.\n");

// =======================================================================================
// PHẦN 2: TẠO CÁC COLLECTIONS CẦN THIẾT
// =======================================================================================

print("Đang tạo collections...");

// users
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "wallet"],
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
    }
  }
});

// movies
db.createCollection("movies", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "price"],
      properties: {
        _id: { bsonType: "objectId" },
        title: { bsonType: "string" },
        description: { bsonType: "string" },
        duration: { bsonType: ["int", "double"] },
        genre: { bsonType: "string" },
        price: { bsonType: ["double", "int"] },
        createdAt: { bsonType: "date" }
      }
    }
  }
});

// screenings
db.createCollection("screenings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["movieId", "screenTime"],
      properties: {
        _id: { bsonType: "objectId" },
        movieId: { bsonType: "objectId" },
        screeningRoom: { bsonType: "string" },
        screenTime: { bsonType: "date" },
        totalSeats: { bsonType: ["int", "double"] },
        bookedSeats: { bsonType: "array" },
        createdAt: { bsonType: "date" }
      }
    }
  }
});

// don_hang (orders)
db.createCollection("don_hang", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "screeningId", "totalAmount", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        userId: { bsonType: "objectId" },
        screeningId: { bsonType: "objectId" },
        totalAmount: { bsonType: ["double", "int"] },
        status: { bsonType: "string" },
        comboCount: { bsonType: ["int", "double"] },
        createdAt: { bsonType: "date" },
        paidAt: { bsonType: "date" },
        cancelledAt: { bsonType: "date" },
        expireAt: { bsonType: "date" }
      }
    }
  }
});

// ve_xem_phim (tickets)
db.createCollection("ve_xem_phim", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["orderId", "userId", "screeningId", "ghe"],
      properties: {
        _id: { bsonType: "objectId" },
        orderId: { bsonType: "objectId" },
        userId: { bsonType: "objectId" },
        screeningId: { bsonType: "objectId" },
        ghe: { bsonType: "string" },
        movieTitle: { bsonType: "string" },
        status: { bsonType: "string" },
        createdAt: { bsonType: "date" },
        paidAt: { bsonType: "date" },
        cancelledAt: { bsonType: "date" }
      }
    }
  }
});

// gom (combo inventory)
db.createCollection("gom", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["type", "soluong"],
      properties: {
        _id: { bsonType: "objectId" },
        type: { bsonType: "string" },
        soluong: { bsonType: ["int", "double"] },
        gia: { bsonType: ["double", "int"] },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
});

// thanh_toan (payments)
db.createCollection("thanh_toan", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["orderId", "userId", "amount", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        orderId: { bsonType: "objectId" },
        userId: { bsonType: "objectId" },
        amount: { bsonType: ["double", "int"] },
        paymentMethod: { bsonType: "string" },
        status: { bsonType: "string" },
        createdAt: { bsonType: "date" },
        paidAt: { bsonType: "date" }
      }
    }
  }
});

// transaction_logs
db.createCollection("transaction_logs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["status", "timestamp"],
      properties: {
        _id: { bsonType: "objectId" },
        orderId: { bsonType: "objectId" },
        userId: { bsonType: "objectId" },
        status: { bsonType: "string" },
        details: { bsonType: "string" },
        amount: { bsonType: ["double", "int"] },
        timestamp: { bsonType: "date" }
      }
    }
  }
});

// bookings (legacy collection)
db.createCollection("bookings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        _id: { bsonType: "objectId" }
      }
    }
  }
});

print("✓ Collections đã được tạo.\n");

// =======================================================================================
// PHẦN 3: NẠP DỮ LIỆU SAMPLE (SAMPLE DATA)
// =======================================================================================

print("================================");
print("INSERTING SAMPLE DATA");
print("================================\n");

// 1. Users - TẠO 4 USERS VỚI VÍ TIỀN ĐỦNG SỬ DỤNG
print("1. Inserting USERS...");
db.users.insertMany([
  {
    _id: ObjectId("507f1f77bcf86cd799439011"),
    email: "user1@cinema.com",
    name: "Nguyen Van A",
    phone: "0912345678",
    wallet: 2000000.0,  // 2,000,000d - đủ cho tất cả scenarios
    role: "user",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId("507f1f77bcf86cd799439012"),
    email: "user2@cinema.com",
    name: "Tran Thi B",
    phone: "0987654321",
    wallet: 1500000.0,  // 1,500,000d - đủ cho scenarios 3b, 3c, 3d
    role: "user",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId("507f1f77bcf86cd799439013"),
    email: "user3@cinema.com",
    name: "Pham Minh C",
    phone: "0933333333",
    wallet: 1800000.0,  // 1,800,000d - cho scenario 3e (race condition)
    role: "user",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId("507f1f77bcf86cd799439099"),
    email: "admin@cinema.com",
    name: "Admin Cinema",
    phone: "0900000000",
    wallet: 999999999.0,
    role: "admin",
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);
print("   ✓ Inserted 4 users\n");

// 2. Movies - TẠO 2 PHIM
print("2. Inserting MOVIES...");
db.movies.insertMany([
  {
    _id: ObjectId("607f1f77bcf86cd799439021"),
    title: "Mat Biec",
    description: "Phim tinh cam Viet Nam kinh dien",
    duration: 120,
    genre: "Drama/Romance",
    price: 150000.0,
    createdAt: new Date()
  },
  {
    _id: ObjectId("607f1f77bcf86cd799439022"),
    title: "Avatar 3",
    description: "Phim khoa hoc vien tuong hanh dong",
    duration: 180,
    genre: "Sci-Fi/Action",
    price: 150000.0,
    createdAt: new Date()
  }
]);
print("   ✓ Inserted 2 movies\n");

// 3. Screenings - TẠO 2 SUẤT CHIẾU TRÊN 1 PHIM
print("3. Inserting SCREENINGS...");
db.screenings.insertMany([
  {
    _id: ObjectId("707f1f77bcf86cd799439031"),
    movieId: ObjectId("607f1f77bcf86cd799439021"),
    screeningRoom: "Room 1",
    screenTime: new Date("2026-06-15T19:00:00Z"),
    totalSeats: 100,
    bookedSeats: [],  // Trống - sẵn sàng cho test
    createdAt: new Date()
  },
  {
    _id: ObjectId("707f1f77bcf86cd799439032"),
    movieId: ObjectId("607f1f77bcf86cd799439022"),
    screeningRoom: "Room 2",
    screenTime: new Date("2026-06-16T20:00:00Z"),
    totalSeats: 100,
    bookedSeats: [],
    createdAt: new Date()
  }
]);
print("   ✓ Inserted 2 screenings\n");

// 4. Combo Inventory - TẠO KHOHO COMBO
print("4. Inserting GOM (COMBO INVENTORY)...");
db.gom.insertMany([
  {
    _id: ObjectId(),
    type: "combo_pop",
    soluong: 100,
    gia: 80000.0,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    type: "combo_standard",
    soluong: 200,
    gia: 50000.0,
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);
print("   ✓ Inserted 2 combo types\n");

// =======================================================================================
// PHẦN 4: SUMMARY
// =======================================================================================

print("\n================================");
print("SAMPLE DATA SUMMARY");
print("================================\n");

print("USERS:");
db.users.find({}, { _id: 0, email: 1, name: 1, wallet: 1 }).forEach(user => {
  print("  • " + user.email + " (" + user.name + ") - Wallet: " + user.wallet.toLocaleString() + "d");
});

print("\nMOVIES:");
db.movies.find({}, { _id: 0, title: 1, price: 1 }).forEach(movie => {
  print("  • " + movie.title + " - Price: " + movie.price.toLocaleString() + "d per ticket");
});

print("\nSCREENINGS:");
db.screenings.find({}, { _id: 0, screeningRoom: 1, screenTime: 1, bookedSeats: 1 }).forEach(screening => {
  print("  • " + screening.screeningRoom + " - Time: " + new Date(screening.screenTime).toLocaleString());
  print("    Booked seats: [" + (screening.bookedSeats || []).join(", ") + "]");
});

print("\nCOMBO INVENTORY:");
db.gom.find({}, { _id: 0, type: 1, soluong: 1, gia: 1 }).forEach(combo => {
  print("  • " + combo.type.toUpperCase() + " - Qty: " + combo.soluong + " - Price: " + combo.gia.toLocaleString() + "d");
});

print("\nCOLLECTION STATUS:");
print("  • users:           " + db.users.countDocuments() + " documents");
print("  • movies:          " + db.movies.countDocuments() + " documents");
print("  • screenings:      " + db.screenings.countDocuments() + " documents");
print("  • gom:             " + db.gom.countDocuments() + " documents");
print("  • don_hang:        " + db.don_hang.countDocuments() + " documents (empty - ready for test)");
print("  • ve_xem_phim:     " + db.ve_xem_phim.countDocuments() + " documents (empty - ready for test)");
print("  • thanh_toan:      " + db.thanh_toan.countDocuments() + " documents (empty - ready for test)");
print("  • transaction_logs: " + db.transaction_logs.countDocuments() + " documents (empty - ready for test)");

print("\n================================");
print("✓ SETUP HOAN TAT!");
print("================================");
print("\nCo the chay 5 scenarios test:");
print("  1. 03-transaction-demo-3a.js  (Dat ve + thanh toan ngay)");
print("  2. 03-transaction-demo-3b.js  (Dat ve + thanh toan sau)");
print("  3. 03-transaction-demo-3c.js  (Thanh toan don cho)");
print("  4. 03-transaction-demo-3d.js  (Huy don cho thanh toan)");
print("  5. 03-transaction-demo-3e.js  (Race condition - 2 users cung chon 1 ghe)\n");
