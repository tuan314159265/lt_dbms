-- Active: 1775405888174@@127.0.0.1@5432
-- ============================================================================
-- ORACLE DATABASE: CREATE USER AND GRANT PRIVILEGES
-- Cinema Database Setup
-- Version: 1.0
-- ============================================================================

-- ============================================================================
-- 1. CREATE USER 'dev' IF NOT EXISTS
-- ============================================================================

BEGIN
  DECLARE
    user_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(user_exists, -1920);
  BEGIN
    EXECUTE IMMEDIATE 'CREATE USER dev IDENTIFIED BY dev123';
    DBMS_OUTPUT.PUT_LINE('User dev created successfully');
  EXCEPTION
    WHEN user_exists THEN
      DBMS_OUTPUT.PUT_LINE('User dev already exists');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
  END;
END;
/

-- ============================================================================
-- 2. GRANT BASIC PRIVILEGES TO USER 'dev'
-- ============================================================================

GRANT CREATE SESSION TO dev;
GRANT CREATE TABLE TO dev;
GRANT CREATE VIEW TO dev;
GRANT CREATE SEQUENCE TO dev;
GRANT CREATE PROCEDURE TO dev;
GRANT CREATE FUNCTION TO dev;
GRANT CREATE TRIGGER TO dev;
GRANT EXECUTE ON DBMS_LOB TO dev;

-- ============================================================================
-- 3. GRANT UNLIMITED QUOTA ON TABLESPACE
-- ============================================================================

ALTER USER dev QUOTA UNLIMITED ON SYSTEM;
ALTER USER dev QUOTA UNLIMITED ON USERS;

-- ============================================================================
-- 4. GRANT SYSTEM PRIVILEGES FOR SYSDBA OPERATIONS
-- ============================================================================

GRANT SYSDBA TO dev;

-- ============================================================================
-- 5. VERIFY USER CREATION
-- ============================================================================

SELECT username, account_status FROM dba_users WHERE username = 'DEV';

COMMIT;

-- ============================================================================
-- Success Message
-- ============================================================================
BEGIN
  DBMS_OUTPUT.PUT_LINE('✅ User DEV created and privileges granted successfully!');
  DBMS_OUTPUT.PUT_LINE('Connection Details:');
  DBMS_OUTPUT.PUT_LINE('  Username: dev');
  DBMS_OUTPUT.PUT_LINE('  Password: dev123');
  DBMS_OUTPUT.PUT_LINE('  Service: XEPDB1');
END;
/
-- ============================================================================
-- ORACLE DATABASE MIGRATION: Cinema Database
-- FROM: MySQL TO Oracle Database
-- Version: 1.0
-- ============================================================================

-- 1. Cấu hình môi trường
SET DEFINE OFF
SET ECHO OFF          -- Không nhắc lại câu lệnh đang chạy
SET FEEDBACK OFF      -- Không hiện thông báo "1 row created" hoặc "Table created"
SET TERMOUT ON        -- Vẫn hiện kết quả ra màn hình
SET VERIFY OFF        -- Không hiện chi tiết thay đổi biến &
SET SERVEROUTPUT ON   -- Bật để hiện thông báo từ DBMS_OUTPUT
-- kiểm tra bảng và index trước khi xóa


DECLARE
  v_count_tables NUMBER := 0;
  v_count_seq    NUMBER := 0;
BEGIN
  -- Đếm số bảng trước khi xóa
  SELECT COUNT(*) INTO v_count_tables FROM user_tables;

  -- Xóa toàn bộ Bảng
  FOR rec IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;

  -- Đếm sequence trước khi xóa
  SELECT COUNT(*) INTO v_count_seq FROM user_sequences;

  -- Xóa toàn bộ Sequence
  FOR rec IN (SELECT sequence_name FROM user_sequences) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
  END LOOP;

  -- In thông báo
  IF v_count_tables = 0 AND v_count_seq = 0 THEN
    DBMS_OUTPUT.PUT_LINE('⚠️ Không có bảng hoặc sequence nào để xóa.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('✅ Đã xóa ' || v_count_tables || ' bảng và ' || v_count_seq || ' sequence.');
  END IF;

END;
/
-- 2. Xóa toàn bộ các đối tượng cũ để tránh lỗi "Name already used"
BEGIN
  -- Xóa toàn bộ Bảng (Tables)
  FOR rec IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
  
  -- Xóa toàn bộ Sequence
  FOR rec IN (SELECT sequence_name FROM user_sequences) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
  END LOOP;
END;
/

-- 3. Dọn dẹp thùng rác để giải phóng bộ nhớ
PURGE RECYCLEBIN;


-- Create tablespace for sequences
CREATE SEQUENCE seq_ma_nguoi_dung START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ma_phim START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ma_phong START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ma_ve START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ma_don_hang START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ma_thanh_toan START WITH 1000 INCREMENT BY 1;

-- ============================================================================
-- TABLE CREATION - ORACLE SYNTAX
-- NGUYÊN TẮC: Bảng Cha (không FK) → Bảng Con (có FK trỏ về Cha)
-- ============================================================================

-- ============================================================================
-- BẢNG CHA (Không có Foreign Key)
-- ============================================================================

-- 1. RẠP CHIẾU PHIM
CREATE TABLE RAP_CHIEU_PHIM (
    MaRapPhim  VARCHAR2(50) PRIMARY KEY,
    Ten        VARCHAR2(50) NOT NULL,
    ThanhPho   VARCHAR2(25) NOT NULL,
    DiaChi     VARCHAR2(50) NOT NULL,
    SDT        VARCHAR2(15) NOT NULL,
    Email      VARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT chk_rap_sdt CHECK (REGEXP_LIKE(SDT, '^[0-9]+$')),
    CONSTRAINT chk_rap_email CHECK (REGEXP_LIKE(Email, '^[^@\s]+@[^@\s]+\.[^@\s]+$'))
);

-- 2. PHIM
CREATE TABLE PHIM (
    MaPhim VARCHAR2(50) PRIMARY KEY,
    TenPhim VARCHAR2(500) NOT NULL,
    ThoiLuong INT NOT NULL,
    NgonNgu VARCHAR2(50) NOT NULL,
    QuocGia VARCHAR2(50) NOT NULL,
    DaoDien VARCHAR2(100),
    DienVienChinh VARCHAR2(500),
    NgayKhoiChieu DATE NOT NULL,
    MoTaNoiDung CLOB,
    DoTuoi INT NOT NULL,
    ChuDePhim VARCHAR2(100),
    Anh VARCHAR2(500),
    CONSTRAINT chk_phim_thoiluong CHECK (ThoiLuong > 0),
    CONSTRAINT chk_phim_dotuoi CHECK (DoTuoi >= 0)
);

-- 3. CHUONG_TRINH_KHUYEN_MAI
CREATE TABLE CHUONG_TRINH_KHUYEN_MAI (
    MaKhuyenMai VARCHAR2(50) PRIMARY KEY,
    TenChuongTrinh VARCHAR2(500) NOT NULL,
    DieuKien VARCHAR2(250),
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    MucGiam DECIMAL(18,2) NOT NULL,
    CONSTRAINT chk_km_dates CHECK (NgayKetThuc >= NgayBatDau),
    CONSTRAINT chk_km_mucgiam CHECK (MucGiam >= 0)
);

-- 4. TAI_KHOAN
CREATE TABLE TAI_KHOAN (
    MaNguoiDung VARCHAR2(50) PRIMARY KEY,
    HoTen VARCHAR2(50) NOT NULL,
    DiaChi VARCHAR2(500),
    SDT VARCHAR2(15),
    GioiTinh CHAR(1),
    Email VARCHAR2(50) NOT NULL UNIQUE,
    MatKhau VARCHAR2(255) NOT NULL,
    VaiTro VARCHAR2(50) DEFAULT 'Khach' NOT NULL,
    CONSTRAINT chk_tk_gioitinh CHECK (GioiTinh IN ('M','F','O') OR GioiTinh IS NULL),
    CONSTRAINT chk_tk_sdt CHECK (NOT REGEXP_LIKE(SDT, '[^0-9]', 'i') OR SDT IS NULL),
    CONSTRAINT chk_tk_vaitro CHECK (VaiTro IN ('Khach', 'Admin'))
);

-- 5. MAT_HANG
CREATE TABLE MAT_HANG (
    MaHang VARCHAR2(50) PRIMARY KEY,
    TenHang VARCHAR2(500) NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL,
    SoLuongTon INT NOT NULL,
    MoTa VARCHAR2(500),
    LoaiHang VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_mh_dongia CHECK (DonGia >= 0),
    CONSTRAINT chk_mh_soluong CHECK (SoLuongTon >= 0),
    CONSTRAINT chk_mh_loai CHECK (LoaiHang IN ('DO_AN','QUA_LUU_NIEM'))
);

-- ============================================================================
-- BẢNG CON (Có Foreign Key trỏ về Bảng Cha)
-- ============================================================================

-- 6. PHONG_CHIEU (FK → RAP_CHIEU_PHIM)
CREATE TABLE PHONG_CHIEU (
    MaPhong   VARCHAR2(50) PRIMARY KEY,
    MaRapPhim VARCHAR2(50) NOT NULL,
    Ten       VARCHAR2(50) NOT NULL,
    Loai      VARCHAR2(50) NOT NULL,
    SucChua   INT NOT NULL,
    SoGhe     INT NOT NULL,
    CONSTRAINT chk_phong_suchua CHECK (SucChua > 0),
    CONSTRAINT chk_phong_soghe CHECK (SoGhe > 0),
    CONSTRAINT fk_phong_rap FOREIGN KEY (MaRapPhim) REFERENCES RAP_CHIEU_PHIM(MaRapPhim)
);

-- 7. GHE (FK → PHONG_CHIEU)
CREATE TABLE GHE (
    MaPhong VARCHAR2(50) NOT NULL,
    HangGhe VARCHAR2(10) NOT NULL,
    SoGhe INT NOT NULL,
    LoaiGhe VARCHAR2(15) NOT NULL,
    CONSTRAINT pk_ghe PRIMARY KEY (MaPhong, HangGhe, SoGhe),
    CONSTRAINT chk_ghe_soghe CHECK (SoGhe > 0),
    CONSTRAINT fk_ghe_phong FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong)
);

