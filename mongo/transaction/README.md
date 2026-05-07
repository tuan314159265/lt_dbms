# 🍃 Hướng dẫn chạy MongoDB Transaction Demo
# Windows PowerShell - Từng bước chi tiết

---

## 📋 BƯỚC 0: Kiểm tra cấu trúc thư mục

Chạy lệnh này để xem file nằm ở đâu:

```powershell
dir D:\Desktop\mongodb\mongodb\
```

Bạn phải thấy các file:
- 01-init-collections.js
- 02-sample-data.js  
- 03-transaction-demo.js

---

## 🚀 BƯỚC 1: Xóa container cũ và khởi động lại

```powershell
cd D:\Desktop\mongodb

docker compose down -v

docker compose up -d mongodb
```

Đợi 20 giây để MongoDB khởi động xong.

---

## ✅ BƯỚC 2: Kiểm tra container đang chạy

```powershell
docker ps
```

Phải thấy container tên `temp-mongodb` đang **Up**.

---

## 🔧 BƯỚC 3: Init Replica Set

```powershell
docker exec temp-mongodb mongosh --eval "rs.initiate({ _id: 'rs0', members: [{ _id: 0, host: 'localhost:27017' }] })"
```

Kết quả mong đợi: `{ ok: 1 }`

---

## ⏳ BƯỚC 4: Đợi Primary được bầu

```powershell
Start-Sleep -Seconds 8
```

Kiểm tra — phải ra `true`:

```powershell
docker exec temp-mongodb mongosh --quiet --eval "db.isMaster().ismaster"
```

⚠️ Nếu ra `false`, đợi thêm 5 giây rồi chạy lại lệnh kiểm tra.

---

## 📂 BƯỚC 5: Copy file vào container

Chạy từng lệnh một, kiểm tra "Successfully copied" sau mỗi lệnh:

```powershell
docker cp scripts\01-init-collections.js temp-mongodb:/01-init-collections.js
```
```
docker cp scripts\02-sample-data.js temp-mongodb:/02-sample-data.js
```
```powershell
docker cp scripts\03-transaction-demo.js temp-mongodb:/03-transaction-demo.js
```

docker cp scripts\01-init-collections.js temp-mongodb:/01-init-collections.js ; docker cp scripts\02-sample-data.js temp-mongodb:/02-sample-data.js ; docker cp scripts\03-transaction-demo.js temp-mongodb:/03-transaction-demo.js

⚠️ Nếu báo lỗi "file not found", thử:
```powershell
docker cp scripts/01-init-collections.js temp-mongodb:/01-init-collections.js
docker cp scripts/02-sample-data.js temp-mongodb:/02-sample-data.js
docker cp scripts/03-transaction-demo.js temp-mongodb:/03-transaction-demo.js
```

---

## 🗄️ BƯỚC 6: Tạo Collections và Index

```powershell
docker exec temp-mongodb mongosh cinema_db /01-init-collections.js
```

Kết quả mong đợi:
```
✅ Collections and indexes created successfully!
```

---

## 📝 BƯỚC 7: Insert dữ liệu mẫu

```powershell
docker exec temp-mongodb mongosh cinema_db /02-sample-data.js
```

Kết quả mong đợi:
```
✅ Sample data inserted successfully!
   Users:     3
   Movies:    3
   Screenings:2
```

---

## 🎬 BƯỚC 8: Chạy Demo Transaction

```powershell
docker exec temp-mongodb mongosh cinema_db /03-transaction-demo.js
```

Kết quả mong đợi:
```
📌 SCENARIO 1: Đặt vé THÀNH CÔNG
✅ TRANSACTION COMMITTED!

📌 SCENARIO 2: Đặt vé THẤT BẠI - Không đủ tiền
❌ TRANSACTION ROLLED BACK: Insufficient balance...

📌 SCENARIO 3: Đặt vé THẤT BẠI - Ghế đã bị đặt
❌ TRANSACTION ROLLED BACK: Seat(s) already reserved...

✅ Demo hoàn tất!
```

---

## 🔍 BƯỚC 9: Verify kết quả trong mongosh

```powershell
docker exec -it temp-mongodb mongosh
```

Trong cửa sổ mongosh chạy từng lệnh:

```javascript
use cinema_db
```

```javascript
// Xem wallet — Nguyễn Văn A phải còn 200,000đ (trừ 300k)
// Trần Thị B phải còn 200,000đ (không đổi vì rollback)
db.users.find({}, { name: 1, wallet: 1 })
```

```javascript
// Phải có đúng 1 booking (scenario 1)
db.bookings.find()
```

```javascript
// Phòng 1 phải có ghế: [A1, A2, B1, C1, C2]
db.screenings.find({}, { screeningRoom: 1, bookedSeats: 1 })
```

```javascript
// Phải có 1 log "committed"
db.transaction_logs.find()
```

Thoát mongosh:
```javascript
exit
```

---

## ❌ XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi: "No host described in new configuration maps to this node"
→ Sai port. Luôn dùng `localhost:27017` (port bên trong container)

### Lỗi: "file not found" khi docker cp
→ Kiểm tra lại đường dẫn bằng `dir mongodb\`
→ Thử dùng `mongodb/scripts/` thay vì `mongodb/`

### Lỗi: "Transaction numbers are only allowed on a replica set"
→ RS chưa init. Quay lại Bước 3

### db.isMaster().ismaster ra `false` mãi
→ Chạy lại rs.initiate() ở Bước 3
→ Đợi thêm 10 giây rồi kiểm tra lại

### Lỗi: "Document failed validation"
→ Đang dùng file JS cũ chưa fix. Dùng file từ output của tôi

---

## 📡 Thông tin kết nối

| Thông số | Giá trị |
|----------|---------|
| Host | localhost |
| Port | 27018 (từ host) |
| Connection String | `mongodb://localhost:27018/?replicaSet=rs0` |
| Database | cinema_db |

