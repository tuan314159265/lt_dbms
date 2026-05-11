-- ============================================================
-- TEST 3: Semantic Optimization - Table Elimination
-- Bài toán: Lấy MaDonHang + MaNguoiDung của đơn hàng "Chờ thanh toán"
-- Minh họa: Dù SQL viết JOIN với KHACH_HANG, CBO suy luận từ FK
--           và tự loại bỏ bảng KHACH_HANG khỏi plan (Table Elimination)
-- ============================================================

SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT  CASE STUDY 3: SEMANTIC OPTIMIZATION - TABLE ELIMINATION
PROMPT  Oracle dung rang buoc FK de loai bo bang JOIN thua
PROMPT ============================================================

-- Bước 1: Kết quả thực tế
PROMPT
PROMPT --- [KET QUA THUC TE] ---

SELECT dh.MaDonHang, kh.MaNguoiDung, dh.TrangThai, dh.TongTien
FROM DON_HANG dh
JOIN KHACH_HANG kh ON dh.MaNguoiDung_KH = kh.MaNguoiDung
WHERE dh.TrangThai = 'Chờ thanh toán';

-- Bước 2: Plan có JOIN KHACH_HANG - quan sát xem Oracle có loại bỏ không
PROMPT
PROMPT --- [EXECUTION PLAN: JOIN voi KHACH_HANG] ---
PROMPT Ky vong: Oracle phat hien MaNguoiDung_KH la FK -> moi gia tri deu co ban ghi KHACH_HANG
PROMPT Ket qua: KHACH_HANG bi loai khoi plan (Table Elimination), chi scan DON_HANG

EXPLAIN PLAN SET STATEMENT_ID = 'TEST3A' FOR
SELECT dh.MaDonHang, kh.MaNguoiDung, dh.TrangThai
FROM DON_HANG dh
JOIN KHACH_HANG kh ON dh.MaNguoiDung_KH = kh.MaNguoiDung
WHERE dh.TrangThai = 'Chờ thanh toán';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST3A',
    format       => 'ALL'
));

-- Bước 3: So sánh - chỉ query DON_HANG (không JOIN) - plan phải giống hệt
PROMPT
PROMPT --- [SO SANH: Chi query DON_HANG, khong JOIN] ---
PROMPT Neu plan giong TEST3A -> chung minh Table Elimination da xay ra

EXPLAIN PLAN SET STATEMENT_ID = 'TEST3B' FOR
SELECT dh.MaDonHang, dh.MaNguoiDung_KH, dh.TrangThai
FROM DON_HANG dh
WHERE dh.TrangThai = 'Chờ thanh toán';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST3B',
    format       => 'ALL'
));

-- Bước 4: Trường hợp KHÔNG bị elimination - khi cần cột từ bảng JOIN
PROMPT
PROMPT --- [NGUOC LAI: Can cot tu KHACH_HANG -> KHONG the Eliminate] ---
PROMPT Khi SELECT lay cot khong co trong DON_HANG (VD: LoaiThanhVien)
PROMPT Oracle buoc phai JOIN thuc su -> Table Elimination KHONG xay ra

EXPLAIN PLAN SET STATEMENT_ID = 'TEST3C' FOR
SELECT dh.MaDonHang, kh.LoaiThanhVien, dh.TrangThai
FROM DON_HANG dh
JOIN KHACH_HANG kh ON dh.MaNguoiDung_KH = kh.MaNguoiDung
WHERE dh.TrangThai = 'Chờ thanh toán';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST3C',
    format       => 'ALL'
));

PROMPT
PROMPT --- [PHAN TICH SO SANH] ---
PROMPT > TEST3A = TEST3B (cung plan): chung minh Table Elimination thanh cong
PROMPT > TEST3C khac (them KHACH_HANG): Oracle buoc phai JOIN de lay LoaiThanhVien
PROMPT > MongoDB khong co co che nay - $lookup van chay mac du khong can du lieu tu collection do

quit