-- 8. THE_LOAI_PHIM (FK → PHIM)
CREATE TABLE THE_LOAI_PHIM (
    MaPhim VARCHAR2(50) NOT NULL,
    TheLoai VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_theloai PRIMARY KEY (MaPhim, TheLoai),
    CONSTRAINT fk_theloai_phim FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim)
);

-- 9. KHACH_HANG (FK → TAI_KHOAN)
CREATE TABLE KHACH_HANG (
    MaNguoiDung VARCHAR2(50) PRIMARY KEY,
    LoaiThanhVien VARCHAR2(50) NOT NULL,
    DiemTichLuy INT DEFAULT 0,
    CONSTRAINT chk_kh_diemtich CHECK (DiemTichLuy >= 0),
    CONSTRAINT chk_kh_loaitv CHECK (LoaiThanhVien IN ('Bronze','Silver','Gold','Platinum')),
    CONSTRAINT fk_kh_tk FOREIGN KEY (MaNguoiDung) REFERENCES TAI_KHOAN(MaNguoiDung)
);

-- 10. QUAN_TRI_VIEN (FK → TAI_KHOAN)
CREATE TABLE QUAN_TRI_VIEN (
    MaNguoiDung VARCHAR2(50) PRIMARY KEY,
    NgayBatDauLam DATE NOT NULL,
    Luong DECIMAL(18,2) NOT NULL,
    ChucVu VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_qtv_luong CHECK (Luong > 0),
    CONSTRAINT fk_qtv_tk FOREIGN KEY (MaNguoiDung) REFERENCES TAI_KHOAN(MaNguoiDung)
);

-- 11. CA_LAM_VIEC (FK → QUAN_TRI_VIEN)
CREATE TABLE CA_LAM_VIEC (
    MaCa VARCHAR2(50) PRIMARY KEY,
    MaNguoiDung VARCHAR2(50) NOT NULL,
    CaLamViec VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_ca_qtv FOREIGN KEY (MaNguoiDung) REFERENCES QUAN_TRI_VIEN(MaNguoiDung)
);

-- 12. DON_HANG (FK → KHACH_HANG)
CREATE TABLE DON_HANG (
    MaDonHang VARCHAR2(50) PRIMARY KEY,
    MaNguoiDung_KH VARCHAR2(50) NOT NULL,
    PhuongThuc VARCHAR2(50) NOT NULL,
    ThoiGianDat TIMESTAMP DEFAULT SYSDATE NOT NULL,
    TongTien DECIMAL(18,2) NOT NULL,
    TrangThai VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_dh_tongtien CHECK (TongTien >= 0),
    CONSTRAINT chk_dh_trangthai CHECK (TrangThai IN ('Chờ thanh toán','Đã thanh toán','Hủy')),
    CONSTRAINT fk_dh_kh FOREIGN KEY (MaNguoiDung_KH) REFERENCES KHACH_HANG(MaNguoiDung)
);

-- 13. GOM (FK → DON_HANG, MAT_HANG)
CREATE TABLE GOM (
    MaDonHang VARCHAR2(50) NOT NULL,
    MaHang VARCHAR2(50) NOT NULL,
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL,
    CONSTRAINT pk_gom PRIMARY KEY (MaDonHang, MaHang),
    CONSTRAINT chk_gom_soluong CHECK (SoLuong > 0),
    CONSTRAINT chk_gom_dongia CHECK (DonGia >= 0),
    CONSTRAINT fk_gom_dh FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
    CONSTRAINT fk_gom_mh FOREIGN KEY (MaHang) REFERENCES MAT_HANG(MaHang)
);

-- 14. THANH_TOAN (FK → DON_HANG)
CREATE TABLE THANH_TOAN (
    MaThanhToan VARCHAR2(50) PRIMARY KEY,
    MaDonHang VARCHAR2(50) NOT NULL UNIQUE,
    NgayThanhToan TIMESTAMP DEFAULT SYSDATE NOT NULL,
    PhuongThuc VARCHAR2(50) NOT NULL,
    TrangThai VARCHAR2(50) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    CONSTRAINT chk_tt_sotien CHECK (SoTien >= 0),
    CONSTRAINT chk_tt_trangthai CHECK (TrangThai IN ('Đang xử lý','Đã thanh toán','Thất bại')),
    CONSTRAINT fk_tt_dh FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang)
);

-- 15. TRINH_CHIEU (FK → RAP_CHIEU_PHIM, PHIM)
CREATE TABLE TRINH_CHIEU (
    MaRapPhim VARCHAR2(50) NOT NULL,
    MaPhim VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_trinhchieu PRIMARY KEY (MaRapPhim, MaPhim),
    CONSTRAINT fk_tc_rap FOREIGN KEY (MaRapPhim) REFERENCES RAP_CHIEU_PHIM(MaRapPhim),
    CONSTRAINT fk_tc_phim FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim)
);

-- 16. SUAT_CHIEU (FK → PHIM, PHONG_CHIEU)
CREATE TABLE SUAT_CHIEU (
    MaSuatChieu VARCHAR2(50) PRIMARY KEY,
    MaPhim VARCHAR2(50) NOT NULL,
    MaPhong VARCHAR2(50) NOT NULL,
    NgayChieu DATE NOT NULL,
    GioBatDau TIMESTAMP DEFAULT SYSDATE NOT NULL,
    GioKetThuc TIMESTAMP DEFAULT SYSDATE NOT NULL,
    GiaVeCoBan DECIMAL(18,2) NOT NULL,
    TrangThai VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_sc_gio CHECK (GioKetThuc > GioBatDau),
    CONSTRAINT chk_sc_gia CHECK (GiaVeCoBan >= 0),
    CONSTRAINT chk_sc_trangthai CHECK (TrangThai IN ('Đang mở','Hủy','Đã chiếu')),
    CONSTRAINT fk_sc_phim FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim) ON DELETE CASCADE,
    CONSTRAINT fk_sc_phong FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong)
);

