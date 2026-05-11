# Khai báo tên container
ORACLE_CONTAINER = ecommerce_oracle
MONGO_CONTAINER  = ecommerce_mongodb

# MongoDB credentials (khớp với docker-compose.yml)
MONGO_USER = admin
MONGO_PASS = AdminPassword123
MONGO_DB   = ecommerce_db
MONGOSH    = mongosh "mongodb://$(MONGO_USER):$(MONGO_PASS)@127.0.0.1:27017/$(MONGO_DB)?authSource=admin"

.PHONY: up down clean logs sql mongo check seed \
        oracle-setup oracle-tests \
        mongo-setup mongo-tests mongo-transaction \
        all-tests

# ============================================================
# 1. Khởi chạy hệ thống (chạy ngầm)
# ============================================================
up:
	docker compose up -d
	@echo "Đang khởi động hệ thống. Gõ 'make logs' để xem tiến trình."

# ============================================================
# 2. Tắt hệ thống
# ============================================================
down:
	docker compose down
	@echo "Đã tắt hệ thống."

# ============================================================
# 3. Tắt và XÓA SẠCH DỮ LIỆU (Reset)
# ============================================================
clean:
	docker compose down -v
	@echo "Đã dọn dẹp sạch sẽ hệ thống và volume dữ liệu."

# ============================================================
# 4. Xem log
# ============================================================
logs:
	docker compose logs -f

# ============================================================
# 5. Mở SQL*Plus Oracle
# ============================================================
sql:
	@echo "Đang truy cập Oracle SQL*Plus..."
	docker exec -it $(ORACLE_CONTAINER) sqlplus dev/dev123@//localhost:1521/FREEPDB1

# ============================================================
# 6. Mở MongoDB Shell
# ============================================================
mongo:
	@echo "Đang truy cập MongoDB Shell..."
	docker exec -it $(MONGO_CONTAINER) $(MONGOSH)

# ============================================================
# 7. Kiểm tra nhanh dữ liệu cả 2 database
# ============================================================
check:
	@echo "======================================="
	@echo " KIỂM TRA DỮ LIỆU MONGODB"
	@echo "======================================="
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) --quiet --eval "\
		console.log('Collections:', db.getCollectionNames().join(', ')); \
		db.getCollectionNames().forEach(c => \
			console.log('  ' + c + ': ' + db[c].countDocuments() + ' docs')); \
	"
	@echo ""
	@echo "======================================="
	@echo " KIỂM TRA DỮ LIỆU ORACLE"
	@echo "======================================="
	@(echo "SET HEADING OFF FEEDBACK OFF PAGESIZE 0"; \
	  echo "SELECT 'Bảng: ' || table_name || ' — ' || TO_CHAR(num_rows) || ' rows'"; \
	  echo "FROM user_tables ORDER BY table_name;"; \
	  echo "EXIT;") | docker exec -i $(ORACLE_CONTAINER) sqlplus -S dev/dev123@//localhost:1521/FREEPDB1
	@echo "======================================="

# ============================================================
# 8. ORACLE — Nạp setup.sql
# ============================================================
oracle-setup:
	@echo "🚀 [Oracle] Nạp setup.sql..."
	@docker cp oracle/setup.sql $(ORACLE_CONTAINER):/tmp/oracle_setup.sql
	@docker exec -i $(ORACLE_CONTAINER) sqlplus dev/dev123@//localhost:1521/FREEPDB1 @/tmp/oracle_setup.sql
	@echo "✅ [Oracle] setup.sql hoàn tất."

# ============================================================
# 9. ORACLE — Chạy test1.sql, test2.sql, test3.sql
# ============================================================
oracle-tests:
	@echo "🧪 [Oracle] Chạy test1.sql..."
	@docker cp oracle/study_case_query_processing/test1.sql $(ORACLE_CONTAINER):/tmp/oracle_test1.sql
	@docker exec -i $(ORACLE_CONTAINER) sqlplus dev/dev123@//localhost:1521/FREEPDB1 @/tmp/oracle_test1.sql
	@echo "🧪 [Oracle] Chạy test2.sql..."
	@docker cp oracle/study_case_query_processing/test2.sql $(ORACLE_CONTAINER):/tmp/oracle_test2.sql
	@docker exec -i $(ORACLE_CONTAINER) sqlplus dev/dev123@//localhost:1521/FREEPDB1 @/tmp/oracle_test2.sql
	@echo "🧪 [Oracle] Chạy test3.sql..."
	@docker cp oracle/study_case_query_processing/test3.sql $(ORACLE_CONTAINER):/tmp/oracle_test3.sql
	@docker exec -i $(ORACLE_CONTAINER) sqlplus dev/dev123@//localhost:1521/FREEPDB1 @/tmp/oracle_test3.sql
	@echo "✅ [Oracle] Tất cả tests hoàn tất."

# ============================================================
# 10. MONGO — Nạp setup.js
# ============================================================
mongo-setup:
	@echo "🚀 [MongoDB] Nạp setup.js..."
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/setup.js
	@echo "✅ [MongoDB] setup.js hoàn tất."

# ============================================================
# 11. MONGO — Chạy test1.js, test2.js, test3.js
# ============================================================
mongo-tests:
	@echo "🧪 [MongoDB] Chạy test1.js..."
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/study_case_query_processing/test1.js
	@echo "🧪 [MongoDB] Chạy test2.js..."
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/study_case_query_processing/test2.js
	@echo "🧪 [MongoDB] Chạy test3.js..."
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/study_case_query_processing/test3.js
	@echo "✅ [MongoDB] Tất cả tests hoàn tất."

# ============================================================
# 12. MONGO — Chạy toàn bộ transaction scripts
# ============================================================
mongo-transaction:
	@echo "🔄 [MongoDB] Chạy transaction scripts..."
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/transaction/scripts/01-init-collections.js
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/transaction/scripts/02-sample-data.js
	@docker exec -i $(MONGO_CONTAINER) $(MONGOSH) < mongo/transaction/scripts/03-transaction-demo.js
	@echo "✅ [MongoDB] Transaction scripts hoàn tất."

# ============================================================
# 13. SEED — Nạp dữ liệu cả 2 DB (setup)
# ============================================================
seed: oracle-setup mongo-setup
	@echo "======================================="
	@echo "✅ Đã nạp xong dữ liệu! Gõ 'make check' để kiểm tra."
	@echo "======================================="

# ============================================================
# 14. ALL-TESTS — Chạy tất cả test files (cả Oracle + Mongo)
# ============================================================
all-tests: oracle-tests mongo-tests
	@echo "======================================="
	@echo "✅ Đã chạy xong tất cả tests!"
	@echo "======================================="

# ============================================================
# 15. ALL — Setup + Tests đầy đủ
# ============================================================
all: seed all-tests mongo-transaction
	@echo "======================================="
	@echo "🎉 Hoàn tất toàn bộ! Setup + Tests + Transactions."
	@echo "======================================="
