#!/usr/bin/env bash
# =============================================================
# SCRIPT THUYET TRINH: Query Processing & Optimization
# So sanh Oracle (RDBMS) vs MongoDB (NoSQL)
# Chay: bash present.sh
# =============================================================

ORACLE_CONTAINER="ecommerce_oracle"
MONGO_CONTAINER="ecommerce_mongodb"
ORACLE_DSN="dev/dev123@//localhost:1521/FREEPDB1"
MONGOSH='mongosh "mongodb://admin:AdminPassword123@127.0.0.1:27017/ecommerce_db?authSource=admin" --quiet'

# ── màu sắc ──────────────────────────────────────────────────
BOLD='\033[1m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

divider() { echo -e "${CYAN}══════════════════════════════════════════════════════════════${RESET}"; }
section() { echo -e "\n${YELLOW}▶ $1${RESET}"; }
subsection() { echo -e "\n${BLUE}  ── $1${RESET}"; }
note() { echo -e "${GREEN}  ✔ $1${RESET}"; }
warn() { echo -e "${MAGENTA}  ℹ $1${RESET}"; }

run_oracle() {
    docker exec -i "$ORACLE_CONTAINER" sqlplus -S "$ORACLE_DSN" <<EOF
SET DEFINE OFF
SET LINESIZE 160
SET PAGESIZE 50
SET FEEDBACK OFF
SET VERIFY OFF
SET ECHO OFF
$1
EXIT;
EOF
}

MONGO_TMP="/tmp/_present_mongo.js"

run_mongo() {
    printf '%s' "$1" | docker exec -i "$MONGO_CONTAINER" \
        mongosh 'mongodb://admin:AdminPassword123@127.0.0.1:27017/ecommerce_db?authSource=admin' \
        --quiet
}

pause() {
    echo ""
    read -rp "$(echo -e ${BOLD}"  [ Enter để tiếp tục... ]"${RESET})" _
    echo ""
}

# =============================================================
clear
divider
echo -e "${BOLD}${CYAN}"
echo "   XỬ LÝ VÀ TỐI ƯU HÓA TRUY VẤN"
echo "   Oracle Database (RDBMS)  vs  MongoDB (NoSQL)"
echo -e "${RESET}"
divider
echo ""
echo -e "  Nội dung demo gồm 3 Case Study:"
echo -e "  ${BOLD}1.${RESET} Thuật toán JOIN & Pipelining"
echo -e "  ${BOLD}2.${RESET} External Sorting & Giới hạn bộ nhớ 100MB"
echo -e "  ${BOLD}3.${RESET} Semantic Optimization – Table Elimination"
echo ""
pause

# =============================================================
# CASE STUDY 1: JOIN ALGORITHM & PIPELINING
# =============================================================
clear
divider
echo -e "${BOLD}  CASE STUDY 1: THUẬT TOÁN JOIN & PIPELINING${RESET}"
divider
echo ""
echo -e "  ${BOLD}Bài toán:${RESET} Lấy mã đơn hàng + tên phim của đơn hàng đã thanh toán"
echo ""
echo -e "  ${BOLD}Oracle:${RESET} JOIN 3 bảng chuẩn hóa (DON_HANG → VE_XEM_PHIM → SUAT_CHIEU → PHIM)"
echo -e "          CBO tự chọn thuật toán JOIN tối ưu, Pipeline kết quả không ghi tạm ra đĩa"
echo ""
echo -e "  ${BOLD}MongoDB:${RESET} Dữ liệu nhúng sẵn (Embedding) → bypass JOIN hoàn toàn"
echo ""

subsection "ORACLE — Execution Plan (4-table JOIN)"
warn "Quan sát: HASH JOIN + NESTED LOOPS + INDEX RANGE SCAN + Predicate Pushdown"
echo ""

run_oracle "
SET SERVEROUTPUT ON
EXPLAIN PLAN SET STATEMENT_ID = 'CS1' FOR
SELECT dh.MaDonHang, p.TenPhim, dh.TrangThai
FROM DON_HANG dh
JOIN VE_XEM_PHIM v  ON dh.MaDonHang  = v.MaDonHang
JOIN SUAT_CHIEU sc  ON v.MaSuatChieu = sc.MaSuatChieu
JOIN PHIM p         ON sc.MaPhim     = p.MaPhim
WHERE dh.TrangThai = 'Đã thanh toán'
ORDER BY dh.MaDonHang;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS1', format=>'TYPICAL'));
"

echo ""
note "HASH JOIN ở gốc cây = Oracle kết hợp 2 nhánh kết quả bằng bảng băm (hiệu quả cho bảng lớn)"
note "NESTED LOOPS bên trong = duyệt từng hàng PHIM → dò SUAT_CHIEU qua index"
note "Predicate filter('Đã thanh toán') được đẩy xuống tận bảng DON_HANG (Pushdown)"
note "Không có TEMP trong plan = toàn bộ kết quả được Pipeline, không ghi tạm ra đĩa"
pause