-- 17. VE_XEM_PHIM (FK → SUAT_CHIEU, GHE, KHACH_HANG, DON_HANG)
CREATE TABLE VE_XEM_PHIM (
    MaVe VARCHAR2(50) PRIMARY KEY,
    MaSuatChieu VARCHAR2(50) NOT NULL,
    MaPhong VARCHAR2(50) NOT NULL,
    HangGhe VARCHAR2(10) NOT NULL,
    SoGhe INT NOT NULL,
    MaNguoiDung_KH VARCHAR2(50) NOT NULL,
    MaDonHang VARCHAR2(50) NOT NULL,
    GiaVeCuoi DECIMAL(18,2) NOT NULL,
    NgayDat TIMESTAMP DEFAULT SYSDATE NOT NULL,
    TrangThai VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_ve_gia CHECK (GiaVeCuoi >= 0),
    CONSTRAINT chk_ve_trangthai CHECK (TrangThai IN ('Đã đặt','Đã thanh toán','Đã xem','Chờ thanh toán','Hủy')),
    CONSTRAINT fk_ve_sc FOREIGN KEY (MaSuatChieu) REFERENCES SUAT_CHIEU(MaSuatChieu) ON DELETE CASCADE,
    CONSTRAINT fk_ve_ghe FOREIGN KEY (MaPhong, HangGhe, SoGhe) REFERENCES GHE(MaPhong, HangGhe, SoGhe),
    CONSTRAINT fk_ve_kh FOREIGN KEY (MaNguoiDung_KH) REFERENCES KHACH_HANG(MaNguoiDung),
    CONSTRAINT fk_ve_dh FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang)
);

-- 18. AP_DUNG (FK → VE_XEM_PHIM, CHUONG_TRINH_KHUYEN_MAI)
CREATE TABLE AP_DUNG (
    MaVe VARCHAR2(50) NOT NULL UNIQUE,
    MaKhuyenMai VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_apdung PRIMARY KEY (MaVe, MaKhuyenMai),
    CONSTRAINT fk_ad_ve FOREIGN KEY (MaVe) REFERENCES VE_XEM_PHIM(MaVe),
    CONSTRAINT fk_ad_km FOREIGN KEY (MaKhuyenMai) REFERENCES CHUONG_TRINH_KHUYEN_MAI(MaKhuyenMai)
);

-- 19. DANH_GIA (FK → KHACH_HANG, PHIM)
CREATE TABLE DANH_GIA (
    MaDanhGia VARCHAR2(50) PRIMARY KEY,
    MaNguoiDung VARCHAR2(50) NOT NULL,
    MaPhim VARCHAR2(50) NOT NULL,
    NoiDung VARCHAR2(1000),
    NgayDang TIMESTAMP DEFAULT SYSDATE NOT NULL,
    DiemSo INT NOT NULL,
    CONSTRAINT chk_dg_diem CHECK (DiemSo BETWEEN 1 AND 10),
    CONSTRAINT fk_dg_kh FOREIGN KEY (MaNguoiDung) REFERENCES KHACH_HANG(MaNguoiDung),
    CONSTRAINT fk_dg_phim FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim) ON DELETE CASCADE
);

-- 50. QUAN_LY (FK → QUAN_TRI_VIEN, RAP_CHIEU_PHIM)
CREATE TABLE QUAN_LY (
    MaNguoiDung_QTV VARCHAR2(50) NOT NULL,
    MaRapPhim VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_quanly PRIMARY KEY (MaNguoiDung_QTV, MaRapPhim),
    CONSTRAINT fk_ql_qtv FOREIGN KEY (MaNguoiDung_QTV) REFERENCES QUAN_TRI_VIEN(MaNguoiDung),
    CONSTRAINT fk_ql_rap FOREIGN KEY (MaRapPhim) REFERENCES RAP_CHIEU_PHIM(MaRapPhim)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_phong_rap ON PHONG_CHIEU(MaRapPhim);
CREATE INDEX idx_ghe_phong ON GHE(MaPhong);
CREATE INDEX idx_phim_ngay ON PHIM(NgayKhoiChieu);
CREATE INDEX idx_donhang_kh ON DON_HANG(MaNguoiDung_KH);
CREATE INDEX idx_gom_hang ON GOM(MaHang);
CREATE INDEX idx_suat_phim ON SUAT_CHIEU(MaPhim);
CREATE INDEX idx_suat_phong ON SUAT_CHIEU(MaPhong);
CREATE INDEX idx_suat_ngay ON SUAT_CHIEU(NgayChieu);
CREATE INDEX idx_ve_suat ON VE_XEM_PHIM(MaSuatChieu);
CREATE INDEX idx_ve_kh ON VE_XEM_PHIM(MaNguoiDung_KH);
CREATE INDEX idx_ve_dh ON VE_XEM_PHIM(MaDonHang);
CREATE INDEX idx_danhgia_kh ON DANH_GIA(MaNguoiDung);
CREATE INDEX idx_danhgia_phim ON DANH_GIA(MaPhim);
--CREATE INDEX idx_thanhtoan_dh ON THANH_TOAN(MaDonHang);

COMMIT;
-- ============================================================================
-- INSERT MORE DATA (CLEAN VERSION)
-- Purpose: Add extra movies (PH009..PH015) with stable poster URLs for testing.
-- Notes:
--   - Idempotent via MERGE.
--   - Does NOT delete PHIM rows, so existing poster data is preserved.
-- ============================================================================

SET DEFINE OFF;
SET ECHO OFF;
SET FEEDBACK OFF;
SET TERMOUT ON;
SET VERIFY OFF;
SET SERVEROUTPUT ON;

-- Update existing rows (keep old poster if already present, fill if NULL).
UPDATE PHIM
SET TenPhim = 'Cô Gái Từ Quá Khứ', ThoiLuong = 105, NgonNgu = 'Tiếng Việt', QuocGia = 'Việt Nam',
    DaoDien = 'Nguyễn Quang Dũng', DienVienChinh = 'Kaity Nguyễn',
    NgayKhoiChieu = TO_DATE('2026-02-14', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Câu chuyện tình yêu xuyên thời gian đầy cảm xúc.',
    DoTuoi = 13, ChuDePhim = 'Tình cảm',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/tH92dHWRnzDuQ8jJya8co47PwuI.jpg')
WHERE MaPhim = 'PH009';

UPDATE PHIM
SET TenPhim = 'Hai Phượng 2', ThoiLuong = 110, NgonNgu = 'Tiếng Việt', QuocGia = 'Việt Nam',
    DaoDien = 'Lê Văn Kiệt', DienVienChinh = 'Ngô Thanh Vân',
    NgayKhoiChieu = TO_DATE('2026-03-08', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Nữ chiến binh trở lại với hành trình truy lùng tổ chức tội phạm mới.',
    DoTuoi = 16, ChuDePhim = 'Hành động',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/pKGvJ5LFyVGfeRRWzUF8B1u0fEf.jpg')
WHERE MaPhim = 'PH010';

UPDATE PHIM
SET TenPhim = 'Doraemon: Nobita Và Cuộc Phiêu Lưu Vũ Trụ', ThoiLuong = 95, NgonNgu = 'Tiếng Việt', QuocGia = 'Japan',
    DaoDien = 'Takahiro Imamura', DienVienChinh = 'Wasabi Mizuta',
    NgayKhoiChieu = TO_DATE('2026-04-01', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Doraemon và nhóm bạn phiêu lưu ngoài vũ trụ.',
    DoTuoi = 0, ChuDePhim = 'Hoạt hình',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/f0cSFvuuEXpQEHXn9jFpCblHyMI.jpg')
WHERE MaPhim = 'PH011';

UPDATE PHIM
SET TenPhim = 'Gái Già Lắm Chiêu 6', ThoiLuong = 100, NgonNgu = 'Tiếng Việt', QuocGia = 'Việt Nam',
    DaoDien = 'Bảo Nhân', DienVienChinh = 'Hồng Vân',
    NgayKhoiChieu = TO_DATE('2026-01-15', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Series hài hước với nhiều tình huống bất ngờ.',
    DoTuoi = 13, ChuDePhim = 'Hài',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/LvfFOe7xx9EeHMylpNVLXsYCUA.jpg')
WHERE MaPhim = 'PH012';

UPDATE PHIM
SET TenPhim = 'Kẻ Thứ Ba', ThoiLuong = 118, NgonNgu = 'Tiếng Việt', QuocGia = 'Việt Nam',
    DaoDien = 'Trần Thanh Huy', DienVienChinh = 'Kaity Nguyễn',
    NgayKhoiChieu = TO_DATE('2026-02-28', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Bộ phim tâm lý tội phạm với nhiều nút thắt.',
    DoTuoi = 18, ChuDePhim = 'Tâm lý - Tội phạm',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/k4Owgh1qe9F3oLokli4lvw0c4nd.jpg')
WHERE MaPhim = 'PH013';

UPDATE PHIM
SET TenPhim = 'Mission Impossible 8', ThoiLuong = 163, NgonNgu = 'English', QuocGia = 'USA',
    DaoDien = 'Christopher McQuarrie', DienVienChinh = 'Tom Cruise',
    NgayKhoiChieu = TO_DATE('2025-05-22', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Ethan Hunt trở lại với nhiệm vụ bất khả thi mới.',
    DoTuoi = 13, ChuDePhim = 'Hành động',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/wxnbCpRKs8FV1SLZYA0mj1x26f9.jpg')
WHERE MaPhim = 'PH014';

UPDATE PHIM
SET TenPhim = 'Ma Da', ThoiLuong = 108, NgonNgu = 'Tiếng Việt', QuocGia = 'Việt Nam',
    DaoDien = 'Tống Phước Lạc', DienVienChinh = 'Thanh Hằng',
    NgayKhoiChieu = TO_DATE('2026-03-20', 'YYYY-MM-DD'),
    MoTaNoiDung = 'Phim kinh dị Việt mang màu sắc dân gian.',
    DoTuoi = 16, ChuDePhim = 'Kinh dị',
    Anh = NVL(Anh, 'https://image.tmdb.org/t/p/w500/gmoA1CpaLxLNK4nLpbszpvm2Dyr.jpg')
WHERE MaPhim = 'PH015';

-- Insert missing rows only.
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH009', 'Cô Gái Từ Quá Khứ', 105, 'Tiếng Việt', 'Việt Nam', 'Nguyễn Quang Dũng', 'Kaity Nguyễn',
       TO_DATE('2026-02-14', 'YYYY-MM-DD'), 'Câu chuyện tình yêu xuyên thời gian đầy cảm xúc.',
       13, 'Tình cảm', 'https://image.tmdb.org/t/p/w500/tH92dHWRnzDuQ8jJya8co47PwuI.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH009');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH010', 'Hai Phượng 2', 110, 'Tiếng Việt', 'Việt Nam', 'Lê Văn Kiệt', 'Ngô Thanh Vân',
       TO_DATE('2026-03-08', 'YYYY-MM-DD'), 'Nữ chiến binh trở lại với hành trình truy lùng tổ chức tội phạm mới.',
       16, 'Hành động', 'https://image.tmdb.org/t/p/w500/pKGvJ5LFyVGfeRRWzUF8B1u0fEf.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH010');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH011', 'Doraemon: Nobita Và Cuộc Phiêu Lưu Vũ Trụ', 95, 'Tiếng Việt', 'Japan', 'Takahiro Imamura', 'Wasabi Mizuta',
       TO_DATE('2026-04-01', 'YYYY-MM-DD'), 'Doraemon và nhóm bạn phiêu lưu ngoài vũ trụ.',
       0, 'Hoạt hình', 'https://image.tmdb.org/t/p/w500/f0cSFvuuEXpQEHXn9jFpCblHyMI.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH011');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH012', 'Gái Già Lắm Chiêu 6', 100, 'Tiếng Việt', 'Việt Nam', 'Bảo Nhân', 'Hồng Vân',
       TO_DATE('2026-01-15', 'YYYY-MM-DD'), 'Series hài hước với nhiều tình huống bất ngờ.',
       13, 'Hài', 'https://image.tmdb.org/t/p/w500/LvfFOe7xx9EeHMylpNVLXsYCUA.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH012');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH013', 'Kẻ Thứ Ba', 118, 'Tiếng Việt', 'Việt Nam', 'Trần Thanh Huy', 'Kaity Nguyễn',
       TO_DATE('2026-02-28', 'YYYY-MM-DD'), 'Bộ phim tâm lý tội phạm với nhiều nút thắt.',
       18, 'Tâm lý - Tội phạm', 'https://image.tmdb.org/t/p/w500/k4Owgh1qe9F3oLokli4lvw0c4nd.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH013');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH014', 'Mission Impossible 8', 163, 'English', 'USA', 'Christopher McQuarrie', 'Tom Cruise',
       TO_DATE('2025-05-22', 'YYYY-MM-DD'), 'Ethan Hunt trở lại với nhiệm vụ bất khả thi mới.',
       13, 'Hành động', 'https://image.tmdb.org/t/p/w500/wxnbCpRKs8FV1SLZYA0mj1x26f9.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH014');

INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh)
SELECT 'PH015', 'Ma Da', 108, 'Tiếng Việt', 'Việt Nam', 'Tống Phước Lạc', 'Thanh Hằng',
       TO_DATE('2026-03-20', 'YYYY-MM-DD'), 'Phim kinh dị Việt mang màu sắc dân gian.',
       16, 'Kinh dị', 'https://image.tmdb.org/t/p/w500/gmoA1CpaLxLNK4nLpbszpvm2Dyr.jpg'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = 'PH015');

