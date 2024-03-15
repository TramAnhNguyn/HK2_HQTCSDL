-------------------TUAN 5----------------
--II) Stored Procedure:
--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
--B1: Tao thu tuc
create proc cau1_TT @thang int, @nam int
as
	begin
		select c.CustomerID, SumOfTotalDue = sum(TotalDue)
		from [Sales].[Customer] c join [Sales].[SalesOrderHeader] h
		on c.CustomerID=h.CustomerID
		where month(OrderDate) = @thang and year(OrderDate)=@nam
		group by c.CustomerID
	end
go

--B2: Tim hieu du lieu
select c.CustomerID, SumOfTotalDue = sum(TotalDue)
from [Sales].[Customer] c join [Sales].[SalesOrderHeader] h
on c.CustomerID=h.CustomerID
group by c.CustomerID

--B3: Thuc thi
exec cau1_TT 2,2006
exec cau1_TT 7,2007
go

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại
--(SalesYTD) của một nhân viên bất kỳ, với một tham số đầu vào và một tham số
--đầu ra. Tham số @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục,
--tham số @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.

--Mau:---------------------------------------------------------------------------------------
create proc cau2_TT @bienVao kieu1, @bienRa kieu2 out  --hay output							-
as																							-
	select																					-
	from																					-
	where																					-
go																							-
																							-
--tim so lieu cua BusinessEntityID = SalesPersonID											-
																							-
--Goi thu tuc bang batch																	-
declare @bienRa kieu   --bien nhan ket qua cua tham so dau ra  VD: @DoanhThuNam money		-
exec Cau2_TT TriVao, @bienRa out															-
select @bienRa as [Doanh thu nam]   --in tri dau ra cua thu tuc								-
go																							-
---------------------------------------------------------------------------------------------

--Giai
--B1: Tao thu tuc
create proc cau2_TT @SalesPerson int, @SalesYTD money out
as
	select @SalesYTD=SalesYTD
	from [Sales].[SalesPerson]
	where BusinessEntityID = @SalesPerson
go

--B2:Tim so lieu
select *
from Sales.SalesPerson

--B3:Thuc thi
declare @DoanhThuNam int 
exec Cau2_TT 275, @DoanhThuNam out	--275 co SalesYTD = 	3763178,1787													
select @DoanhThuNam as [Doanh thu nam]   --in tri dau ra cua thu tuc								
go	

--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).

--B1: Tao thu tuc
create proc cau3_TT @MaxPrice money
as
	select ProductID, ListPrice
	from [Production].[Product]
	where ListPrice <= @MaxPrice
go

--B2: Tim du lieu
select  ProductID,ListPrice
from [Production].[Product]

--B3: Thuc thi
exec cau3_TT 1000

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01

DECLARE @mancc int, @masp_bai4 int, @soluongcc int
set @mancc = 1650
set @masp_bai4 = 4
set @soluongcc = (
    select ppv.OnOrderQty
    from Production.Product as pp join Purchasing.ProductVendor as ppv
    on pp.ProductID = ppv.ProductID
    where ppv.ProductID = @masp_bai4 and ppv.BusinessEntityID = @mancc
)

if @soluongcc is null
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' không cung cấp sản phẩm có mã: ' + convert(varchar(5), @masp_bai4)
else
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' cấp sản phẩm có mã: ' + convert(varchar(5), @masp_bai4) + N' với số lượng là ' + convert(varchar(5), @soluongcc)


--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
create view v_NhomSanPham
as
    select ppc.ProductCategoryID, ppc.Name, SumOfQty = sum(ssod.OrderQty), ssoh.OrderDate
    from Sales.SalesOrderHeader as ssoh join Sales.SalesOrderDetail as ssod
        on ssoh.SalesOrderID = ssod.SalesOrderID join Production.Product pp
        on ssod.ProductID = pp.ProductID join Production.ProductSubCategory as ppsc
        on pp.ProductSubcategoryID = ppsc.ProductSubCategoryID join Production.ProductCategory as ppc
        on ppsc.ProductCategoryID = ppc.ProductCategoryID
    group by ppc.ProductCategoryID, ppc.Name, ssoh.OrderDate
GO

select *
from v_NhomSanPham
go

create proc MaxOrderQty
    @nam int
as
BEGIN
    select n.ProductCategoryID, n.Name, n.SumOfQty
    from v_NhomSanPham as n
    where n.SumOfQty = (
        select max(a.SumOfQty)
    from v_NhomSanPham as a
    where year(a.OrderDate) = @nam
    )
end
go

EXEC MaxOrderQty 2008

drop proc MaxOrderQty
go

drop view v_NhomSanPham
go

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.

create proc TongThu @maNV int, @TongGT money out
as
	begin
		set @TongGT=
			(Select sum(TotalDue)
			from [Sales].[SalesPerson] s join [Sales].[SalesOrderHeader] h
			on s.BusinessEntityID=h.SalesPersonID
			where [BusinessEntityID]=@maNV
			group by [BusinessEntityID]
			)
		if @TongGT > 0 return 0
		else return 1
	end
