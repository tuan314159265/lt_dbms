// =======================================================================================
// PHẦN 1: KHỞI TẠO DATABASE VÀ DỌN DẸP
// =======================================================================================
print("Đang khởi tạo database 'ecommerce_db'...");
db = db.getSiblingDB('ecommerce_db');
const collections = ["users", "categories", "products", "vouchers", "carts", "orders", "reviews"];
collections.forEach(col => {
    db.getCollection(col).drop();
});
print("Đã dọn dẹp các collection cũ.");

// =======================================================================================
// PHẦN 2: NẠP DỮ LIỆU (INSERT DATA)
// =======================================================================================

// 1. Collection: users
print("Đang nạp dữ liệu users...");
db.users.insertMany([
  { _id: "U2310110", first_name: "Anh", last_name: "Nguyễn Ngọc Hoàng", username: "hoanganh1812", password: "$2b$10$hashedpass1", birthday: new Date("2005-12-18"), sex: "Nữ", address: "48/44 đường Tân Quý, phường Bình Tân, TP.HCM", phone_number: "0799610456", email: "anh.nguyen@hcmut.edu.vn", roles: ["buyer"], following_sellers: ["U2213838", "U2313178"], created_at: new Date() },
  { _id: "U2313522", first_name: "Trang", last_name: "Võ Ngọc Thùy", username: "trangvongocthuy1008", password: "$2b$10$hashedpass2", birthday: new Date("2005-08-10"), sex: "Nữ", address: "269 đường Ông Ích Khiêm, phường Tân Phú, TP.HCM", phone_number: "0562650565", email: "trangvongocthuy1008@hcmut.edu.vn", roles: ["buyer"], following_sellers: ["U2313178"], created_at: new Date() },
  { _id: "U2433225", first_name: "Trang", last_name: "Dương Thị Tuyết", username: "trangduong", password: "$2b$10$hashedpass3", birthday: new Date("2007-07-24"), sex: "Nữ", address: "349 đường Điện Biên Phủ, phường Thảo Điền, TP.HCM", phone_number: "0165144651", email: "trangduongthituyet@hcmut.edu.vn", roles: ["buyer"], following_sellers: ["U2213838"], created_at: new Date() },
  { _id: "U2213838", first_name: "Tú", last_name: "Dương Tú", username: "duongtutu", password: "$2b$10$hashedpass4", birthday: new Date("2003-03-24"), sex: "Nam", address: "284 đường Quảng trường Sáng tạo, phường Thủ Đức, TP.HCM", phone_number: "0516516514", email: "tuduongtu@hcmut.edu.vn", roles: ["seller"], shop_name: "TuTechShop", created_at: new Date() },
  { _id: "U2313178", first_name: "Thắng", last_name: "Huỳnh Quốc", username: "thanghuynh", password: "$2b$10$hashedpass5", birthday: new Date("2005-05-18"), sex: "Nam", address: "126/2 đường Gò Dầu, phường Phú Thọ Hòa, TP.HCM", phone_number: "0154894589", email: "thanghuynh@hcmut.edu.vn", roles: ["seller"], shop_name: "ThangGadget", created_at: new Date() },
  { _id: "U2314111", first_name: "Minh", last_name: "Lê Thị", username: "minhle123", password: "$2b$10$hashedpass6", birthday: new Date("2004-03-05"), sex: "Nữ", address: "12 Lê Lợi, Phường Nhà Bè, TP.HCM", phone_number: "0987654321", email: "minhle123@gmail.com", roles: ["buyer", "seller"], shop_name: "MinhStore", created_at: new Date() },
  { _id: "U2314222", first_name: "Huy", last_name: "Nguyễn Văn", username: "huynguyen", password: "$2b$10$hashedpass7", birthday: new Date("2004-07-20"), sex: "Nam", address: "99 Nguyễn Trãi, phường Tân Thới Hiệp, TP.HCM", phone_number: "0912345678", email: "huynguyen@gmail.com", roles: ["buyer", "seller"], shop_name: "HuyTech", following_sellers: ["U2213838"], created_at: new Date() },
  { _id: "U2314333", first_name: "Lan", last_name: "Phạm Thị", username: "lanpham", password: "$2b$10$hashedpass8", birthday: new Date("2005-11-11"), sex: "Nữ", address: "55 Trần Hưng Đạo, Phường Diên Hồng, TP.HCM", phone_number: "0923456789", email: "lanpham@gmail.com", roles: ["buyer", "seller"], shop_name: "LanFashion", following_sellers: ["U2313178"], created_at: new Date() }
]);