COMMIT;

-- ============================================================================
-- 2) MOVIE GENRES FOR PH009..PH015
-- ============================================================================
DELETE FROM THE_LOAI_PHIM WHERE MaPhim IN ('PH009', 'PH010', 'PH011', 'PH012', 'PH013', 'PH014', 'PH015');

INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH009', 'Tình cảm');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH010', 'Hành động');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH011', 'Hoạt hình');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH012', 'Hài');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH013', 'Tâm lý');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH014', 'Hành động');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH015', 'Kinh dị');

COMMIT;
-- ============================================================================
-- INSERT DATA - ORACLE SYNTAX (FIXED VERSION - MAY 2026)
-- ============================================================================
-- CRITICAL FIXES APPLIED:
-- 1. All dates updated from December 2025 to May 2026
-- 2. DON_HANG.ThoiGianDat synchronized with VE_XEM_PHIM.NgayDat
-- 3. All SUAT_CHIEU.NgayChieu >= PHIM.NgayKhoiChieu (constraint compliance)
-- 4. Seat assignments respect TRG_VE_CheckGheAvailable (no duplicates)
-- 5. VE_XEM_PHIM with "Đã thanh toán" have matching THANH_TOAN records
-- 6. All trigger constraints validated
-- ============================================================================

SET ECHO OFF
SET FEEDBACK OFF
SET TERMOUT ON
SET VERIFY OFF
SET SERVEROUTPUT ON

-- Tắt kiểm tra khóa ngoại (Disable Constraints)
ALTER TABLE GHE DISABLE CONSTRAINT fk_ghe_phong;
ALTER TABLE THE_LOAI_PHIM DISABLE CONSTRAINT fk_theloai_phim;
ALTER TABLE KHACH_HANG DISABLE CONSTRAINT fk_kh_tk;
ALTER TABLE QUAN_TRI_VIEN DISABLE CONSTRAINT fk_qtv_tk;
ALTER TABLE CA_LAM_VIEC DISABLE CONSTRAINT fk_ca_qtv;
ALTER TABLE DON_HANG DISABLE CONSTRAINT fk_dh_kh;
ALTER TABLE GOM DISABLE CONSTRAINT fk_gom_dh;
ALTER TABLE GOM DISABLE CONSTRAINT fk_gom_mh;
ALTER TABLE THANH_TOAN DISABLE CONSTRAINT fk_tt_dh;
ALTER TABLE TRINH_CHIEU DISABLE CONSTRAINT fk_tc_rap;
ALTER TABLE TRINH_CHIEU DISABLE CONSTRAINT fk_tc_phim;
ALTER TABLE SUAT_CHIEU DISABLE CONSTRAINT fk_sc_phim;
ALTER TABLE SUAT_CHIEU DISABLE CONSTRAINT fk_sc_phong;
ALTER TABLE VE_XEM_PHIM DISABLE CONSTRAINT fk_ve_sc;
ALTER TABLE VE_XEM_PHIM DISABLE CONSTRAINT fk_ve_ghe;
ALTER TABLE VE_XEM_PHIM DISABLE CONSTRAINT fk_ve_kh;
ALTER TABLE VE_XEM_PHIM DISABLE CONSTRAINT fk_ve_dh;
ALTER TABLE AP_DUNG DISABLE CONSTRAINT fk_ad_ve;
ALTER TABLE AP_DUNG DISABLE CONSTRAINT fk_ad_km;
ALTER TABLE DANH_GIA DISABLE CONSTRAINT fk_dg_kh;
ALTER TABLE DANH_GIA DISABLE CONSTRAINT fk_dg_phim;
ALTER TABLE QUAN_LY DISABLE CONSTRAINT fk_ql_qtv;
ALTER TABLE QUAN_LY DISABLE CONSTRAINT fk_ql_rap;

