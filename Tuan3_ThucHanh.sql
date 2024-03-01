--------------------TUAN3-------------
-----------------CONSTRAINT--------------------
--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table MyDepartment 
(
	DepID smallint not null primary key, 
	DepName nvarchar(50),
	GrpName nvarchar(50)
)
create table MyEmployee 
(
	EmpID int not null primary key,
	FrstName nvarchar(50),
	MidName nvarchar(50),
	LstName nvarchar(50),
	DepID smallint not null foreign key 
	      references MyDepartment(DepID)
)

--2) Dùng lệnh insert <TableName1> select <fieldList> from
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
--bảng [HumanResources].[Department].
insert MyDepartment
select DepartmentID, Name, GroupName
from [HumanResources].[Department]

--delete from MyDepartment

select * from MyDepartment

--3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
--từ 2 bảng
--[Person].[Person] và
--[HumanResources].[EmployeeDepartmentHistory]
insert [dbo].[MyEmployee]
select top 5 p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, h.DepartmentID
from [Person].[Person] p join 
     [HumanResources].[EmployeeDepartmentHistory] h on h.BusinessEntityID=p.BusinessEntityID
where h.DepartmentID=1 

insert [dbo].[MyEmployee]
select top 5 p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, h.DepartmentID
from [Person].[Person] p join 
     [HumanResources].[EmployeeDepartmentHistory] h on h.BusinessEntityID=p.BusinessEntityID
where h.DepartmentID=3

select * from MyEmployee

--alter table MyEmployee
--add constraint fk_DepID foreign key (DepID) references MyDepartment (DepID)

alter table MyEmployee
drop constraint fk_DepID
--tìm hiểu dữ liệu
select p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, h.DepartmentID
from [Person].[Person] p inner join 
     [HumanResources].[EmployeeDepartmentHistory] h on h.BusinessEntityID=p.BusinessEntityID
order by p.BusinessEntityID

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
--có thực hiện được không? Vì sao?
delete from MyDepartment
where DepID=1

select * from MyDepartment
--có thể xóa được vì table MyDepartment không có tham chiếu đến bảng khác

--5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
--với giá trị mặc định là 1.
alter table MyEmployee
add constraint DF_MyEmployee default 1 for DepID
--delete default constraint
alter table MyEmployee
drop constraint DF_MyEmployee 

select * from MyEmployee

--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
--insert into MyEmployee (EmpID, FrstName, MidName,
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
--trong field depID của record mới thêm.

--them record
insert MyDepartment
select
from
where

select * from MyEmployee
--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
--delete set default.


--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
--trong hai bảng MyEmployee và MyDepartment


--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
--ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
--cascade và on update cascade


--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
--thực hiện được không?


--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturinｇ


--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60











-----------------------------------VIEW----------------------
----1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
----Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
----ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate

----2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
----hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
----Product_Name, CountOfOrderID và SubTotal.

----3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
----TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
----CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
----OrderMonth, SUM(TotalDue).

----4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
----viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty

----5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
----đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
----(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

----6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
----‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
----tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
----Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
----Production.Product)

----7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
----lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
----tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
----[HumanResources].[Department],
----[HumanResources].[EmployeeDepartmentHistory],
----[HumanResources].[EmployeePayHistory].

----8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
----OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
----(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này

----9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
----gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
----ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
----Product. Có xóa được không? Vì sao?

----10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
----phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
----Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
----a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
----“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
----chèn được không? Giải thích.
----b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
----phòng thuộc nhóm “Quality Assurance”.
----c. Dùng câu lệnh Select xem kết quả trong bảng Department.