// 2. Collection: categories
print("Đang nạp dữ liệu categories...");
db.categories.insertMany([
  { _id: "G2100001", name: "Điện thoại", description: "Các loại điện thoại thông minh", parent_id: "G2100004" },
  { _id: "G2100002", name: "Phụ kiện", description: "Tai nghe, sạc, dây cáp", parent_id: "G2100001" },
  { _id: "G2100003", name: "Laptop", description: "Máy tính xách tay các thương hiệu", parent_id: "G2100001" },
  { _id: "G2100004", name: "Thời trang", description: "Quần áo và phụ kiện thời trang", parent_id: "G2100002" },
  { _id: "G2100005", name: "Đồng hồ", description: "Đồng hồ thông minh và cơ", parent_id: "G2100002" }
]);

// 3. Collection: products
print("Đang nạp dữ liệu products...");
db.products.insertMany([
  { _id: "P2200001", seller_id: "U2213838", name: "iPhone 14", weight: 0.4, product_size: "6.1 inch", origin: "Mỹ", brand: "Apple", description: "Điện thoại Apple mới nhất", price: 12500000, stock_quantity: 20, rating_avg: 4.9, image_url: "iphone14.jpg", status: "active", category_ids: ["G2100001"], created_at: new Date("2025-10-01") },
  { _id: "P2200002", seller_id: "U2313178", name: "Tai nghe Bluetooth", weight: 0.2, product_size: "Nhỏ", origin: "Trung Quốc", brand: "SoundMax", description: "Tai nghe không dây âm thanh chuẩn", price: 500000, stock_quantity: 50, rating_avg: 4.5, image_url: "tainghe.jpg", status: "active", category_ids: ["G2100002"], created_at: new Date("2025-09-28") },
  { _id: "P2200003", seller_id: "U2213838", name: "MacBook Air M2", weight: 1.3, product_size: "13 inch", origin: "Mỹ", brand: "Apple", description: "Laptop mỏng nhẹ pin trâu", price: 19000000, stock_quantity: 10, rating_avg: 4.8, image_url: "macbook.jpg", status: "active", category_ids: ["G2100003"], created_at: new Date("2025-08-30") },
  { _id: "P2200004", seller_id: "U2314333", name: "Áo thun Local", weight: 0.2, product_size: "L", origin: "Vietnam", brand: "Local", description: "Áo thun chất lượng", price: 450000, stock_quantity: 100, rating_avg: 4.5, image_url: "aothun.jpg", status: "active", category_ids: ["G2100004"], created_at: new Date("2025-10-01") },
  { _id: "P2200005", seller_id: "U2314222", name: "Đồng hồ Casio", weight: 0.1, product_size: "Free", origin: "Japan", brand: "Casio", description: "Đồng hồ nam", price: 2500000, stock_quantity: 50, rating_avg: 4.8, image_url: "dongho.jpg", status: "active", category_ids: ["G2100005"], created_at: new Date("2025-10-02") },
  { _id: "P2200006", seller_id: "U2314111", name: "Chuột không dây", weight: 0.15, product_size: "Tiêu chuẩn", origin: "Trung Quốc", brand: "Logitech", description: "Chuột gaming chuẩn", price: 1200000, stock_quantity: 40, rating_avg: 4.7, image_url: "chuot.jpg", status: "active", category_ids: ["G2100002"], created_at: new Date("2025-10-20") },
  { _id: "P2200007", seller_id: "U2314222", name: "Tai nghe In-ear", weight: 0.05, product_size: "Nhỏ", origin: "Trung Quốc", brand: "Sony", description: "Tai nghe nhỏ gọn", price: 350000, stock_quantity: 60, rating_avg: 4.4, image_url: "tainghe2.jpg", status: "active", category_ids: ["G2100002"], created_at: new Date("2025-10-21") },
  { _id: "P2200008", seller_id: "U2314333", name: "Bàn phím cơ", weight: 0.8, product_size: "Fullsize", origin: "Trung Quốc", brand: "Corsair", description: "Bàn phím cơ RGB", price: 1500000, stock_quantity: 25, rating_avg: 4.6, image_url: "banphim.jpg", status: "active", category_ids: ["G2100002"], created_at: new Date("2025-10-22") }
]);

// 4. Collection: carts
print("Đang nạp dữ liệu carts...");
db.carts.insertMany([
  { _id: "C2300001", buyer_id: "U2310110", created_at: new Date("2025-10-20"), items: [ { cart_item_id: "D2400001", product_id: "P2200001", quantity: 1, price_at_add: 12500000 }, { cart_item_id: "D2400002", product_id: "P2200002", quantity: 1, price_at_add: 500000 } ] },
  { _id: "C2300002", buyer_id: "U2313522", created_at: new Date("2025-10-21"), items: [ { cart_item_id: "D2400003", product_id: "P2200003", quantity: 1, price_at_add: 19000000 } ] },
  { _id: "C2300003", buyer_id: "U2433225", created_at: new Date("2025-10-22"), items: [ { cart_item_id: "D2400004", product_id: "P2200002", quantity: 2, price_at_add: 500000 } ] }
]);

