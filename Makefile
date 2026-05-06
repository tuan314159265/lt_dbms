# Khai báo tên container
ORACLE_CONTAINER = ecommerce_oracle
MONGO_CONTAINER = ecommerce_mongodb

.PHONY: up down clean logs sql mongo check

# 1. Khởi chạy hệ thống (chạy ngầm)
up:
	docker compose up -d
	@echo "Đang khởi động hệ thống. Gõ 'make logs' để xem tiến trình khởi tạo dữ liệu."

# 2. Tắt hệ thống
down:
	docker compose down
	@echo "Đã tắt hệ thống."

# 3. Tắt và XÓA SẠCH DỮ LIỆU (Reset)
clean:
	docker compose down -v
	@echo "Đã dọn dẹp sạch sẽ hệ thống và volume dữ liệu."

# 4. Xem log 
logs:
	docker compose logs -f

# 5. MỞ GIAO DIỆN LỆNH ORACLE SQL
sql:
	@echo "Đang truy cập Oracle SQL*Plus..."
	docker exec -it $(ORACLE_CONTAINER) sqlplus SYSTEM/SysPassword123@FREEPDB1

# 6. MỞ GIAO DIỆN LỆNH MONGODB
mongo:
	@echo "Đang truy cập MongoDB Shell..."
	docker exec -it $(MONGO_CONTAINER) mongosh ecommerce_db

# 7. KIỂM TRA NHANH DỮ LIỆU CỦA CẢ 2 DATABASE
check:
	@echo "======================================="
	@echo " KIỂM TRA DỮ LIỆU MONGODB"
	@echo "======================================="
	@docker exec -i $(MONGO_CONTAINER) mongosh ecommerce_db --quiet --eval "\
		console.log('Tổng số Users:    ', db.users.countDocuments()); \
		console.log('Tổng số Products: ', db.products.countDocuments()); \
		console.log('Tổng số Orders:   ', db.orders.countDocuments()); \
		console.log('Tổng số Reviews:  ', db.reviews.countDocuments()); \
	"
	@echo ""
	@echo "======================================="
	@echo " KIỂM TRA DỮ LIỆU ORACLE SQL"
	@echo "======================================="
	@(echo "SET HEADING OFF"; \
	echo "SET FEEDBACK OFF"; \
	echo "SELECT 'Tổng số Users:    ' || COUNT(*) FROM USERS;"; \
	echo "SELECT 'Tổng số Products: ' || COUNT(*) FROM PRODUCT;"; \
	echo "SELECT 'Tổng số Orders:   ' || COUNT(*) FROM ORDERS;"; \
	echo "SELECT 'Tổng số Reviews:  ' || COUNT(*) FROM REVIEW;"; \
	echo "EXIT;") | docker exec -i $(ORACLE_CONTAINER) sqlplus -S SYSTEM/SysPassword123@FREEPDB1
	@echo "======================================="

# 8. ÉP NẠP DỮ LIỆU BẰNG TAY (Chắc chắn thành công 100%)
seed:
	@echo "======================================="
	@echo "🚀 ĐANG NẠP DỮ LIỆU VÀO MONGODB..."
	@docker exec -i $(MONGO_CONTAINER) mongosh ecommerce_db < ./mongo/setup.js
	@echo "🚀 ĐANG NẠP DỮ LIỆU VÀO ORACLE SQL..."
	@docker exec -i $(ORACLE_CONTAINER) sqlplus SYSTEM/SysPassword123@FREEPDB1 < ./oracle/setup.sql
	@echo "======================================="
	@echo "✅ ĐÃ NẠP XONG! Hãy gõ 'make check' để xem thành quả."