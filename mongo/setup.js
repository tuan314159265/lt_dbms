// Chọn database

// Xóa dữ liệu cũ nếu chạy lại
db.movies.drop();
db.users.drop();
db.cinemas.drop();
db.showtimes.drop();
db.orders.drop();

// =========================================================
// 1. CHÈN DỮ LIỆU PHIM (Đã thêm phim mới cho demo)
// =========================================================
db.movies.insertMany([
  {
    _id: "PH001",
    title: "Avengers: Endgame",
    duration: 180,
    language: "English",
    country: "USA",
    director: "Anthony Russo",
    cast: "Robert Downey Jr.",
    releaseDate: ISODate("2019-04-26T00:00:00Z"),
    ageRating: 13,
    genres: ["Hành động", "Siêu anh hùng"], // Nhúng bảng THE_LOAI_PHIM
    posterUrl: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg"
  },
  {
    _id: "PH002",
    title: "Nhà Bà Nữ",
    duration: 120,
    language: "Tiếng Việt",
    country: "Việt Nam",
    director: "Trấn Thành",
    cast: "Lê Giang",
    releaseDate: ISODate("2023-01-22T00:00:00Z"),
    ageRating: 13,
    genres: ["Hài", "Gia đình"],
    posterUrl: "https://upload.wikimedia.org/wikipedia/vi/thumb/6/6f/..."
  },
  {
    _id: "PH016", // Dữ liệu Generate thêm
    title: "Avatar: Fire and Ash",
    duration: 190,
    language: "English",
    country: "USA",
    director: "James Cameron",
    cast: "Sam Worthington",
    releaseDate: ISODate("2025-12-19T00:00:00Z"),
    ageRating: 13,
    genres: ["Viễn tưởng", "Hành động"],
    posterUrl: "https://image.tmdb.org/t/p/w500/avatar3.jpg"
  },
  {
    _id: "PH017", // Dữ liệu Generate thêm
    title: "Deadpool & Wolverine 2",
    duration: 130,
    language: "English",
    country: "USA",
    director: "Shawn Levy",
    cast: "Ryan Reynolds, Hugh Jackman",
    releaseDate: ISODate("2026-05-15T00:00:00Z"),
    ageRating: 18,
    genres: ["Hành động", "Hài"],
    posterUrl: "https://image.tmdb.org/t/p/w500/dpwv2.jpg"
  }
]);

// =========================================================
// 2. CHÈN DỮ LIỆU USERS (Gộp Khách hàng & Admin)
// =========================================================
db.users.insertMany([
  {
    _id: "KH001",
    fullName: "Nguyễn Văn A",
    phone: "0901111111",
    email: "a@example.com",
    role: "Khach",
    customerInfo: {
      memberTier: "Bronze",
      points: 33
    }
  },
  {
    _id: "KH002",
    fullName: "Trần Thị B",
    phone: "0902222222",
    email: "b@example.com",
    role: "Khach",
    customerInfo: {
      memberTier: "Silver",
      points: 210
    }
  },
  {
    _id: "AD001",
    fullName: "Admin Quản Lý",
    phone: "0911111111",
    email: "admin1@example.com",
    role: "Admin",
    adminInfo: {
      salary: 20000000,
      position: "Quản lý rạp",
      startDate: ISODate("2024-01-01T00:00:00Z")
    }
  }
]);
// =========================================================
// ORDERS (Đơn hàng — embedding items thay vì JOIN)
// =========================================================
db.orders.drop();
db.orders.insertMany([
  {
    _id: "DH001",
    userId: "KH001",
    status: "delivered",
    createdAt: ISODate("2024-03-01T10:00:00Z"),
    totalAmount: 180000,
    items: [
      { product_id: "PH001", product_name: "Avengers: Endgame", quantity: 2, price: 90000 }
    ]
  },
  {
    _id: "DH002",
    userId: "KH002",
    status: "delivered",
    createdAt: ISODate("2024-03-05T14:00:00Z"),
    totalAmount: 120000,
    items: [
      { product_id: "PH002", product_name: "Nhà Bà Nữ", quantity: 1, price: 120000 }
    ]
  },
  {
    _id: "DH003",
    userId: "KH001",
    status: "pending",
    createdAt: ISODate("2024-03-10T09:00:00Z"),
    totalAmount: 90000,
    items: [
      { product_id: "PH016", product_name: "Avatar: Fire and Ash", quantity: 1, price: 90000 }
    ]
  }
]);

// =========================================================
// REVIEWS (Đánh giá — cho demo GROUP BY + SORT)
// =========================================================
db.reviews.drop();
db.reviews.insertMany([
  { _id: "DG001", product_id: "PH001", userId: "KH001", rating: { score: 9 }, createdAt: ISODate("2024-03-02T00:00:00Z") },
  { _id: "DG002", product_id: "PH001", userId: "KH002", rating: { score: 8 }, createdAt: ISODate("2024-03-06T00:00:00Z") },
  { _id: "DG003", product_id: "PH002", userId: "KH001", rating: { score: 7 }, createdAt: ISODate("2024-03-07T00:00:00Z") },
  { _id: "DG004", product_id: "PH002", userId: "KH002", rating: { score: 9 }, createdAt: ISODate("2024-03-08T00:00:00Z") },
  { _id: "DG005", product_id: "PH016", userId: "KH001", rating: { score: 10 }, createdAt: ISODate("2024-03-09T00:00:00Z") },
  { _id: "DG006", product_id: "PH017", userId: "KH002", rating: { score: 6 }, createdAt: ISODate("2024-03-10T00:00:00Z") }
]);

// =========================================================
// INDEX cho demo Case Study 1 & 2
// =========================================================
db.orders.createIndex({ status: 1 });
db.reviews.createIndex({ product_id: 1 });
db.reviews.createIndex({ "rating.score": -1 });