SET DEFINE OFF

-- ========== 1. TÀI KHOẢN - KHÁCH HÀNG - QUẢN TRỊ VIÊN ==========
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH001', 'Nguyễn Văn A', 'Q1, TP.HCM', '0901111111', 'M', 'a@example.com', 'passA', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH002', 'Trần Thị B', 'Q3, TP.HCM', '0902222222', 'F', 'b@example.com', 'passB', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH003', 'Lê Văn C', 'Q5, TP.HCM', '0903333333', 'M', 'c@example.com', 'passC', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH004', 'Phạm Thị D', 'Q7, TP.HCM', '0904444444', 'F', 'd@example.com', 'passD', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH005', 'Hoàng Văn E', 'Tân Bình', '0905555555', 'M', 'e@example.com', 'passE', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH006', 'Vũ Thị F', 'Thủ Đức', '0906666666', 'F', 'f@example.com', 'passF', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH007', 'Đặng Văn G', 'Bình Thạnh', '0907777777', 'M', 'g@example.com', 'passG', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH008', 'Bùi Thị H', 'Gò Vấp', '0908888888', 'F', 'h@example.com', 'passH', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH009', 'Ngô Văn I', 'Q12, TP.HCM', '0909999999', 'M', 'i@example.com', 'passI', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH010', 'Đỗ Thị K', 'Q10, TP.HCM', '0910101010', 'F', 'k@example.com', 'passK', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH011', 'Nguyễn Văn L', 'Q1, TP.HCM', '0911111111', 'M', 'l@example.com', 'passL', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH012', 'Trần Thị M', 'Q3, TP.HCM', '0912222222', 'F', 'm@example.com', 'passM', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH013', 'Lê Văn N', 'Q5, TP.HCM', '0913333333', 'M', 'n@example.com', 'passN', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH014', 'Phạm Thị O', 'Q7, TP.HCM', '0914444444', 'F', 'o@example.com', 'passO', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH015', 'Hoàng Văn P', 'Tân Bình', '0915555555', 'M', 'p@example.com', 'passP', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH016', 'Vũ Thị Q', 'Thủ Đức', '0916666666', 'F', 'q@example.com', 'passQ', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH017', 'Đặng Văn R', 'Bình Thạnh', '0917777777', 'M', 'r@example.com', 'passR', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH018', 'Bùi Thị S', 'Gò Vấp', '0918888888', 'F', 's@example.com', 'passS', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH019', 'Ngô Văn T', 'Q12, TP.HCM', '0919999999', 'M', 't@example.com', 'passT', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('KH020', 'Đỗ Thị U', 'Q10, TP.HCM', '0920202020', 'F', 'u@example.com', 'passU', 'Khach');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('AD001', 'Admin Quản Lý', 'Q1, TP.HCM', '0911111111', 'M', 'admin1@example.com', 'admin1', 'Admin');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('AD002', 'Admin Trưởng Ca', 'Q1, TP.HCM', '0912222222', 'F', 'admin2@example.com', 'admin2', 'Admin');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('AD003', 'Admin Kế Toán', 'Q3, TP.HCM', '0913333333', 'F', 'admin3@example.com', 'admin3', 'Admin');
INSERT INTO TAI_KHOAN (MaNguoiDung, HoTen, DiaChi, SDT, GioiTinh, Email, MatKhau, VaiTro) VALUES
('AD004', 'Admin Nội Bộ', 'Q2, TP.HCM', '0914444444', 'M', 'admin1', 'ad1', 'Admin');

COMMIT;

-- ========== KHÁCH HÀNG ==========
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH001', 'Bronze', 33);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH002', 'Silver', 210);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH003', 'Gold', 682);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH004', 'Bronze', 0);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH005', 'Platinum', 1213);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH006', 'Silver', 225);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH007', 'Bronze', 20);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH008', 'Gold', 510);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH009', 'Bronze', 38);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH010', 'Platinum', 1060);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH011', 'Bronze', 0);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH012', 'Silver', 210);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH013', 'Gold', 510);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH014', 'Bronze', 0);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH015', 'Platinum', 1010);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH016', 'Silver', 210);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH017', 'Bronze', 0);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH018', 'Gold', 510);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH019', 'Bronze', 0);
INSERT INTO KHACH_HANG (MaNguoiDung, LoaiThanhVien, DiemTichLuy) VALUES ('KH020', 'Platinum', 1010);

COMMIT;

-- ========== QUẢN TRỊ VIÊN ==========
INSERT INTO QUAN_TRI_VIEN (MaNguoiDung, NgayBatDauLam, Luong, ChucVu) VALUES ('AD001', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 20000000, 'Quản lý rạp');
INSERT INTO QUAN_TRI_VIEN (MaNguoiDung, NgayBatDauLam, Luong, ChucVu) VALUES ('AD002', TO_DATE('2025-06-01', 'YYYY-MM-DD'), 12000000, 'Trưởng ca');
INSERT INTO QUAN_TRI_VIEN (MaNguoiDung, NgayBatDauLam, Luong, ChucVu) VALUES ('AD003', TO_DATE('2025-09-01', 'YYYY-MM-DD'), 15000000, 'Kế toán');

COMMIT;

-- ========== CA LÀM VIỆC ==========
INSERT INTO CA_LAM_VIEC (MaCa, MaNguoiDung, CaLamViec) VALUES ('CA001', 'AD001', 'Hành chính');
INSERT INTO CA_LAM_VIEC (MaCa, MaNguoiDung, CaLamViec) VALUES ('CA002', 'AD002', 'Ca Sáng');
INSERT INTO CA_LAM_VIEC (MaCa, MaNguoiDung, CaLamViec) VALUES ('CA003', 'AD002', 'Ca Chiều');
INSERT INTO CA_LAM_VIEC (MaCa, MaNguoiDung, CaLamViec) VALUES ('CA004', 'AD003', 'Hành chính');
INSERT INTO CA_LAM_VIEC (MaCa, MaNguoiDung, CaLamViec) VALUES ('CA005', 'AD002', 'Ca Tối');

COMMIT;

-- ========== RẠP – PHÒNG – GHẾ ==========
INSERT INTO RAP_CHIEU_PHIM (MaRapPhim, Ten, ThanhPho, DiaChi, SDT, Email) VALUES ('RAP001', 'Galaxy Nguyễn Du', 'Hồ Chí Minh', '116 Nguyễn Du, Q1', '02838222222', 'glx.nd@example.com');
INSERT INTO RAP_CHIEU_PHIM (MaRapPhim, Ten, ThanhPho, DiaChi, SDT, Email) VALUES ('RAP002', 'CGV Vincom Đồng Khởi', 'Hồ Chí Minh', '72 Lê Thánh Tôn, Q1', '02838333333', 'cgv.dk@example.com');
INSERT INTO RAP_CHIEU_PHIM (MaRapPhim, Ten, ThanhPho, DiaChi, SDT, Email) VALUES ('RAP003', 'BHD Bitexco', 'Hồ Chí Minh', '2 Hải Triều, Q1', '02838444444', 'bhd.bt@example.com');
INSERT INTO RAP_CHIEU_PHIM (MaRapPhim, Ten, ThanhPho, DiaChi, SDT, Email) VALUES ('RAP004', 'Lotte Gò Vấp', 'Hồ Chí Minh', '242 Nguyễn Văn Lượng', '02838555555', 'lotte.gv@example.com');
INSERT INTO RAP_CHIEU_PHIM (MaRapPhim, Ten, ThanhPho, DiaChi, SDT, Email) VALUES ('RAP005', 'CGV Aeon Tân Phú', 'Hồ Chí Minh', '30 Bờ Bao Tân Thắng', '02838666666', 'cgv.tp@example.com');

COMMIT;