subsection "MONGODB — Kết quả thực tế (không cần JOIN nhờ Embedding)"
warn "Quan sát: chỉ IXSCAN + FETCH trên 1 collection, totalKeysExamined = nReturned"
echo ""

run_mongo "
var res = db.orders.find({status:'delivered'},{_id:1,'items.product_name':1,status:1}).explain('executionStats');
print('--- Winning Plan ---');
print('Stage:', res.queryPlanner.winningPlan.stage);
if(res.queryPlanner.winningPlan.inputStage)
  print('Input stage:', res.queryPlanner.winningPlan.inputStage.stage,
        '| index:', res.queryPlanner.winningPlan.inputStage.indexName || 'N/A');
print('--- Execution Stats ---');
print('nReturned          :', res.executionStats.nReturned);
print('totalKeysExamined  :', res.executionStats.totalKeysExamined);
print('totalDocsExamined  :', res.executionStats.totalDocsExamined);
print('executionTimeMillis:', res.executionStats.executionTimeMillis, 'ms');
"

echo ""
note "MongoDB không cần JOIN vì items được nhúng thẳng vào document orders"
note "Hit-rate 100%: totalKeysExamined = nReturned → không quét thừa 1 document nào"
warn "Đánh đổi: cập nhật thông tin sản phẩm phải update nhiều document (denormalization)"
pause

# =============================================================
# CASE STUDY 2: EXTERNAL SORTING & MEMORY LIMIT
# =============================================================
clear
divider
echo -e "${BOLD}  CASE STUDY 2: EXTERNAL SORTING & GIỚI HẠN BỘ NHỚ 100MB${RESET}"
divider
echo ""
echo -e "  ${BOLD}Bài toán:${RESET} Tính điểm đánh giá trung bình từng phim, sắp xếp giảm dần"
echo ""
echo -e "  ${BOLD}Oracle:${RESET}  HASH GROUP BY + SORT ORDER BY → nếu tràn RAM tự xả ra TEMP tablespace"
echo -e "  ${BOLD}MongoDB:${RESET} Giới hạn cứng 100MB/stage → lỗi nếu không bật allowDiskUse:true"
echo ""

subsection "ORACLE — HASH GROUP BY + SORT ORDER BY"
warn "Quan sát: SORT ORDER BY (Id 1) nằm ngoài cùng = tốn kém nhất; HASH GROUP BY bên trong"
echo ""

run_oracle "
EXPLAIN PLAN SET STATEMENT_ID = 'CS2A' FOR
SELECT p.TenPhim,
       COUNT(dg.MaDanhGia)      AS SoDanhGia,
       ROUND(AVG(dg.DiemSo),2)  AS DiemTB
FROM PHIM p JOIN DANH_GIA dg ON p.MaPhim = dg.MaPhim
GROUP BY p.MaPhim, p.TenPhim
ORDER BY DiemTB DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS2A', format=>'TYPICAL'));
"

echo ""
note "SORT ORDER BY nằm ở gốc = bắt buộc sort toàn bộ tập kết quả → tốn nhất"
note "Nếu data tràn PGA → Oracle tự xả ra TEMP tablespace (External Sort), không lỗi"
warn "Kiểm tra spill thực tế: SELECT * FROM V\$SQL_WORKAREA WHERE OPERATION_TYPE='SORT'"
echo ""

subsection "ORACLE — So sánh: Bỏ ORDER BY → SORT ORDER BY biến mất"
echo ""
run_oracle "
EXPLAIN PLAN SET STATEMENT_ID = 'CS2B' FOR
SELECT p.MaPhim, COUNT(dg.MaDanhGia), ROUND(AVG(dg.DiemSo),2)
FROM PHIM p JOIN DANH_GIA dg ON p.MaPhim = dg.MaPhim
GROUP BY p.MaPhim;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS2B', format=>'TYPICAL'));
"
note "Không có SORT ORDER BY → plan rẻ hơn, chỉ còn HASH GROUP BY"
pause

subsection "MONGODB — Demo giới hạn 100MB (allowDiskUse: false)"
warn "Quan sát: lỗi tường minh khi sort > 100MB mà không cho phép spill to disk"
echo ""

run_mongo "
print('--- Test sort với allowDiskUse: false ---');
try {
  db.reviews.aggregate([
    { \$sort: { 'rating.score': -1 } }
  ], { allowDiskUse: false }).toArray();
  print('OK - data < 100MB, khong can spill');
} catch(e) {
  print('LOI (nhu ky vong voi data lon):');
  print(e.message);
}
print('');
print('--- Test sort với allowDiskUse: true (an toan) ---');
var r = db.reviews.aggregate([
  { \$group: { _id: '\$product_id', avgScore: { \$avg: '\$rating.score' }, total: { \$sum: 1 } } },
  { \$sort: { avgScore: -1 } },
  { \$limit: 5 }
], { allowDiskUse: true }).toArray();
r.forEach(x => print('product:', x._id, '| avg:', x.avgScore, '| reviews:', x.total));
"

