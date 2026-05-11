-- ============================================================
-- TEST 2: External Sorting & Giới hạn bộ nhớ (SORT ORDER BY + HASH GROUP BY)
-- Bài toán: Tính điểm đánh giá trung bình từng phim, sắp xếp giảm dần
-- Minh họa: Oracle dùng HASH GROUP BY + SORT ORDER BY
--           Nếu dữ liệu lớn tràn RAM -> tự xả ra TEMP tablespace (External Sort)
-- ============================================================

SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT  CASE STUDY 2: EXTERNAL SORTING & AGGREGATE (GROUP BY + ORDER BY)
PROMPT  Query: Diem danh gia trung binh tung phim, sap xep giam dan
PROMPT ============================================================

-- Bước 1: Kết quả thực tế
PROMPT
PROMPT --- [KET QUA THUC TE] ---

SELECT
    p.MaPhim,
    p.TenPhim,
    COUNT(dg.MaDanhGia)          AS SoDanhGia,
    ROUND(AVG(dg.DiemSo), 2)     AS DiemTrungBinh,
    MAX(dg.DiemSo)               AS DiemCao,
    MIN(dg.DiemSo)               AS DiemThap
FROM PHIM p
JOIN DANH_GIA dg ON p.MaPhim = dg.MaPhim
GROUP BY p.MaPhim, p.TenPhim
ORDER BY DiemTrungBinh DESC;

-- Bước 2: Execution plan
PROMPT
PROMPT --- [EXECUTION PLAN] ---
PROMPT Tim "SORT ORDER BY" va "HASH GROUP BY" trong plan.
PROMPT Neu data lon: Oracle tu dong spill ra TEMP tablespace (External Sort).
PROMPT De xac nhan spill thuc su: query V$SQL_WORKAREA trong luc query dang chay.

EXPLAIN PLAN SET STATEMENT_ID = 'TEST2' FOR
SELECT
    p.MaPhim,
    p.TenPhim,
    COUNT(dg.MaDanhGia)          AS SoDanhGia,
    ROUND(AVG(dg.DiemSo), 2)     AS DiemTrungBinh,
    MAX(dg.DiemSo)               AS DiemCao,
    MIN(dg.DiemSo)               AS DiemThap
FROM PHIM p
JOIN DANH_GIA dg ON p.MaPhim = dg.MaPhim
GROUP BY p.MaPhim, p.TenPhim
ORDER BY DiemTrungBinh DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST2',
    format       => 'ALL'
));

-- Bước 3: So sánh thêm - không có ORDER BY (không cần External Sort)
PROMPT
PROMPT --- [SO SANH: Khong ORDER BY - khong can External Sort] ---
PROMPT

EXPLAIN PLAN SET STATEMENT_ID = 'TEST2B' FOR
SELECT p.MaPhim, COUNT(dg.MaDanhGia), AVG(dg.DiemSo)
FROM PHIM p
JOIN DANH_GIA dg ON p.MaPhim = dg.MaPhim
GROUP BY p.MaPhim;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(
    statement_id => 'TEST2B',
    format       => 'TYPICAL'
));

PROMPT
PROMPT --- [PHAN TICH] ---
PROMPT > "HASH GROUP BY": Oracle dung bang bam de gom nhom -> hieu qua hon SORT GROUP BY
PROMPT > "SORT ORDER BY": bat buoc phai sort -> ton kem nhat trong plan
PROMPT > Neu thay "TEMP" -> data da tran RAM, Oracle dang dung External Sort
PROMPT > MongoDB bi loi neu sort > 100MB va khong set allowDiskUse:true

quit