-- ========== PHÒNG CHIẾU ==========
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P001', 'RAP001', 'Phòng 1', '2D', 100, 100);
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P002', 'RAP001', 'Phòng 2', '3D', 80, 80);
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P003', 'RAP002', 'Phòng IMAX', 'IMAX', 150, 150);
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P004', 'RAP003', 'Phòng 4', '2D', 60, 60);
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P005', 'RAP004', 'Phòng 5', '3D', 90, 90);
INSERT INTO PHONG_CHIEU (MaPhong, MaRapPhim, Ten, Loai, SucChua, SoGhe) VALUES ('P006', 'RAP005', 'Phòng Gold', 'VIP', 40, 40);

COMMIT;

-- ========== GHẾ (Seat initialization) ==========
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P001', hang, stt, 'Thường'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'B' FROM DUAL UNION ALL SELECT 'C' FROM DUAL UNION ALL SELECT 'D' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 20);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P001', hang, stt, 'VIP'
FROM (SELECT 'E' hang FROM DUAL UNION ALL SELECT 'F' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P002', hang, stt, 'Thường'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'C' FROM DUAL UNION ALL SELECT 'D' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P002', hang, stt, 'VIP'
FROM (SELECT 'B' hang FROM DUAL UNION ALL SELECT 'E' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P003', hang, stt, 'Thường'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'B' FROM DUAL UNION ALL SELECT 'C' FROM DUAL 
      UNION ALL SELECT 'D' FROM DUAL UNION ALL SELECT 'E' FROM DUAL UNION ALL SELECT 'F' FROM DUAL UNION ALL SELECT 'G' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P003', hang, stt, 'Đôi'
FROM (SELECT 'H' hang FROM DUAL UNION ALL SELECT 'I' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P003', hang, stt, 'VIP'
FROM (SELECT 'J' hang FROM DUAL UNION ALL SELECT 'K' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P004', hang, stt, 'Thường'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'B' FROM DUAL UNION ALL SELECT 'C' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P004', hang, stt, 'VIP'
FROM (SELECT 'D' hang FROM DUAL UNION ALL SELECT 'E' FROM DUAL UNION ALL SELECT 'F' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P005', hang, stt, 'Thường'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'B' FROM DUAL UNION ALL SELECT 'C' FROM DUAL 
      UNION ALL SELECT 'D' FROM DUAL UNION ALL SELECT 'E' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);
INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P005', hang, stt, 'VIP'
FROM (SELECT 'F' hang FROM DUAL UNION ALL SELECT 'G' FROM DUAL UNION ALL SELECT 'H' FROM DUAL UNION ALL SELECT 'I' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

INSERT INTO GHE (MaPhong, HangGhe, SoGhe, LoaiGhe) SELECT 'P006', hang, stt, 'Giường nằm'
FROM (SELECT 'A' hang FROM DUAL UNION ALL SELECT 'B' FROM DUAL UNION ALL SELECT 'C' FROM DUAL UNION ALL SELECT 'D' FROM DUAL),
     (SELECT ROWNUM stt FROM DUAL CONNECT BY ROWNUM <= 10);

COMMIT;

-- ========== PHIM – THỂ LOẠI – KHUYẾN MÃI (UNCHANGED - Movies released before May 2026) ==========
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH001', 'Avengers: Endgame', 180, 'English', 'USA', 'Anthony Russo', 'Robert Downey Jr.', TO_DATE('2019-04-26', 'YYYY-MM-DD'), 'Siêu anh hùng Marvel quấp lại để cứu vũ trụ khỏi tay Thanos. Một cuộc chiến tối cùng giữa thiện và ác.', 13, 'Siêu anh hùng', 'https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH002', 'Nhà Bà Nữ', 120, 'Tiếng Việt', 'Việt Nam', 'Tristian', 'Lê Giang', TO_DATE('2023-01-22', 'YYYY-MM-DD'), 'Một bộ phim hài gia đình vui nhộn với những tình huống hài hước và ấm áp. Câu chuyện về gia đình và tình cảm.', 13, 'Gia đình', 'https://upload.wikimedia.org/wikipedia/vi/thumb/6/6f/%C3%81p_ph%C3%ADch_phim_Nh%C3%A0_b%C3%A0_N%E1%BB%AF.jpg/250px-%C3%81p_ph%C3%ADch_phim_Nh%C3%A0_b%C3%A0_N%E1%BB%AF.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH003', 'Fast & Furious 9', 145, 'English', 'USA', 'Justin Lin', 'Vin Diesel', TO_DATE('2021-05-19', 'YYYY-MM-DD'), 'Đội hình Fast & Furious quay trở lại với những cuộc đua xe tốc độ cao và những pha hành động kịch tính nhất. Tìm kiếm lao động bí ẩn.', 16, 'Hành động', 'https://image.tmdb.org/t/p/w500/deEmLILTPejEb6OGsXRJ5MCvyDW.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH004', 'Conan Movie 26', 110, 'Japanese', 'Japan', 'Yuzuru Tachikawa', 'Minami Takayama', TO_DATE('2023-04-14', 'YYYY-MM-DD'), 'Thám tử lừng danh Conan lại quay trở lại với một vụ án bí ẩn liên quan đến tàu ngầm đen. Một cuộc phiêu lưu kỳ thú chính ở biển.', 13, 'Hoạt hình', 'https://image.tmdb.org/t/p/w500/ksQ8uNgoWsVH6a0oPB6zx08pOwU.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH005', 'Spider-Man: No Way Home', 150, 'English', 'USA', 'Jon Watts', 'Tom Holland', TO_DATE('2021-12-17', 'YYYY-MM-DD'), 'Spider-Man phải đối mặt với những kẻ thù từ các vũ trụ khác nhau. Một cuộc chiến liên vũ trụ đầy kịch tính và bất ngờ.', 13, 'Siêu anh hùng', 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH006', 'Dune: Messiah', 160, 'English', 'USA', 'Denis Villeneuve', 'Chalamet', TO_DATE('2025-04-15', 'YYYY-MM-DD'), 'Tiếp tục câu chuyện sử thi của Dune với những cảnh quay hoành tráng và các trận chiến mãn nhân tạo. Một tác phẩm khoa học viễn tưởng vĩ đại.', 16, 'Viễn tưởng', 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH007', 'Lật Mặt 7', 115, 'Tiếng Việt', 'Việt Nam', 'Lý Hải', 'Lý Hải', TO_DATE('2025-11-25', 'YYYY-MM-DD'), 'Phần 7 của series Lật Mặt mang đến những pha hành động hài hước và gay cấn. Một cuộc chiến với những twist không ngờ tới.', 16, 'Hành động', 'https://iguov8nhvyobj.vcdn.cloud/media/catalog/product/cache/1/image/c5f0a1eff4c394a251036189ccddaacd/l/a/lat-mat-7.jpg');
INSERT INTO PHIM (MaPhim, TenPhim, ThoiLuong, NgonNgu, QuocGia, DaoDien, DienVienChinh, NgayKhoiChieu, MoTaNoiDung, DoTuoi, ChuDePhim, Anh) VALUES
('PH008', 'The Conjuring 3', 100, 'English', 'USA', 'Michael Chaves', 'Patrick Wilson', TO_DATE('2024-10-31', 'YYYY-MM-DD'), 'Những vụ án liên quan đến ma ám bí ẩn lại xuất hiện. Một bộ phim kinh dị đầy rợn người và bí ẩn.', 18, 'Kinh dị', 'https://image.tmdb.org/t/p/w500/rQfX2xx8TUoNvyk892yKWNikJaM.jpg');

COMMIT;

-- ========== THE_LOAI_PHIM ==========
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH001', 'Hành động');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH002', 'Hài');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH003', 'Hành động');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH004', 'Hoạt hình');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH005', 'Siêu anh hùng');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH006', 'Viễn tưởng');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH007', 'Hành động');
INSERT INTO THE_LOAI_PHIM (MaPhim, TheLoai) VALUES ('PH008', 'Kinh dị');

COMMIT;

-- ========== KHUYẾN MÃI ==========
INSERT INTO CHUONG_TRINH_KHUYEN_MAI (MaKhuyenMai, TenChuongTrinh, DieuKien, NgayBatDau, NgayKetThuc, MucGiam) VALUES
('KM001', 'Thứ 3 vui vẻ', 'Suất chiếu thứ 3', TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 20000);
INSERT INTO CHUONG_TRINH_KHUYEN_MAI (MaKhuyenMai, TenChuongTrinh, DieuKien, NgayBatDau, NgayKetThuc, MucGiam) VALUES
('KM002', 'Thành viên Silver', 'Hạng Silver', TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 15000);
INSERT INTO CHUONG_TRINH_KHUYEN_MAI (MaKhuyenMai, TenChuongTrinh, DieuKien, NgayBatDau, NgayKetThuc, MucGiam) VALUES
('KM003', 'Combo vé + bắp', 'Mua kèm combo', TO_DATE('2025-02-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 10000);
INSERT INTO CHUONG_TRINH_KHUYEN_MAI (MaKhuyenMai, TenChuongTrinh, DieuKien, NgayBatDau, NgayKetThuc, MucGiam) VALUES
('KM004', 'HSSV', 'Thẻ HSSV', TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 25000);
INSERT INTO CHUONG_TRINH_KHUYEN_MAI (MaKhuyenMai, TenChuongTrinh, DieuKien, NgayBatDau, NgayKetThuc, MucGiam) VALUES
('KM005', 'May 2026 Special', 'Ngày May', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_DATE('2026-05-31', 'YYYY-MM-DD'), 30000);

COMMIT;

-- ========== MẶT HÀNG ==========
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH001', 'Bắp rang bơ', 45000, 100, 'Vị bơ', 'DO_AN');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH002', 'Nước ngọt Coca', 30000, 200, 'Lon 330ml', 'DO_AN');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH003', 'Combo bắp + nước', 70000, 150, 'Tiết kiệm', 'DO_AN');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH004', 'Móc khóa Spider-Man', 60000, 50, 'Móc khóa', 'QUA_LUU_NIEM');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH005', 'Áo thun Avengers', 200000, 30, 'Áo thun', 'QUA_LUU_NIEM');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH006', 'Bắp Phô Mai', 55000, 80, 'Vị phô mai', 'DO_AN');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH007', 'Hotdog', 40000, 60, 'Xúc xích nóng', 'DO_AN');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH008', 'Ly giữ nhiệt Conan', 150000, 40, 'Ly limited', 'QUA_LUU_NIEM');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH_VIP_1', 'Mô hình Iron Man', 5000000, 10, 'Life-size 1:1', 'QUA_LUU_NIEM');
INSERT INTO MAT_HANG (MaHang, TenHang, DonGia, SoLuongTon, MoTa, LoaiHang) VALUES
('MH_VIP_2', 'Bộ sưu tập Marvel', 2000000, 20, 'Full set', 'QUA_LUU_NIEM');

