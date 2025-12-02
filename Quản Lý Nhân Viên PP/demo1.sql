if object_id('V_NhanVienNu_6Thang', 'V') is not null drop view V_NhanVienNu_6Thang;
go
create view V_NhanVienNu_6Thang
as  
--Lấy danh sách nv nữ làm 6 tháng trở lên 
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
go
select*from V_NhanVienNu_6Thang

if object_id('V_SapHetHanHopDong', 'V') is not null drop view V_SapHetHanHopDong;
go
create view V_SapHetHanHopDong
as
--Lấy danh sách nv có hợp đồng hết hạn còn 1 tháng
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
go
select*from V_SapHetHanHopDong 

create view V_Luong_TheoPhong
as
--Lấy danh sách lương, phụ cấp và tổng lương theo nv và pb
select pb.MaPB, 
       pb.TenPB, 
	   nv.MaNV, 
	   nv.HoTen, 
	   nv.ChucVu, 
	   l.LuongCoBan, 
	   l.HeSoPhuCap, 
	   (l.LuongCoBan * l.HeSoPhuCap) as TongLuong
from NhanVien nv
join PhongBan pb on nv.MaPB = pb.MaPB
join Luong l on nv.MaNV = l.MaNV;
go
select*from V_Luong_TheoPhong

if object_id('V_SoNhanVien_TheoLoaiHD', 'V') is not null drop view V_SoNhanVien_TheoLoaiHD;
go
create view V_SoNhanVien_TheoLoaiHD
as
--Đếm số lượng nv theo từng loại hđ
  select count(*) as [Số lượng nhân viên],
	        L.LoaiHD [Loại hợp đồng]
     from NhanVien NV
          join HopDong L on NV.MaNV=L.MaNV
	 group by L.LoaiHD 
go
select*from V_SoNhanVien_TheoLoaiHD

if object_id('V_QuyLuong_Phong', 'V') is not null drop view V_QuyLuong_Phong;
go
create view V_QuyLuong_Phong
as
--Tính tổng quỹ lương từng phòng
select pb.MaPB, pb.TenPB,
	sum(l.LuongCoBan * l.HeSoPhuCap) as QuyLuong
from NhanVien nv
join Luong l on nv.MaNV = l.MaNV
join PhongBan pb on nv.MaPB = pb.MaPB
group by pb.MaPB, pb.TenPB;
go
select*from V_QuyLuong_Phong

if object_id('V_Phong_QuyLuong_Max', 'V') is not null drop view V_Phong_QuyLuong_Max;
if object_id('V_Phong_QuyLuong_Min', 'V') is not null drop view V_Phong_QuyLuong_Min;
go
create view V_Phong_QuyLuong_Max
as
--Lấy phòng có quỹ lương cao nhất
select top 1 *
from V_QuyLuong_Phong
order by QuyLuong desc;
go
create view V_Phong_QuyLuong_Min
as
--Lấy phòng có quỹ lương thấp nhất
select top 1 *
from V_QuyLuong_Phong
order by QuyLuong asc;
go
create view V_Phong_QuyLuong_TongHop
as
select *
from (
    select top 1 MaPB, TenPB, QuyLuong, 'Max' as LoaiQuyLuong
    from V_QuyLuong_Phong
    order by QuyLuong desc
) as MaxLuong
union all
select *
FROM (
    select top 1 MaPB, TenPB, QuyLuong, 'Min' AS LoaiQuyLuong
    from V_QuyLuong_Phong
    order by QuyLuong asc
) as MinLuong;
go
select * from V_Phong_QuyLuong_TongHop

if object_id('V_NVNam_Tuoi27', 'V') is not null drop view V_NVNam_Tuoi27;
go
create view V_NVNam_Tuoi27
as
--Lấy danh sách nv có tuổi từ 27 trở xuống
select nv.MaNV, 
       nv.HoTen, 
	   nv.NgaySinh, 
	   nv.GioiTinh, 
	   nv.SDT, 
	   nv.DiaChi, 
	   nv.ChucVu,
       nv.BacLuong, 
	   nv.MaPB
from NhanVien nv
where nv.GioiTinh = N'Nam'
  and datediff(year, nv.NgaySinh, getdate()) <= 27;
go
select*from V_NVNam_Tuoi27

if object_id('V_ThamNien_2Nam', 'V') IS NOT NULL
    drop view V_ThamNien_2Nam;
go
create view V_ThamNien_2Nam
as
select 
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
from NhanVien nv
join HopDong hd on nv.MaNV = hd.MaNV
where dbo.fn_ThoiGianLamViec(hd.NgayBatDau) >= 2;
go
select * from V_ThamNien_2Nam