// 5. Collection: orders
print("Đang nạp dữ liệu orders...");
db.orders.insertMany([
  { _id: "O2500001", buyer_id: "U2310110", status: "delivered", delivery_address: "48/44 Tân Quý, phường Bình Tân, TP.HCM", order_date: new Date("2025-10-15"), items: [{ order_item_id: "I2600001", product_id: "P2200001", quantity: 1, price: 12500000 }], payment: { payment_id: "M2700001", method: "COD", amount: 12500000, status: "completed", payment_date: new Date("2025-10-22") }, delivery: { delivery_id: "Y2800001", courier_name: "GHTK", delivering_fee: 25000, status: "delivered", expected_delivery_date: new Date("2025-10-22") } },
  { _id: "O2500002", buyer_id: "U2313522", status: "delivered", delivery_address: "269 Ông Ích Khiêm, phường Tân Phú, TP.HCM", order_date: new Date("2025-09-20"), items: [{ order_item_id: "I2600002", product_id: "P2200003", quantity: 1, price: 19000000 }], payment: { payment_id: "M2700002", method: "Online", amount: 19000000, status: "pending", payment_date: new Date("2025-10-25") }, delivery: { delivery_id: "Y2800002", courier_name: "VNPost", delivering_fee: 30000, status: "in_transit", expected_delivery_date: new Date("2025-10-28") } },
  { _id: "O2500003", buyer_id: "U2433225", status: "delivered", delivery_address: "349 Điện Biên Phủ, phường Thảo Điền, TP.HCM", order_date: new Date("2025-10-05"), items: [{ order_item_id: "I2600003", product_id: "P2200004", quantity: 2, price: 900000 }], payment: { payment_id: "M2700003", method: "COD", amount: 1000000, status: "completed", payment_date: new Date("2025-10-23") }, delivery: { delivery_id: "Y2800003", courier_name: "J&T", delivering_fee: 20000, status: "pending", expected_delivery_date: new Date("2025-10-24") } },
  { _id: "O2500004", buyer_id: "U2314111", status: "delivered", delivery_address: "12 Lê Lợi, phường An Lạc, TP.HCM", order_date: new Date("2025-10-22"), items: [{ order_item_id: "I2600004", product_id: "P2200006", quantity: 1, price: 1200000 }], payment: { payment_id: "M2700004", method: "Online", amount: 1200000, status: "completed", payment_date: new Date("2025-10-26") }, delivery: { delivery_id: "Y2800004", courier_name: "GHN", delivering_fee: 25000, status: "delivered", expected_delivery_date: new Date("2025-10-27") } },
  { _id: "O2500005", buyer_id: "U2314222", status: "delivered", delivery_address: "99 Nguyễn Trãi, phường Diên Hồng, TP.HCM", order_date: new Date("2025-10-23"), items: [{ order_item_id: "I2600005", product_id: "P2200007", quantity: 1, price: 350000 }], payment: { payment_id: "M2700005", method: "Online", amount: 350000, status: "pending", payment_date: new Date("2025-10-24") }, delivery: { delivery_id: "Y2800005", courier_name: "ViettelPost", delivering_fee: 30000, status: "in_transit", expected_delivery_date: new Date("2025-10-29") } },
  { _id: "O2500006", buyer_id: "U2314333", status: "pending", delivery_address: "55 Trần Hưng Đạo, phường Tân Sơn Nhì, TP.HCM", order_date: new Date("2025-10-24"), items: [{ order_item_id: "I2600006", product_id: "P2200008", quantity: 2, price: 1500000 }], payment: { payment_id: "M2700006", method: "Online", amount: 3000000, status: "completed", payment_date: new Date("2025-10-27") }, delivery: { delivery_id: "Y2800006", courier_name: "GHTK", delivering_fee: 25000, status: "delivered", expected_delivery_date: new Date("2025-10-30") } }
]);