COMMIT;

-- ========== ĐƠN HÀNG (MAY 2026 - FIXED DATES) ==========
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH001', 'KH001', 'Online', TO_TIMESTAMP('2026-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH002', 'KH002', 'Tại quầy', TO_TIMESTAMP('2026-05-01 10:15:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Chờ thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH003', 'KH003', 'Online', TO_TIMESTAMP('2026-05-01 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH004', 'KH004', 'Tại quầy', TO_TIMESTAMP('2026-05-01 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Hủy');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH005', 'KH005', 'Online', TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH006', 'KH006', 'Online', TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH007', 'KH007', 'App', TO_TIMESTAMP('2026-05-02 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH008', 'KH008', 'Tại quầy', TO_TIMESTAMP('2026-05-03 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Chờ thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH009', 'KH009', 'Online', TO_TIMESTAMP('2026-05-03 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH010', 'KH010', 'Online', TO_TIMESTAMP('2026-05-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH011', 'KH001', 'App', TO_TIMESTAMP('2026-05-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Đã thanh toán');
INSERT INTO DON_HANG (MaDonHang, MaNguoiDung_KH, PhuongThuc, ThoiGianDat, TongTien, TrangThai) VALUES
('DH012', 'KH002', 'Web', TO_TIMESTAMP('2026-05-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 'Hủy');

COMMIT;

-- ========== TRINH CHIẾU – SUẤT CHIẾU (MAY 2026) ==========
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP001','PH001');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP001','PH002');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP001','PH006');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP002','PH003');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP002','PH007');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP003','PH004');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP003','PH008');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP004','PH005');
INSERT INTO TRINH_CHIEU (MaRapPhim, MaPhim) VALUES ('RAP005','PH001');

COMMIT;

-- ========== SUẤT CHIẾU (MAY 2026) ==========
-- May 1, 2026 (Thursday): 9 showtimes
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC001', 'PH001', 'P001', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC002', 'PH002', 'P002', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 100000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC003', 'PH003', 'P003', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 15:15:00', 'YYYY-MM-DD HH24:MI:SS'), 150000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC005', 'PH001', 'P001', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC006', 'PH002', 'P002', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 100000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC007', 'PH003', 'P003', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 20:15:00', 'YYYY-MM-DD HH24:MI:SS'), 150000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC008', 'PH001', 'P001', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC009', 'PH004', 'P004', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 14:50:00', 'YYYY-MM-DD HH24:MI:SS'), 110000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC010', 'PH005', 'P005', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-01 16:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');

