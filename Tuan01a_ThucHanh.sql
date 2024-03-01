----------------------TUAN 01-------------------
--2.
create database SmallWorks
on primary
(
	NAME = 'SmallWorksPrimary',
	FILENAME = 'D:\NguyenLeTramAnh\SmallWorks.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData1
(
	NAME = 'SmallWorksData1',
	FILENAME = 'D:\NguyenLeTramAnh\SmallWorksData1.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData2
(
	NAME = 'SmallWorksData2',
	FILENAME = 'D:\NguyenLeTramAnh\SmallWorksData2.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
)
LOG ON
(
	NAME = 'SmallWorks_log',
	FILENAME = 'D:\NguyenLeTramAnh\SmallWorks_log.ldf',
	SIZE = 10MB,
	FILEGROWTH = 10%,
	MAXSIZE = 20MB
)

--3. Dùng SSMS để xem kết quả: Click phải trên tên của CSDL vừa tạo
--a. Chọn filegroups, quan sát kết quả:
-- Có bao nhiêu filegroup, liệt kê tên các filegroup hiện tại
-- Filegroup mặc định là gì?
-- 4filegroup
--b. Chọn Files, quan sát có bao nhiêu database file?

--4. Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add
--thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1.
--Dùng SSMS xem kết quả.
alter database SmallWorks
add filegroup Test1FG1

alter database SmallWorks
add file(name = filedata1,
         filename='D:\NguyenLeTramAnh\file_data1.ndf',
		 size=5MB,
		 maxsize=10MB
) to filegroup Test1FG1

alter database SmallWorks
add file(name = filedata2,
         filename= 'D:\NguyenLeTramAnh\file_data2.ndf',
		 size=5MB,
		 maxsize=10MB
) to filegroup Test1FG1

--5. Dùng T-SQL tạo thêm một một file thứ cấp filedat3.ndf dung lượng 3MB trong
--filegroup Test1FG1. Sau đó sửa kích thước tập tin này lên 5MB. Dùng SSMS xem
--kết quả. Dùng T-SQL xóa file thứ cấp filedat3.ndf. Dùng SSMS xem kết quả
alter database SmallWorks
add file(name=filedata3,
         filename='D:\NguyenLeTramAnh\file_data3.ndf',
		 size=3MB,
		 maxsize=5MB
) to filegroup Test1FG1

--Xóa file thứ cấp
alter database SmallWorks
remove file filedata3

--Chỉnh sửa size của file
alter database SmallWorks
modify file (name='filedata3', size=5MB)

--6. Xóa filegroup Test1FG1? Bạn có xóa được không? Nếu không giải thích? Muốn xóa
--được bạn phải làm gì?

--Không xóa được do file đang có dữ liệu
--Phải xóa dữ liệu trong file mới xóa được

ALTER DATABASE SmallWorks
REMOVE FILE filedat1

ALTER DATABASE SmallWorks
REMOVE FILE filedat2

ALTER DATABASE SmallWorks
REMOVE FILEGROUP TestFG1

--7. Xem lại thuộc tính (properties) của CSDL SmallWorks bằng cửa sổ thuộc tính
--properties và bằng thủ tục hệ thống sp_helpDb, sp_spaceUsed, sp_helpFile.
--Quan sát và cho biết các trang thể hiện thông tin gì?.


--8. Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó
--đóng cửa sổ properties. Quan sát màu sắc của CSDL. Dùng lệnh T-SQL gỡ bỏ
--thuộc tính ReadOnly và đặt thuộc tính cho phép nhiều người sử dụng CSDL
--SmallWorks
ALTER DATABASE SmallWorks
SET Read_Only -- Chi co doc (database chuyen sang mau xam)

ALTER DATABASE SmallWorks
SET Read_Write -- Doc va Ghi (database chuyen sang mau vang)

ALTER DATABASE SmallWorks
SET MULTI_USER -- Thiet dat nhieu nguoi dung


--9.Trong CSDL SmallWorks, tạo 2 bảng mới theo cấu trúc như sau:
CREATE TABLE dbo.Person
(
	PersonID int NOT NULL,
	FirstName varchar(50) NOT NULL,
	MiddleName varchar(50) NULL,
	LastName varchar(50) NOT NULL,
	EmailAddress nvarchar(50) NULL
) ON SWUserData1

CREATE TABLE dbo.Product
(
	ProductID int NOT NULL,
	ProductName varchar(75) NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	StandardCost money NOT NULL,
	ListPrice money NOT NULL
) ON SWUserData2

--10. Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng Person và bảng Product trong
--AdventureWorks2008 (lưu ý: chỉ rõ tên cơ sở dữ liệu và lược đồ), dùng lệnh
--Insert…Select... Dùng lệnh Select * để xem dữ liệu trong 2 bảng Person và bảng
--Product trong SmallWorks.
INSERT INTO Person(PersonID,FirstName,MiddleName,LastName,EmailAddress)
SELECT p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,ea.EmailAddress
FROM [AdventureWorks2008R2].[Person].[Person] p INNER JOIN
	 [AdventureWorks2008R2].[Person].[EmailAddress] ea
	 ON p.BusinessEntityID=ea.BusinessEntityID

INSERT INTO Product(ProductID,ProductName,ProductNumber,StandardCost,ListPrice)
SELECT p.ProductID,p.Name,p.ProductNumber,p.StandardCost,p.ListPrice
FROM [AdventureWorks2008R2].[Production].[Product] p

--11. Dùng SSMS, Detach cơ sở dữ liệu SmallWorks ra khỏi phiên làm việc của SQL.
-- SmallWorks -> Tasks -> Detach -> OK

--12. Dùng SSMS, Attach cơ sở dữ liệu SmallWorks vào SQL
-- Databases -> Attach -> Add -> OK