echo ""
note "allowDiskUse:false → lỗi ngay khi data lớn hơn 100MB"
note "allowDiskUse:true → MongoDB 6.0+ tự động spill to disk, tương tự Oracle TEMP"
warn "Khác Oracle: MongoDB giới hạn CỨNG per-stage, Oracle giới hạn MỀM theo PGA"
pause

# =============================================================
# CASE STUDY 3: SEMANTIC OPTIMIZATION - TABLE ELIMINATION
# =============================================================
clear
divider
echo -e "${BOLD}  CASE STUDY 3: SEMANTIC OPTIMIZATION — TABLE ELIMINATION${RESET}"
divider
echo ""
echo -e "  ${BOLD}Bài toán:${RESET} Lấy MaDonHang + MaNguoiDung của đơn hàng 'Chờ thanh toán'"
echo ""
echo -e "  ${BOLD}Oracle:${RESET}  CBO đọc ràng buộc FK → suy luận JOIN là thừa → loại bỏ bảng khỏi plan"
echo -e "  ${BOLD}MongoDB:${RESET} Schema-less, không có FK → \$lookup luôn thực thi dù không cần"
echo ""

subsection "ORACLE — Plan A: JOIN với KHACH_HANG (có FK)"
warn "Kỳ vọng: KHACH_HANG BIẾN MẤT khỏi plan dù SQL có JOIN"
echo ""

run_oracle "
EXPLAIN PLAN SET STATEMENT_ID = 'CS3A' FOR
SELECT dh.MaDonHang, kh.MaNguoiDung, dh.TrangThai
FROM DON_HANG dh
JOIN KHACH_HANG kh ON dh.MaNguoiDung_KH = kh.MaNguoiDung
WHERE dh.TrangThai = 'Chờ thanh toán';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS3A', format=>'TYPICAL'));
"

echo ""

subsection "ORACLE — Plan B: Chỉ query DON_HANG, KHÔNG JOIN"
warn "Kỳ vọng: Plan hash value GIỐNG HỆT Plan A → chứng minh elimination"
echo ""

run_oracle "
EXPLAIN PLAN SET STATEMENT_ID = 'CS3B' FOR
SELECT dh.MaDonHang, dh.MaNguoiDung_KH, dh.TrangThai
FROM DON_HANG dh
WHERE dh.TrangThai = 'Chờ thanh toán';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS3B', format=>'TYPICAL'));
"

echo ""
note "Plan hash value của CS3A = CS3B → Oracle đã loại bỏ KHACH_HANG hoàn toàn"
note "Tiết kiệm 50% I/O đọc đĩa so với JOIN thực sự"
echo ""

subsection "ORACLE — Plan C: Cần cột từ KHACH_HANG → KHÔNG thể Eliminate"
warn "Quan sát: KHACH_HANG XUẤT HIỆN trở lại trong plan khi cần LoaiThanhVien"
echo ""

run_oracle "
EXPLAIN PLAN SET STATEMENT_ID = 'CS3C' FOR
SELECT dh.MaDonHang, kh.LoaiThanhVien, dh.TrangThai
FROM DON_HANG dh
JOIN KHACH_HANG kh ON dh.MaNguoiDung_KH = kh.MaNguoiDung
WHERE dh.TrangThai = 'Chờ thanh toán';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(statement_id=>'CS3C', format=>'TYPICAL'));
"

echo ""
note "KHACH_HANG xuất hiện trở lại → Oracle buộc phải JOIN để lấy LoaiThanhVien"
warn "MongoDB: \$lookup luôn chạy dù chỉ cần trường có sẵn trong orders"
pause

# =============================================================
# TỔNG KẾT
# =============================================================
clear
divider
echo -e "${BOLD}${CYAN}  TỔNG KẾT SO SÁNH${RESET}"
divider
echo ""
printf "  %-28s %-30s %-30s\n" "Tiêu chí" "Oracle (RDBMS)" "MongoDB (NoSQL)"
echo "  ──────────────────────────────────────────────────────────────────────────────────"
printf "  %-28s %-30s %-30s\n" "Nền tảng lý thuyết" "SQL → Relational Algebra" "MQL → AST / Pipeline"
printf "  %-28s %-30s %-30s\n" "Thuật toán JOIN" "Nested-Loop/Hash/Sort-Merge" "Embedding + \$lookup"
printf "  %-28s %-30s %-30s\n" "Quản lý bộ nhớ sort" "PGA → TEMP (không giới hạn)" "100MB/stage (cứng)"
printf "  %-28s %-30s %-30s\n" "Semantic Optimization" "Table Elimination (FK)" "Không hỗ trợ"
printf "  %-28s %-30s %-30s\n" "Ra quyết định plan" "CBO + Statistics" "Plan Racing thực nghiệm"
printf "  %-28s %-30s %-30s\n" "Thích ứng runtime" "Adaptive Plans" "Plan Cache"
echo ""
divider
echo ""
note "Oracle mạnh hơn: complex multi-table JOIN, semantic optimization, dữ liệu chuẩn hóa"
note "MongoDB mạnh hơn: single-collection lookup, schema linh hoạt, horizontal scale"
echo ""
divider
echo -e "${BOLD}  Demo hoàn tất.${RESET}"
divider
echo ""