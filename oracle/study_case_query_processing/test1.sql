-- ============================================================
-- TEST 1: Thuật toán JOIN và Tự động Pipelining
-- Bài toán: Lấy mã đơn hàng + tên phim của các đơn hàng đã thanh toán
-- Minh họa: Oracle tự chọn thuật toán JOIN (Nested-Loop / Hash / Sort-Merge)
--           và Pipelining giữa các toán tử trong cây thực thi
-- ============================================================

SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT  CASE STUDY 1: JOIN ALGORITHM & PIPELINING
PROMPT  Query: Don hang da thanh toan -> ten phim
PROMPT ============================================================

-- Bước 1: Chạy query thực tế để xem kết quả
PROMPT
PROMPT --- [KET QUA THUC TE] ---

SELECT dh.MaDonHang, p.TenPhim, dh.TrangThai
FROM DON_HANG dh
JOIN VE_XEM_PHIM v  ON dh.MaDonHang   = v.MaDonHang
JOIN SUAT_CHIEU sc  ON v.MaSuatChieu  = sc.MaSuatChieu
JOIN PHIM p         ON sc.MaPhim      = p.MaPhim
WHERE dh.TrangThai = 'Đã thanh toán'
ORDER BY dh.MaDonHang;

-- Bước 2: Sinh execution plan
PROMPT
PROMPT --- [EXECUTION PLAN - EXPLAIN PLAN] ---
PROMPT Oracle tu dong chon thuat toan JOIN toi uu (Nested-Loop / Hash / Sort-Merge)
PROMPT va Pipeline ket qua giua cac operator ma khong ghi tam ra dia.

EXPLAIN PLAN SET STATEMENT_ID = 'TEST1' FOR
SELECT dh.MaDonHang, p.TenPhim, dh.TrangThai
FROM DON_HANG dh
JOIN VE_XEM_PHIM v  ON dh.MaDonHang   = v.MaDonHang
JOIN SUAT_CHIEU sc  ON v.MaSuatChieu  = sc.MaSuatChieu
JOIN PHIM p         ON sc.MaPhim      = p.MaPhim
WHERE dh.TrangThai = 'Đã thanh toán';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST1',
    format       => 'ALL'   -- ALL: hien thi day du Operation, Cost, Rows, Bytes, Predicate
));

PROMPT
PROMPT --- [PHAN TICH] ---
PROMPT > Operation "NESTED LOOPS" hoac "HASH JOIN": thuat toan JOIN Oracle chon
PROMPT > Operation "TABLE ACCESS FULL" / "INDEX SCAN": cach doc du lieu tung bang
PROMPT > "Predicate Information": cho thay dieu kien loc duoc day xuong sau (Predicate Pushdown)
PROMPT > Khong co "TEMP" trong plan = du lieu duoc Pipeline truc tiep, khong ghi tam ra dia

quit
