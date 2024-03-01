create database Sales
on primary
(
	name ='Sales_data',
	filename = 'D:\NguyenLeTramAnh\Sales_data.mdf',
	size = 10MB,
	filegrowth=20%,
	maxsize=50MB
)
log on
(
	name ='Sales_log',
	filename = 'D:\NguyenLeTramAnh\Sales_log.ldf',
	size = 10MB,
	filegrowth=20%,
	maxsize=50MB
)

use [Sales]

--1. Kiểu dữ liệu tự định nghĩa
EXEC sp_addtype 'Mota', 'NVARCHAR(40)'
EXEC sp_addtype 'IDKH', 'CHAR(10)', 'NOT NULL'
EXEC sp_addtype 'DT', 'CHAR(12)'
--2. Tạo các bảng
create table SanPham
(
	MaSP char(6) primary key,
	TenSP varchar(20),
	NgayNhap date,
	DVT char(10),
	SoLuongTon int,
    DonGiaNhap money
)

create table KhachHang
(
	MaKH IDKH,
	TenKH nvarchar(30),
	DiaChi nvarchar(40),
	DienThoai  DT
)

create table HoaDon
(
	MaHD char(10) primary key,
	NgayLap Date,
	NgayGiao Date,
	MaKH  IDKH,
	DienGiai  MoTa
)

create table ChiTietHD
(
	MaHD char(10),
	MaKH char(6),
	Primary key(MaHD, MaKH),
	SoLuong int,
)

--3. Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100).
alter table HoaDon
alter column DienGiai nvarchar(100)
--4. Thêm vào bảng SanPham cột TyLeHoaHong float
alter table SanPham
add TyLeHoaHong float

--5. Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
    DROP COLUMN NgayNhap

--6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
--khóa chính
ALTER TABLE KhachHang ADD CONSTRAINT PK_KhachHang
    PRIMARY KEY (MaKH)

--khóa ngoại
ALTER TABLE HoaDon ADD CONSTRAINT FK_HoaDon
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
    ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_CHiTietHD_MaHD
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD)
    ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_CHiTietHD_MaSP
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
    ON DELETE CASCADE ON UPDATE CASCADE

--7. Thêm vào bảng HoaDon các ràng buộc sau:
-- NgayGiao >= NgayLap
alter table HoaDon add 
check (NgayGiao >= NgayLap)

-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_MaHD
        CHECK (MaHD LIKE '[A-Z]{2}\d{4,}')

-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
ALTER TABLE HoaDon ADD CONSTRAINT DF_HoaDon_NgayLap
        DEFAULT GETDATE() FOR NgayLap

--8. Thêm vào bảng Sản phẩm các ràng buộc sau:
-- SoLuongTon chỉ nhập từ 0 đến 500
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_SoLuongTon
        CHECK (SoLuongTon BETWEEN 0 AND 500)

-- DonGiaNhap lớn hơn 0
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DonGiaNhap
        CHECK (DonGiaNhap > 0)

-- Giá trị mặc định cho NgayNhap là ngày hiện hành
 ALTER TABLE SanPham
        ADD NgayNhap Date
    ALTER TABLE SanPham ADD CONSTRAINT DF_SanPham_NgayNhap
        DEFAULT GETDATE() FOR NgayNhap

-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
ALTER TABLE SanPham
        ALTER COLUMN DVT NCHAR(10)
    ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DVT
        CHECK (DVT IN (N'KG', N'Thùng', N'Cái', N'Hộp'))

--9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng
--buộc của mỗi Table
INSERT INTO SanPham (MaSP, TenSP, NgayNhap, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong) 
    VALUES ('SP01', 'Dau Goi', '20210201', N'Cái', 100, 25000, 1),
            ('SP02', 'Dau Xa', '20210201', N'Cái', 120, 27000, 1),
            ('SP03', 'Xa Phong', '20210201', N'Hộp', 300, 20000, 2),
            ('SP04', 'Mi 3 Mien', '20210201', N'Thùng', 500, 3000, 5)

INSERT INTO KhachHang (MaKH, TenKH, DiaCHi, DienThoai)
    VALUES  ('KH01', N'Trần Minh Quang', N'120 Trường Chinh, Q.12, TP.HCM', '0312345678'),
            ('KH02', N'Nguyễn Thị Anh', N'143 Quang Trung, Q.GV, TP.HCM', '0909091234'),
            ('KH03', N'Võ Quang Hùng', N'23 Nguyễn Thái Bình, Q.GV, TP.HCM', '0707123123'),
            ('KH04', N'Bùi Duy Anh', N'03 Quang Trung, Q.GV, TP.HCM', '0505050505')

INSERT INTO HoaDon (MaHD, NgayLap, NgayGiao, MaKH, DienGiai)
    VALUES  ('HD0101', '20210202', '20210202', 'KH01', N'Giao Nhanh'),
            ('HD0102', '20210202', '20210215', 'KH03', N'Giao Thường'),
            ('HD0103', '20210202', '20210203', 'KH02', N'Giao Nhanh'),
            ('HD0104', '20210202', '20210302', 'KH01', N'Giao Thường')

 INSERT INTO ChiTietHD (MaHD, MaSP, SoLuong)
    VALUES  ('HD0101', 'SP01', 324),
            ('HD0102', 'SP02', 424),
            ('HD0103', 'SP04', 243),
            ('HD0104', 'SP03', 13)

--10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu
--vẫn muốn xóa thì phải dùng cách nào?
--Không xóa được vì hóa đơn có ràng buộc tham chiếu đến bảng ChiTietHD
--Nếu muốn xóa thì phải xóa ở bảng ChiTietHD rồi mới xóa ở bảng HoaDon

--11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và
--MaHD=’1234567890’. Có nhập được không? Tại sao?
-- Không thể nhập 2 bản ghi mới vào bảng ChiTietHD
-- Vì MaHD = ‘HD999999999’ lớn hớn 10 kí tự
-- MaHD=’1234567890’ không có 2 kí tự đầu tiên là kí tự

--12. Đổi tên CSDL Sales thành BanHang
exec sp_renamedb Sales, BanHang

--13. Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao
--chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao
--chép, bạn thực hiện Attach CSDL vào lại SQL.
-- (detach hệ thống sẽ ngắt kết nối tên đã cung cấp và phần còn lại sẽ được giữ nguyên)
    -- Có thể chép được nhưng có khi Attach CSDL có thể bị lỗi vì không Detach CSDL
    -- Để sao chép CSDL cần Detach trước khi chép
    -- database -> Task -> Detach
    -- Vào đường dẫn copy File
    -- C:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA

--14. Tạo bản BackUp cho CSDL BanHang
Backup database BanHang to disk = 'D:\NguyenLeTramAnh'

--15. Xóa CSDL BanHang
use master
drop database Sales