-- May 2, 2026 (Friday): 4 showtimes
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC004', 'PH001', 'P001', TO_DATE('2026-05-02', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-02 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-02 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC011', 'PH002', 'P002', TO_DATE('2026-05-02', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-02 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-02 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 100000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC012', 'PH006', 'P001', TO_DATE('2026-05-02', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-02 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-02 19:40:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC013', 'PH007', 'P002', TO_DATE('2026-05-02', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-02 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-02 20:55:00', 'YYYY-MM-DD HH24:MI:SS'), 100000, 'Đang mở');

-- May 3, 2026 (Saturday): 2 showtimes
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC014', 'PH001', 'P001', TO_DATE('2026-05-03', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-03 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-03 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC015', 'PH008', 'P004', TO_DATE('2026-05-03', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-03 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-03 21:40:00', 'YYYY-MM-DD HH24:MI:SS'), 110000, 'Đang mở');

-- May 4, 2026 (Sunday): 2 showtimes
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC016', 'PH005', 'P005', TO_DATE('2026-05-04', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-04 22:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120000, 'Đang mở');
INSERT INTO SUAT_CHIEU (MaSuatChieu, MaPhim, MaPhong, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
('SC017', 'PH006', 'P003', TO_DATE('2026-05-04', 'YYYY-MM-DD'), TO_TIMESTAMP('2026-05-04 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-05-04 20:40:00', 'YYYY-MM-DD HH24:MI:SS'), 150000, 'Đang mở');

COMMIT;

-- ========== VÉ XEM PHIM (MAY 2026 - UNIQUE SEATS PER SCREENING) ==========
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE001', 'SC001', 'P001', 'A', 1, 'KH001', 'DH001', 120000, TO_TIMESTAMP('2026-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE002', 'SC002', 'P002', 'A', 1, 'KH002', 'DH002', 100000, TO_TIMESTAMP('2026-05-01 10:15:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE003', 'SC003', 'P003', 'A', 1, 'KH003', 'DH003', 150000, TO_TIMESTAMP('2026-05-01 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE005', 'SC012', 'P001', 'E', 1, 'KH005', 'DH005', 120000, TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE006', 'SC011', 'P002', 'B', 1, 'KH006', 'DH006', 100000, TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE007', 'SC004', 'P001', 'E', 2, 'KH007', 'DH007', 120000, TO_TIMESTAMP('2026-05-02 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE008', 'SC015', 'P004', 'D', 1, 'KH008', 'DH008', 110000, TO_TIMESTAMP('2026-05-03 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Chờ thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE009', 'SC004', 'P001', 'E', 3, 'KH009', 'DH009', 120000, TO_TIMESTAMP('2026-05-03 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE010', 'SC016', 'P005', 'F', 1, 'KH010', 'DH010', 120000, TO_TIMESTAMP('2026-05-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE011', 'SC016', 'P005', 'F', 2, 'KH010', 'DH010', 120000, TO_TIMESTAMP('2026-05-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE012', 'SC017', 'P003', 'A', 2, 'KH010', 'DH010', 150000, TO_TIMESTAMP('2026-05-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE013', 'SC014', 'P001', 'A', 3, 'KH001', 'DH011', 120000, TO_TIMESTAMP('2026-05-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Đã thanh toán');
INSERT INTO VE_XEM_PHIM (MaVe, MaSuatChieu, MaPhong, HangGhe, SoGhe, MaNguoiDung_KH, MaDonHang, GiaVeCuoi, NgayDat, TrangThai) VALUES
('VE014', 'SC002', 'P002', 'A', 2, 'KH002', 'DH012', 100000, TO_TIMESTAMP('2026-05-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Hủy');

COMMIT;

-- ========== GỒM (Snacks/Products) ==========
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH001','MH001',1,45000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH001','MH002',2,30000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH002','MH003',1,70000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH003','MH004',1,60000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH005','MH005',2,200000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH006','MH006',1,55000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH006','MH002',1,30000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH007','MH008',1,150000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH007','MH001',1,45000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH008','MH006',1,55000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH009','MH005',1,200000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH009','MH007',2,40000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH010','MH008',2,150000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH010','MH003',2,70000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH011','MH001',2,45000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH012','MH003',1,70000);
INSERT INTO GOM (MaDonHang, MaHang, SoLuong, DonGia) VALUES ('DH012','MH007',1,40000);

COMMIT;

-- ========== THANH TOÁN (Payments - MAY 2026) ==========
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT001', 'DH001', TO_TIMESTAMP('2026-05-01 10:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Thẻ', 'Đã thanh toán', 165000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT002', 'DH002', TO_TIMESTAMP('2026-05-01 10:20:00', 'YYYY-MM-DD HH24:MI:SS'), 'Tiền mặt', 'Đang xử lý', 70000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT003', 'DH003', TO_TIMESTAMP('2026-05-01 11:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Ví điện tử', 'Đã thanh toán', 210000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT004', 'DH004', TO_TIMESTAMP('2026-05-01 12:40:00', 'YYYY-MM-DD HH24:MI:SS'), 'Tiền mặt', 'Thất bại', 0);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT005', 'DH005', TO_TIMESTAMP('2026-05-02 09:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Thẻ', 'Đã thanh toán', 520000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT006', 'DH006', TO_TIMESTAMP('2026-05-02 10:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Momo', 'Đã thanh toán', 185000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT007', 'DH007', TO_TIMESTAMP('2026-05-02 14:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'ZaloPay', 'Đã thanh toán', 315000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT008', 'DH008', TO_TIMESTAMP('2026-05-03 18:10:00', 'YYYY-MM-DD HH24:MI:SS'), 'Tiền mặt', 'Đang xử lý', 55000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT009', 'DH009', TO_TIMESTAMP('2026-05-03 19:10:00', 'YYYY-MM-DD HH24:MI:SS'), 'Thẻ', 'Đã thanh toán', 440000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT010', 'DH010', TO_TIMESTAMP('2026-05-04 20:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Visa', 'Đã thanh toán', 690000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT011', 'DH011', TO_TIMESTAMP('2026-05-05 08:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Momo', 'Đã thanh toán', 210000);
INSERT INTO THANH_TOAN (MaThanhToan, MaDonHang, NgayThanhToan, PhuongThuc, TrangThai, SoTien) VALUES
('TT012', 'DH012', TO_TIMESTAMP('2026-05-05 14:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Visa', 'Thất bại', 0);

COMMIT;

-- ========== QUẢN LÝ (Management assignments) ==========
INSERT INTO QUAN_LY (MaNguoiDung_QTV, MaRapPhim) VALUES ('AD001', 'RAP001');
INSERT INTO QUAN_LY (MaNguoiDung_QTV, MaRapPhim) VALUES ('AD002', 'RAP002');
INSERT INTO QUAN_LY (MaNguoiDung_QTV, MaRapPhim) VALUES ('AD003', 'RAP003');

COMMIT;

-- ========== ÁP DỤNG KHUYẾN MÃI (Apply promotions) ==========
INSERT INTO AP_DUNG (MaVe, MaKhuyenMai) VALUES ('VE001', 'KM001');
INSERT INTO AP_DUNG (MaVe, MaKhuyenMai) VALUES ('VE002', 'KM002');
INSERT INTO AP_DUNG (MaVe, MaKhuyenMai) VALUES ('VE005', 'KM005');
INSERT INTO AP_DUNG (MaVe, MaKhuyenMai) VALUES ('VE006', 'KM005');
INSERT INTO AP_DUNG (MaVe, MaKhuyenMai) VALUES ('VE010', 'KM005');

COMMIT;

-- ========== DANH GIA (Customer reviews) ==========
INSERT INTO DANH_GIA (MaDanhGia, MaNguoiDung, MaPhim, NoiDung, DiemSo) VALUES
('DG001', 'KH001', 'PH001', 'Phim siêu hay, cái kết rất cảm động!', 10);
INSERT INTO DANH_GIA (MaDanhGia, MaNguoiDung, MaPhim, NoiDung, DiemSo) VALUES
('DG002', 'KH002', 'PH001', 'Đã xem 2 lần rồi, vẫn hay lắm', 9);
INSERT INTO DANH_GIA (MaDanhGia, MaNguoiDung, MaPhim, NoiDung, DiemSo) VALUES
('DG003', 'KH003', 'PH002', 'Hài thật, cười bụi xịt', 8);
INSERT INTO DANH_GIA (MaDanhGia, MaNguoiDung, MaPhim, NoiDung, DiemSo) VALUES
('DG004', 'KH004', 'PH003', 'Fast & Furious vẫn luôn tuyệt vời', 9);
INSERT INTO DANH_GIA (MaDanhGia, MaNguoiDung, MaPhim, NoiDung, DiemSo) VALUES
('DG005', 'KH005', 'PH005', 'Spider-Man siêu chất', 10);

COMMIT;

-- Bật lại kiểm tra khóa ngoại (Enable Constraints)
ALTER TABLE GHE ENABLE CONSTRAINT fk_ghe_phong;
ALTER TABLE THE_LOAI_PHIM ENABLE CONSTRAINT fk_theloai_phim;
ALTER TABLE KHACH_HANG ENABLE CONSTRAINT fk_kh_tk;
ALTER TABLE QUAN_TRI_VIEN ENABLE CONSTRAINT fk_qtv_tk;
ALTER TABLE CA_LAM_VIEC ENABLE CONSTRAINT fk_ca_qtv;
ALTER TABLE DON_HANG ENABLE CONSTRAINT fk_dh_kh;
ALTER TABLE GOM ENABLE CONSTRAINT fk_gom_dh;
ALTER TABLE GOM ENABLE CONSTRAINT fk_gom_mh;
ALTER TABLE THANH_TOAN ENABLE CONSTRAINT fk_tt_dh;
ALTER TABLE TRINH_CHIEU ENABLE CONSTRAINT fk_tc_rap;
ALTER TABLE TRINH_CHIEU ENABLE CONSTRAINT fk_tc_phim;
ALTER TABLE SUAT_CHIEU ENABLE CONSTRAINT fk_sc_phim;
ALTER TABLE SUAT_CHIEU ENABLE CONSTRAINT fk_sc_phong;
ALTER TABLE VE_XEM_PHIM ENABLE CONSTRAINT fk_ve_sc;
ALTER TABLE VE_XEM_PHIM ENABLE CONSTRAINT fk_ve_ghe;
ALTER TABLE VE_XEM_PHIM ENABLE CONSTRAINT fk_ve_kh;
ALTER TABLE VE_XEM_PHIM ENABLE CONSTRAINT fk_ve_dh;
ALTER TABLE AP_DUNG ENABLE CONSTRAINT fk_ad_ve;
ALTER TABLE AP_DUNG ENABLE CONSTRAINT fk_ad_km;
ALTER TABLE DANH_GIA ENABLE CONSTRAINT fk_dg_kh;
ALTER TABLE DANH_GIA ENABLE CONSTRAINT fk_dg_phim;
ALTER TABLE QUAN_LY ENABLE CONSTRAINT fk_ql_qtv;
ALTER TABLE QUAN_LY ENABLE CONSTRAINT fk_ql_rap;

COMMIT;

-- ============================================================================
-- END OF INSERT DATA - All data synchronized to May 2026
-- All trigger constraints validated:
-- 1. SUAT_CHIEU.NgayChieu >= PHIM.NgayKhoiChieu ✓
-- 2. Unique seats per screening (TRG_VE_CheckGheAvailable) ✓
-- 3. DON_HANG.ThoiGianDat synchronized with VE_XEM_PHIM.NgayDat ✓
-- 4. VE_XEM_PHIM with "Đã thanh toán" have THANH_TOAN records ✓
-- 5. All date-based revenue queries will work correctly ✓
-- ============================================================================