// 6. Collection: vouchers
print("Đang nạp dữ liệu vouchers...");
db.vouchers.insertMany([
  { _id: "V2920001", code: "SHOP10", description: "Giảm 10% cho đơn hàng trên 1 triệu", discount_type: "percentage", discount_value: 10, min_purchase: 1000000, start_date: new Date("2025-10-01"), end_date: new Date("2025-12-31"), applicable_type: "shop", seller_id: "U2213838" },
  { _id: "V2920002", code: "GLOBAL50", description: "Giảm 50k cho đơn hàng bất kỳ", discount_type: "fixed_amount", discount_value: 50000, min_purchase: 0, start_date: new Date("2025-10-01"), end_date: new Date("2025-12-31"), applicable_type: "product", product_ids: ["P2200001"] },
  { _id: "V2920003", code: "SHOP15", description: "Giảm 15% cho đơn hàng trên 2 triệu", discount_type: "percentage", discount_value: 15, min_purchase: 2000000, start_date: new Date("2025-10-05"), end_date: new Date("2025-12-31"), applicable_type: "shop", seller_id: "U2313178" },
  { _id: "V2920004", code: "GLOBAL100", description: "Giảm 100k cho đơn trên 1.5 triệu", discount_type: "fixed_amount", discount_value: 100000, min_purchase: 1500000, start_date: new Date("2025-10-07"), end_date: new Date("2025-12-31"), applicable_type: "product", product_ids: ["P2200003"] },
  { _id: "V2920005", code: "SHOP20", description: "Giảm 20% cho đơn trên 1 triệu", discount_type: "percentage", discount_value: 20, min_purchase: 1000000, start_date: new Date("2025-10-10"), end_date: new Date("2025-12-31"), applicable_type: "shop", seller_id: "U2314222" },
  { _id: "V2920006", code: "FREESHIP50", description: "Giảm 50k cho đơn hàng bất kỳ", discount_type: "fixed_amount", discount_value: 50000, min_purchase: 0, start_date: new Date("2025-10-12"), end_date: new Date("2025-12-31"), applicable_type: "freeship" }
]);

// 7. Collection: reviews
print("Đang nạp dữ liệu reviews...");
db.reviews.insertMany([
  { _id: "R2900001", buyer_id: "U2310110", product_id: "P2200001", title: "Rất hài lòng", content: "Sản phẩm chất lượng tuyệt vời!", created_at: new Date("2025-10-25"), rating: { rating_id: "T2910001", score: 5, packaging: 5, delivery: 5, quality: 5 }, media: [ { media_url: "img_review1.jpg", media_type: "image" }, { media_url: "review1.mp4", media_type: "video" } ] },
  { _id: "R2900002", buyer_id: "U2313522", product_id: "P2200003", title: "Tốt", content: "Giao hàng nhanh, đóng gói kỹ.", created_at: new Date("2025-10-26"), rating: { rating_id: "T2910002", score: 4, packaging: 4, delivery: 4, quality: 4 }, media: [ { media_url: "img_review2.png", media_type: "image" } ] },
  { _id: "R2900003", buyer_id: "U2433225", product_id: "P2200004", title: "Ổn định", content: "Pin dùng bền, hình ảnh rõ nét.", created_at: new Date("2025-10-27"), rating: { rating_id: "T2910003", score: 5, packaging: 4, delivery: 5, quality: 5 }, media: [ { media_url: "img_review3.jpg", media_type: "image" }, { media_url: "review3.mp4", media_type: "video" } ] },
  { _id: "R2900004", buyer_id: "U2314111", product_id: "P2200006", title: "Chấp nhận được", content: "Sản phẩm hơi khác hình minh họa.", created_at: new Date("2025-10-28"), rating: { rating_id: "T2910004", score: 3, packaging: 3, delivery: 4, quality: 3 }, media: [ { media_url: "img_review4.jpg", media_type: "image" } ] },
  { _id: "R2900005", buyer_id: "U2314222", product_id: "P2200007", title: "Tuyệt vời", content: "Dịch vụ hỗ trợ khách hàng rất tốt.", created_at: new Date("2025-10-29"), rating: { rating_id: "T2910005", score: 5, packaging: 5, delivery: 5, quality: 5 }, media: [ { media_url: "img_review5.jpg", media_type: "image" }, { media_url: "review5.mp4", media_type: "video" } ] }
]);

// =======================================================================================
// PHẦN 3: TẠO INDEXES (Tối ưu hiệu năng truy vấn)
// =======================================================================================
print("Đang tạo Indexes...");
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true });
db.products.createIndex({ seller_id: 1 });
db.products.createIndex({ status: 1 });
db.products.createIndex({ name: "text" }); 
db.orders.createIndex({ buyer_id: 1 });
db.orders.createIndex({ status: 1 });
db.orders.createIndex({ order_date: -1 });
db.reviews.createIndex({ product_id: 1 });

print("DATABASE MONGODB SETUP COMPLETED SUCCESSFULLY!");