-- Xóa database nếu tồn tại
IF DB_ID('QLNhanVienDB') IS NOT NULL
BEGIN
    ALTER DATABASE QLNhanVienDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLNhanVienDB;
END
GO

-- Tạo database mới
CREATE DATABASE QLNhanVienDB;
GO
USE QLNhanVienDB;
GO

--USE master;
--GO

--ALTER DATABASE QLNhanVienDB SET MULTI_USER WITH ROLLBACK IMMEDIATE;
--GO

-- Xóa các bảng nếu tồn tại (theo thứ tự ngược FK)
IF OBJECT_ID('HopDong', 'U') IS NOT NULL DROP TABLE HopDong;
IF OBJECT_ID('Luong', 'U') IS NOT NULL DROP TABLE Luong;
IF OBJECT_ID('NhanVien', 'U') IS NOT NULL DROP TABLE NhanVien;
IF OBJECT_ID('PhongBan', 'U') IS NOT NULL DROP TABLE PhongBan;
GO

    CREATE TABLE PhongBan (
    MaPB VARCHAR(10) PRIMARY KEY,
    TenPB NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) NOT NULL,
    DiaDiem NVARCHAR(200) NOT NULL
);
GO

CREATE TABLE NhanVien (
    MaNV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    SDT VARCHAR(15) NOT NULL,
    DiaChi NVARCHAR(200) NOT NULL,
    ChucVu NVARCHAR(50) NOT NULL,
    BacLuong INT NOT NULL DEFAULT 1,        
    MaPB VARCHAR(10) NOT NULL,
    FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

CREATE TABLE Luong (
    MaLuong VARCHAR(10) PRIMARY KEY,
    MaNV VARCHAR(10) NOT NULL,              
    BacLuong INT NOT NULL,                  
    LuongCoBan DECIMAL(15,2) NOT NULL,
    HeSoPhuCap DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    NgayApDung DATE NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE HopDong (
    MaHD VARCHAR(10) PRIMARY KEY,
    MaNV VARCHAR(10) NOT NULL,
    LoaiHD NVARCHAR(20) NOT NULL CHECK (LoaiHD IN (N'Thử Việc', N'1 năm', N'2 Năm', N'5 Năm')),
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO
-- XÓA DỮ LIỆU CŨ (nếu cần)
DELETE FROM HopDong; DELETE FROM Luong; DELETE FROM NhanVien; DELETE FROM PhongBan;
GO

-- 1. PHÒNG BAN (5 phòng – đủ để thấy quỹ lương khác nhau rõ ràng)
INSERT INTO PhongBan (MaPB, TenPB, SDT, DiaDiem) VALUES
('PB01', N'Kế Toán',     '0281112222', N'Tầng 2 - Tòa A'),
('PB02', N'Kinh Doanh',  '0283334444', N'Tầng 4 - Tòa B'),
('PB03', N'Kỹ Thuật',    '0285556666', N'Tầng 3 - Tòa C'),
('PB04', N'Nhân Sự',     '0287778888', N'Tầng 5 - Tòa A'),
('PB05', N'Marketing',   '0289990000', N'Tầng 6 - Tòa B');
GO

-- 2. NHÂN VIÊN (15 người – đủ mọi trường hợp)
INSERT INTO NhanVien (MaNV, HoTen, NgaySinh, GioiTinh, SDT, DiaChi, ChucVu, BacLuong, MaPB) VALUES
-- PB01 - Kế Toán
('NV01', N'Trần Thị Lan',     '1998-05-15', N'Nữ',   '0901000001', N'Hà Nội',     N'Kế toán viên',   2, 'PB01'), -- nữ, làm >6th
('NV02', N'Nguyễn Văn Hùng',  '1995-03-20', N'Nam',  '0901000002', N'TP.HCM',     N'Kế toán trưởng', 5, 'PB01'), -- thâm niên ≥2 năm
('NV03', N'Phạm Thị Mai',     '2001-11-10', N'Nữ',   '0901000003', N'Đà Nẵng',    N'Thực tập sinh',  1, 'PB01'), -- nữ, mới vào <6th

-- PB02 - Kinh Doanh
('NV04', N'Lê Văn Minh',      '2000-08-12', N'Nam',  '0901000004', N'Hà Nội',     N'Nhân viên KD',   1, 'PB02'), -- nam ≤27 tuổi
('NV05', N'Hoàng Thị Ngọc',   '1997-02-28', N'Nữ',   '0901000005', N'TP.HCM',     N'Trưởng nhóm KD', 4, 'PB02'), -- nữ ≥6th
('NV06', N'Vũ Văn Tuấn',      '2003-12-05', N'Nam',  '0901000006', N'Đà Nẵng',    N'Nhân viên KD',   1, 'PB02'), -- nam ≤27 tuổi

-- PB03 - Kỹ Thuật
('NV07', N'Đỗ Văn Giang',     '1988-01-10', N'Nam',  '0901000007', N'Hà Nội',     N'Trưởng phòng',   7, 'PB03'), -- thâm niên lâu, lương cao
('NV08', N'Nguyễn Thị Hương', '1999-09-18', N'Nữ',   '0901000008', N'TP.HCM',     N'Kỹ sư',          3, 'PB03'), -- nữ ≥6th

-- PB04 - Nhân Sự
('NV09', N'Trần Văn Nam',     '2004-04-25', N'Nam',  '0901000009', N'Đà Nẵng',    N'Nhân viên NS',   1, 'PB04'), -- nam ≤27 tuổi
('NV10', N'Lê Thị Thu',       '1996-07-30', N'Nữ',   '0901000010', N'Hà Nội',     N'Chuyên viên',    4, 'PB04'), -- nữ ≥6th

-- PB05 - Marketing
('NV11', N'Phạm Văn Hoàng',   '2005-01-01', N'Nam',  '0901000011', N'TP.HCM',     N'Nhân viên MK',   1, 'PB05'), -- nam ≤27 tuổi
('NV12', N'Bùi Thị Kim',      '2000-10-20', N'Nữ',   '0901000012', N'Đà Nẵng',    N'Trưởng nhóm MK', 3, 'PB05'),
('NV13', N'Hoàng Văn Đức',    '1992-06-15', N'Nam',  '0901000013', N'Hà Nội',     N'Giám đốc MK',    8, 'PB05'), -- lương cao nhất
('NV14', N'Vũ Thị Lan Anh',   '2002-03-22', N'Nữ',   '0901000014', N'TP.HCM',     N'Nhân viên MK',   1, 'PB05'),
('NV15', N'Mai Văn Tuấn',     '2001-11-11', N'Nam',  '0901000015', N'Đà Nẵng',    N'Nhân viên MK',   1, 'PB05');
GO

-- 3. LƯƠNG (đa dạng để quỹ lương khác nhau rõ)
INSERT INTO Luong (MaLuong, MaNV, BacLuong, LuongCoBan, HeSoPhuCap, NgayApDung) VALUES
('L01','NV01',2, 8500000, 1.20, '2024-01-01'),
('L02','NV02',5,18000000, 1.50, '2020-06-01'), -- thâm niên → sẽ được +0.5
('L03','NV03',1, 5000000, 1.00, '2025-03-01'),
('L04','NV04',1, 6500000, 1.10, '2024-09-01'),
('L05','NV05',4,14000000, 1.00, '2023-01-01'),
('L06','NV06',1, 6200000, 1.00, '2024-12-01'),
('L07','NV07',7,25000000, 3.00, '2019-01-01'), -- lương cao nhất
('L08','NV08',3,11000000, 1.50, '2024-02-01'),
('L09','NV09',1, 6000000, 1.00, '2025-01-01'),
('L10','NV10',4,13000000, 1.70, '2023-05-01'),
('L11','NV11',1, 5800000, 1.00, '2025-02-01'),
('L12','NV12',3,12000000, 1.60, '2024-03-01'),
('L13','NV13',8,30000000, 3.50, '2021-01-01'), -- lương khủng
('L14','NV14',1, 6100000, 1.05, '2024-11-01'),
('L15','NV15',1, 6300000, 1.00, '2024-10-01');
GO

-- 4. HỢP ĐỒNG (đủ trường hợp: sắp hết, thâm niên, thử việc…)
INSERT INTO HopDong (MaHD, MaNV, LoaiHD, NgayBatDau, NgayKetThuc) VALUES
('HD01','NV01',N'2 Năm',     '2024-01-01', '2026-01-01'), -- nữ ≥6th
('HD02','NV02',N'5 Năm',     '2020-06-01', '2025-06-01'), -- sắp hết + thâm niên
('HD03','NV03',N'Thử Việc',  '2025-03-01', '2025-06-01'),
('HD04','NV04',N'1 năm',     '2024-09-01', '2025-12-30'), -- sắp hết hạn (≤30 ngày)
('HD05','NV05',N'5 Năm',     '2023-01-01', '2028-01-01'), -- thâm niên
('HD06','NV06',N'1 năm',     '2024-12-01', '2025-12-01'), -- sắp hết
('HD07','NV07',N'5 Năm',     '2019-01-01', '2029-01-01'), -- thâm niên lâu
('HD08','NV08',N'2 Năm',     '2024-02-01', '2026-02-01'),
('HD09','NV09',N'Thử Việc',  '2025-01-01', '2025-04-01'),
('HD10','NV10',N'5 Năm',     '2023-05-01', '2028-05-01'),
('HD11','NV11',N'1 năm',     '2025-02-01', '2026-02-01'),
('HD12','NV12',N'2 Năm',     '2024-03-01', '2026-03-01'),
('HD13','NV13',N'5 Năm',     '2021-01-01', '2026-01-01'), -- thâm niên
('HD14','NV14',N'1 năm',     '2024-11-01', '2025-12-25'), -- sắp hết
('HD15','NV15',N'1 năm',     '2024-10-01', '2025-12-20'); -- sắp hết
GO
-- ======== Truy vấn nâng cao ======== 
IF OBJECT_ID(N'dbo.fn_SoThangLamViec', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_SoThangLamViec;
GO
create function fn_SoThangLamViec(@NgayBatDau Date)
returns int
as 
begin
--Khai báo biến @SoThang cục bộ để lưu kết quả
    declare @SoThang int
    return DateDiff(MONTH,@NgayBatDau,GetDate())
end
select NV.MaNV,
       NV.HoTen, 
	   NV.GioiTinh,
	   HD.NgayBatDau,
	   --Gọi hàm vừa tạo
       dbo.fn_SoThangLamViec(HD.NgayBatDau) as SoThangLamViec
from NhanVien NV
     join HopDong HD on NV.MaNV=HD.MaNV
where NV.GioiTinh=N'Nữ'
and dbo.fn_SoThangLamViec(HD.NgayBatDau)>=6

IF OBJECT_ID('sp_TheoDoiHopDong', 'P') IS NOT NULL
    DROP PROCEDURE sp_TheoDoiHopDong;
GO
--Khai báo sp_TheoDoiHopDong
create procedure sp_TheoDoiHopDong
as 
begin
    select NV.MaNV, 
	       NV.HoTen as [Họ tên], 
		   NV.GioiTinh as [Giới tính], 
		   HD.LoaiHD,
		   HD.NgayBatDau as [Ngày bắt đầu],
		   HD.NgayKetThuc
    from NhanVien NV
         join HopDong HD on NV.MaNV = HD.MaNV
		 --Chỉ theo dõi nhân viên sắp hêt hạn hợp đồng trước hoặc cùng 1 tháng 
    where DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) <= 30 
      and DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) >= 0 
end
exec sp_TheoDoiHopDong

IF OBJECT_ID('sp_SoNhanVienTungLoai', 'P') IS NOT NULL
    DROP PROCEDURE sp_SoNhanVienTungLoai;
GO
create procedure sp_SoNhanVienTungLoai
as
begin
--Đếm số nhân viên bằng cách nhóm vào từng hợp đồng
     select count(*) as [Số lượng nhân viên],
	        L.LoaiHD [Loại hợp đồng]
     from NhanVien NV
          join HopDong L on NV.MaNV=L.MaNV
	 group by L.LoaiHD 
end
exec sp_SoNhanVienTungLoai

IF OBJECT_ID(N'dbo.fn_ThoiGianLamViec', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_ThoiGianLamViec;
GO
--Khai báo fn_ThoiGianLamViec và trả về hàm là số nguyên
create function fn_ThoiGianLamViec(@NgayBatDau Date)
returns int
as 
begin
--Khai báo @SoNam để lưu kết quả
    declare @SoNam int
	set @SoNam=DateDiff(year,@NgayBatDau,GetDate())--Tự động tính ngày hiện tại-ngày bắt đầu
	return @SoNam
end
go
SELECT 
    nv.MaNV,
    nv.HoTen,
    nv.NgaySinh,
    nv.GioiTinh,
    nv.SDT,
    nv.DiaChi,
    nv.ChucVu,
    nv.BacLuong,
    nv.MaPB,
    hd.NgayBatDau,
    dbo.fn_ThoiGianLamViec(hd.NgayBatDau) AS SoNamLamViec
FROM NhanVien nv
JOIN HopDong hd ON nv.MaNV = hd.MaNV
WHERE dbo.fn_ThoiGianLamViec(hd.NgayBatDau) >= 2;
GO

IF OBJECT_ID('trg_Luong_CapNhatHeSoPhuCapThamNien', 'TR') IS NOT NULL
    DROP TRIGGER trg_Luong_CapNhatHeSoPhuCapThamNien;
GO
--Khai báo trg_Luong_CapNhatHeSoPhuCapThamNien để cập nhật tăng lương
CREATE TRIGGER trg_Luong_CapNhatHeSoPhuCapThamNien
ON HopDong  -- Kích Hoạt Khi Hợp Đồng Thay Đổi
AFTER INSERT, UPDATE
AS
BEGIN
    -- Chỉ nâng 1 lần cho NV đủ 2 năm
    UPDATE l 
    SET HeSoPhuCap = HeSoPhuCap + 0.5
    FROM Luong l
    JOIN inserted i ON l.MaNV = i.MaNV
    JOIN HopDong hd ON l.MaNV = hd.MaNV
    WHERE DATEDIFF(MONTH, hd.NgayBatDau, GETDATE()) >= 24
      AND l.HeSoPhuCap < 2   -- Chỉ Nâng 1 Lần!
    
    PRINT N'Đã tự động nâng hệ số cho nhân viên thâm niên!';
END
GO

SELECT MaNV, HeSoPhuCap FROM Luong WHERE MaNV = 'NV02' 
UPDATE HopDong SET LoaiHD = N'5 Năm' WHERE MaNV = 'NV02' 