go

--Tìm dữ liệu
select [BusinessEntityID], sum(TotalDue) as SumOfTotalDue
from [Sales].[SalesPerson] s join [Sales].[SalesOrderHeader] h
	 on s.BusinessEntityID=h.SalesPersonID
group by [BusinessEntityID]   --Nhớ 274, 270
order by [BusinessEntityID]

--Gọi thủ tục bằng Batch
declare @TongTriGia money, @triTraVe int   --bien nhan ket qua cu tham so dau ra
exec @triTraVe=TongThu 274, @TongTriGia out
select @TongTriGia as [TongTriGia],
	   @triTraVe as TriTraVe  
if @triTraVe =0
	print'Thu tuc thanh cong'  --thu tuc thanh cong
else
	print'Thu tuc khong tinh duoc'  --thu tuc that bai
go
--thu voi 270

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.
--Thủ tục
create proc ThongTinCuaHang
    @nam int
as
BEGIN
    select top 1
        ss.Name, MaxOfTotalDue = max(ssoh.TotalDue)
    from Sales.Store as ss join Sales.Customer as sc
        on ss.BusinessEntityID = sc.StoreID join Sales.SalesOrderHeader as ssoh
        on sc.CustomerID = ssoh.CustomerID
    where YEAR(ssoh.OrderDate) = @nam
    group by ss.Name, ssoh.TotalDue
    ORDER BY ssoh.TotalDue Desc
end
GO

--Dữ liệu
select top 1
        ss.Name, MaxOfTotalDue = max(ssoh.TotalDue)
    from Sales.Store as ss join Sales.Customer as sc
        on ss.BusinessEntityID = sc.StoreID join Sales.SalesOrderHeader as ssoh
        on sc.CustomerID = ssoh.CustomerID
    group by ss.Name, ssoh.TotalDue
    ORDER BY ssoh.TotalDue Desc

EXEC ThongTinCuaHang 2007

drop proc ThongTinCuaHang
GO


--III) Function
-- Scalar Function
--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
--giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
--phòng ban tương ứng. 

---Mẫu----------------------------------|
create function TenHam(@Bien_kieu)      |
returns kieu_tra_ve_Scalar  --VD: int   |
as                                      |
	begin                               |
		declare @tongNV int             |
		select @tongNV                  |
		from                            |
		where                           |
		                                |
		return @tongNV                  |
	end                                 |
go                                      |
-----------------------------------------

select dbo.TenHam(tham_so_thuc)
from Bảng
go

--Giải
create function countofEmployees(@mapb smallint)
returns int
as
	begin
		declare @tongNV int
		select @tongNV=count(e.[DepartmentID])
		from HumanResources.EmployeeDepartmentHistory e join HumanResources.Department d
			on e.DepartmentID=d.DepartmentID
		where e.DepartmentID=@mapb
		return @tongNV
	end
go

--Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
--phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng
--[HumanResources].[EmployeeDepartmentHistory] và
--[HumanResources].[Department])

select DepartmentID, Name, dbo.countofEmployees(DepartmentID) as CountOfEmp
from HumanResources.Department
go


--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
create function InventoryProd
(@ProductID int, @LocationID int)
RETURNS int
as
BEGIN
    return (
        select a.Quantity
        from Production.ProductInventory as a
        where a.ProductID = @ProductID and a.LocationID = @LocationID
    )
end
GO

DECLARE @SL int, @locationID int, @productID int

set @productID = 1
set @locationID = 1
set @SL = dbo.InventoryProd(@ProductID, @LocationID);

print N'Sản phẩm có mã: ' + convert(nvarchar(4), @productID) + 
    N' và LocationID: ' + convert(nvarchar(4), @locationID) +
    N' có số lượng sản phẩm tồn kho là: ' + convert(nvarchar(8), @SL)


--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
create function SubTotalOfEmp
(
    @EmplID int, 
    @MonthOrder int, 
    @YearOrder int
)
RETURNS real
as
BEGIN
    return (
        select sum(a.TotalDue)
        from Sales.SalesOrderHeader as a
        where MONTH(a.OrderDate) = @MonthOrder and year(a.OrderDate) = @YearOrder
            and a.SalesPersonID = @EmplID
    )
END
GO

DECLARE @maNV int, @thang int, @nam int, @doanhThu real

set @maNV = 280
set @thang = 1
set @nam = 2008
set @doanhThu = dbo.SubTotalOfEmp(@maNV, @thang, @nam)

print N'Nhan vien co ma: ' + convert(nvarchar(4), @maNV) +
    N' trong thang ' + convert(nvarchar(2), @thang) +
    N' nam ' + convert(nvarchar(4), @nam) +
    N' co doanh thu la: ' + convert(nvarchar(20), @doanhThu)