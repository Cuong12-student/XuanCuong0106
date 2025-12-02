--Chuyển sang db này
use QLNhanVienDB;
go

if object_id('V_NhanVienNu_6Thang', 'V') is not null drop view V_NhanVienNu_6Thang;
go

create view V_NhanVienNu_6Thang
as
--Lấy danh sách nv nữ làm 6 tháng trở lên 
select nv.*
from NhanVien nv
join HopDong hd ON nv.MaNV = hd.MaNV
where nv.GioiTinh = N'Nữ'	
	and datediff(month, hd.NgayBatDau, getdate()) >= 6;
go
--Tạo index để tối ưu truy vấn dựa trên giới tính và ngày bắt đầu
create index IX_NhanVien_GioiTinh on NhanVien(GioiTinh);
create index IX_HopDong_NgayBatDau on HopDong(NgayBatDau);
create index IX_HopDong_MaNV on HopDong(MaNV);
go

if object_id('V_SapHetHanHopDong', 'V') is not null drop view V_SapHetHanHopDong;
go

create view V_SapHetHanHopDong
as
--Lấy danh sách nv có hợp đồng hết hạn còn 1 tháng
select nv.MaNV, nv.HoTen, hd.MaHD, hd.NgayKetThuc
from NhanVien nv
join HopDong hd on nv.MaNV = hd.MaNV
where datediff(month, getdate(), hd.NgayKetThuc) <= 1 
      and datediff(month, getdate(), hd.NgayKetThuc) > 0 ; 
go

--Tạo index để tối ưu truy vấn
create index IX_HopDong_NgayKetThuc on HopDong(NgayKetThuc);
go

if object_id('V_Luong_TheoPhong', 'V') is not null drop view V_Luong_TheoPhong;
go

create view V_Luong_TheoPhong
as
--Lấy danh sách lương, phụ cấp và tổng lương theo nv và pb
SELECT pb.MaPB, pb.TenPB, nv.MaNV, nv.HoTen, nv.ChucVu, 
       l.LuongCoBan, l.HeSoPhuCap, (l.LuongCoBan * l.HeSoPhuCap) AS TongLuong
FROM NhanVien nv
JOIN PhongBan pb ON nv.MaPB = pb.MaPB
JOIN Luong l ON nv.MaNV = l.MaNV;
go

--Tạo index để tối ưu truy vấn join giữa nv và pb
create index IX_NhanVien_MaPhongBan on NhanVien(MaPB);
create index IX_Luong_BacLuong on Luong(BacLuong);
go

if object_id('V_SoNhanVien_TheoLoaiHD', 'V') is not null drop view V_SoNhanVien_TheoLoaiHD;
go

create view V_SoNhanVien_TheoLoaiHD
as
--Đếm số lượng nv theo từng loại hđ
select LoaiHD, count(*) as SoNhanVien
from HopDong
group by LoaiHD;
go

if object_id('V_QuyLuong_Phong', 'V') is not null drop view V_QuyLuong_Phong;
go

create view V_QuyLuong_Phong
as
--Tính tổng quỹ lương từng phòng
SELECT pb.MaPB, pb.TenPB, SUM(l.LuongCoBan * l.HeSoPhuCap) AS QuyLuong
FROM NhanVien nv
JOIN Luong l ON nv.MaNV = l.MaNV         
JOIN PhongBan pb ON nv.MaPB = pb.MaPB
GROUP BY pb.MaPB, pb.TenPB;
go

if object_id('V_Phong_QuyLuong_TongHop', 'V') is not null drop view V_Phong_QuyLuong_TongHop;
go

CREATE VIEW V_Phong_QuyLuong_TongHop
as
SELECT *
FROM (
    SELECT TOP 1 MaPB, TenPB, QuyLuong, 'Max' AS LoaiQuyLuong
    FROM V_QuyLuong_Phong
    ORDER BY QuyLuong DESC
) AS MaxLuong
UNION ALL
SELECT *
FROM (
    SELECT TOP 1 MaPB, TenPB, QuyLuong, 'Min' AS LoaiQuyLuong
    FROM V_QuyLuong_Phong
    ORDER BY QuyLuong ASC
) AS MinLuong;
GO

if object_id('V_NVNam_Tuoi27', 'V') is not null drop view V_NVNam_Tuoi27;
GO

create view V_NVNam_Tuoi27
as
--Lấy danh sách nv có tuổi từ 27 trở xuống
select nv.MaNV, nv.HoTen, nv.NgaySinh, nv.GioiTinh, nv.SDT, nv.DiaChi, nv.ChucVu, nv.BacLuong, nv.MaPB
from NhanVien nv
where GioiTinh = N'Nam' 
    and datediff(year, nv.NgaySinh, getdate()) <= 27;
go

if object_id('V_ThamNien_2Nam', 'V') is not null drop view V_ThamNien_2Nam;
go

create view V_ThamNien_2Nam
as
--Lấy danh sách nv có thâm niên làm việc 2 năm trở lên
select nv.MaNV, nv.HoTen, nv.NgaySinh, nv.GioiTinh, nv.SDT, nv.DiaChi, nv.ChucVu,
       nv.BacLuong, nv.MaPB, hd.NgayBatDau
from NhanVien nv
join HopDong hd on nv.MaNV = hd.MaNV
where datediff(year, hd.NgayBatDau, getdate()) >= 2;
go