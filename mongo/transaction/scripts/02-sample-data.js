// =======================================================================================
// PHẦN 1: KHỞI TẠO DATABASE VÀ DỌN DẸP DỮ LIỆU CŨ
// =======================================================================================

db = db.getSiblingDB("cinema_db");

const collections = ["users", "movies", "screenings"];

print("Đang dọn dẹp dữ liệu mẫu cũ...");
collections.forEach(collectionName => db.getCollection(collectionName).deleteMany({}));
print("Đã xóa dữ liệu cũ trong các collection mẫu.");

function seedCollection(collectionName, documents, successMessage) {
  db.getCollection(collectionName).insertMany(documents);
  print(successMessage);
}

// =======================================================================================
// PHẦN 2: NẠP DỮ LIỆU (INSERT DATA)
// =======================================================================================

// 1. Collection: users
print("Đang nạp dữ liệu users...");
seedCollection(
  "users",
  [
    {
      _id: ObjectId("507f1f77bcf86cd799439011"),
      email: "user1@cinema.com",
      name: "Nguyễn Văn A",
      phone: "0912345678",
      wallet: 500000.0,
      role: "user",
      createdAt: new Date(),
      updatedAt: new Date()
    },
    {
      _id: ObjectId("507f1f77bcf86cd799439012"),
      email: "user2@cinema.com",
      name: "Trần Thị B",
      phone: "0987654321",
      wallet: 200000.0,
      role: "user",
      createdAt: new Date(),
      updatedAt: new Date()
    },
    {
      _id: ObjectId("507f1f77bcf86cd799439013"),
      email: "admin@cinema.com",
      name: "Admin Cinema",
      phone: "0900000000",
      wallet: 999999999.0,
      role: "admin",
      createdAt: new Date(),
      updatedAt: new Date()
    }
  ],
  "Users inserted successfully!"
);

// 2. Collection: movies
print("Đang nạp dữ liệu movies...");
seedCollection(
  "movies",
  [
    {
      _id: ObjectId("607f1f77bcf86cd799439021"),
      title: "Mắt Biếc",
      description: "Bộ phim tình cảm Việt Nam",
      duration: 120,
      genre: "Drama/Romance",
      price: 150000.0,
      createdAt: new Date()
    },
    {
      _id: ObjectId("607f1f77bcf86cd799439022"),
      title: "Avatar 3",
      description: "Khoa học viễn tưởng hành động",
      duration: 180,
      genre: "Sci-Fi/Action",
      price: 200000.0,
      createdAt: new Date()
    },
    {
      _id: ObjectId("607f1f77bcf86cd799439023"),
      title: "Conan",
      description: "Hoạt hình khám phá",
      duration: 90,
      genre: "Animation",
      price: 100000.0,
      createdAt: new Date()
    }
  ],
  "Movies inserted successfully!"
);

// 3. Collection: screenings
print("Đang nạp dữ liệu screenings...");
seedCollection(
  "screenings",
  [
    {
      _id: ObjectId("707f1f77bcf86cd799439031"),
      movieId: ObjectId("607f1f77bcf86cd799439021"),
      screeningRoom: "Phòng 1",
      screenTime: new Date("2026-06-10T19:00:00Z"),
      totalSeats: 100,
      bookedSeats: ["A1", "A2", "B1"],
      createdAt: new Date()
    },
    {
      _id: ObjectId("707f1f77bcf86cd799439032"),
      movieId: ObjectId("607f1f77bcf86cd799439022"),
      screeningRoom: "Phòng 2",
      screenTime: new Date("2026-06-11T20:00:00Z"),
      totalSeats: 120,
      bookedSeats: [],
      createdAt: new Date()
    }
  ],
  "Screenings inserted successfully!"
);

// =======================================================================================
// PHẦN 3: TỔNG KẾT DỮ LIỆU
// =======================================================================================

print("");
print("Sample data inserted successfully!");
print("   Users:     " + db.users.countDocuments());
print("   Movies:    " + db.movies.countDocuments());
print("   Screenings:" + db.screenings.countDocuments());
print("");
print("   User1 (Nguyen Van A) wallet: 500,000d - du tien dat 2 ve (300k)");
print("   User2 (Tran Thi B)   wallet: 200,000d - KHONG du dat 5 ve (750k)");
print("   Screening 1 pre-booked seats: A1, A2, B1");
