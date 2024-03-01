use AdventureWorks2008R2
-------------Tuan 2--------------------
--Câu lệnh SELECT sử dụng các hàm thống kê với các mệnh đề Group by và
--Having:
--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
--SubTotal =SUM(OrderQty*UnitPrice).
select h.SalesOrderID, OrderDate, SubToTal=sum(OrderQty * UnitPrice)
from [Sales].[SalesOrderHeader] h inner join [Sales].[SalesOrderDetail] d
     on h.SalesOrderID = d.SalesOrderID
where month(OrderDate)=6 and year(Orderdate)=2008
group by h.SalesOrderID, OrderDate
having sum(OrderQty*Unitprice) >7000
go

--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
select t.TerritoryID, count(c.CustomerID) as SumOfCustomer, SubToTal=sum(OrderQty*UnitPrice)
from [Sales].[Customer] as c  join  
     [Sales].[SalesTerritory] as t on t.TerritoryID = c.TerritoryID join
	 [Sales].[SalesOrderHeader] as h on c.CustomerID = h.CustomerID join
	 [Sales].[SalesOrderDetail] as d on h.SalesOrderID = d.SalesOrderID 
where t.CountryRegionCode = 'US'
group by t.TerritoryID
order by t.TerritoryID

select * from [Sales].[SalesTerritory]

--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
select d.SalesOrderID, d.CarrierTrackingNumber, Subtotal=sum(OrderQty * UnitPrice)
from [Sales].[SalesOrderDetail] d join [Sales].[SalesOrderHeader] h on d.SalesOrderID=h.SalesOrderID
group by d.SalesOrderID, d.CarrierTrackingNumber
having d.CarrierTrackingNumber like '4BD%'

--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 
--và số lượng bán trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
select p.Name, p.ProductID, avg(d.OrderQty) as 'AverageOfQty'
from [Production].[Product] p join [Sales].[SalesOrderDetail] d on p.ProductID=d.ProductID
where d.UnitPrice < 25 
group by p.Name, p.ProductID
having Count(d.OrderQty) >5


--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
--JobTitle, CountOfPerson=Count(*)
select e.JobTitle,CountOfperson = Count(*)
from [HumanResources].[Employee] e join [Person].[Person] p 
      on e.BusinessEntityID=p.BusinessEntityID
	  group by e.JobTitle
having count(*)>20


--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
--[Purchasing].[PurchaseOrderDetail])
select v.Name, v.BusinessEntityID, d.ProductID, SumOfQty=sum(d.OrderQty), SubTotal=sum(d.OrderQty*d.UnitPrice)
from [Purchasing].[Vendor] v join 
     [Purchasing].[PurchaseOrderHeader] h on v.BusinessEntityID = h.VendorID join
     [Purchasing].[PurchaseOrderDetail] d on h.PurchaseOrderID = d.PurchaseOrderID
where v.Name like '%Bicycles'
group by v.Name, v.BusinessEntityID, d.ProductID
having sum(d.OrderQty*d.UnitPrice) > 8000


--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal
select p.ProductID, p.Name, CountOfOrderID=count(d.SalesOrderID) ,SubTotal=sum(d.OrderQty*d.UnitPrice)
from [Production].[Product] p join
     [Sales].[SalesOrderDetail] d on p.ProductID=d.ProductID join
     [Sales].[SalesOrderHeader] h on h.SalesOrderID=d.SalesOrderID
where datepart(q, h.OrderDate)=1 and year(h.OrderDate)=2008
group by p.ProductID, p.Name
having sum(d.OrderQty*d.UnitPrice) > 1000 and count(d.SalesOrderID)>500

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders).
select FullName=FirstName+' '+p.LastName, CountOfOrders=count(h.SalesOrderID)
from [Person].[Person] p join
     [Sales].[Customer] c on p.BusinessEntityID=c.CustomerID join
	 [Sales].[SalesOrderHeader] h on h.CustomerID=c.CustomerID
where year(h.OrderDate) between 2007 and 2008
group by c.PersonID, p.FirstName+' '+p.LastName
having count(h.SalesOrderID) >25


--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)
select p.ProductID, p.Name, CountOfOrderQty=sum(d.OrderQty), YearOfSales=year(h.OrderDate)
from [Production].[Product] p join 
	 [Sales].[SalesOrderDetail] d on d.ProductID=p.ProductID join
	 [Sales].[SalesOrderHeader] h on d.SalesOrderID=h.SalesOrderID
where p.Name like '%Bike' or p.Name like '%Sport'
group by p.ProductID, p.Name, year(h.OrderDate)
having sum(d.SalesOrderID) >500



--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory]
select d.DepartmentID, d.Name, AvgofRate=avg(p.Rate)
from [HumanResources].[EmployeeDepartmentHistory] h join
     [HumanResources].[Department] d on d.DepartmentID=h.DepartmentID join
     [HumanResources].[EmployeePayHistory] p on p.BusinessEntityID=h.BusinessEntityID
group by d.DepartmentID, d.Name, p.Rate
having avg(p.Rate) > 30

select * from [HumanResources].[Department]


-----------------II) Subquery-----------------
use AdventureWorks2008R2
--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
--trên 100 đơn đặt hàng trong tháng 7 năm 2008
select p.ProductID, p.Name
from [Production].[Product] p
where p.ProductID in (
      select d.ProductID
	  from [Sales].[SalesOrderDetail] d join 
	       [Sales].[SalesOrderHeader] h on h.SalesOrderID=d.SalesOrderID
	  where month(h.OrderDate) = 7 and year(h.OrderDate) = 2008
	  group by d.ProductID
	  having count(*)>100)

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
--trong tháng 7/2008
select p.ProductID, p.Name
from Production.Product p join 
     Sales.SalesOrderDetail d on p.ProductID = d.ProductID
    join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where MONTH(h.OrderDate) = 7 and YEAR(h.OrderDate) = 2008
group by p.ProductID, p.Name
having COUNT(*)>=all( 
					select COUNT(*)
					from Sales.SalesOrderDetail d join 
						 Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
					where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
					group by ProductID
)

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder
select c.CustomerID, CountOfOrder=COUNT(*)
from [Sales].[Customer] c join 
     [Sales].[SalesOrderHeader] h on h.CustomerID=c.CustomerID
group by c.CustomerID 
having count(*)>=all (
					  select count(*)
					  from [Sales].[Customer] c join
					       [Sales].[SalesOrderHeader] h on c.CustomerID=h.CustomerID
					  group by c.CustomerID
 )


--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
--bảng Production.Product và Production.ProductModel)
select p.ProductID, p.Name
from [Production].[Product] p
where exists(
			select m.ProductModelID
			from [Production].[ProductModel] m
			where m.Name like 'Long-Sleeve Logo Jersey'
			and p.ProductModelID = m.ProductModelID
)

--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.
select m.ProductModelID, m.Name, max(p.ListPrice)
from [Production].[ProductModel] m join Production.Product p
    on m.ProductModelID = p.ProductModelID
group by m.ProductModelID, m.Name
having max(p.ListPrice) >= all (
    select avg(p.ListPrice)
    from [Production].[ProductModel] m join [Production].[Product] p
    on m.ProductModelID = p.ProductModelID
)


--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)
-- Using in
select p.ProductID, p.Name
from [Production].[Product] p
where p.ProductID in (
    select d.ProductID
    from sales.SalesOrderDetail d
    group by d.ProductID
    having sum(d.OrderQty) > 5000
)
-- Using exists
select p.ProductID, p.Name
from [Production].[Product] p
where exists (
    select d.ProductID
    from [Sales].[SalesOrderDetail] d 
    where p.ProductID = d.ProductID
    group by d.ProductID
    having sum(d.OrderQty) > 5000
)


--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail
select distinct d.ProductID, d.UnitPrice
from Sales.SalesOrderDetail d
where d.UnitPrice >= all (
    select distinct d.UnitPrice
    from Sales.SalesOrderDetail d
    group by d.UnitPrice
)

--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join.
select p.ProductID, p.Name
from Production.Product p
where p.ProductID not in (
    select d.ProductID
    from sales.SalesOrderDetail d
)

--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
--HumanResources.Employees và Sales.SalesOrdersHeader)
select EmployeeID = p.BusinessEntityID, p.FirstName, p.LastName
from Person.Person p
where p.BusinessEntityID in (
    select h.SalesPersonID
    from Sales.SalesOrderHeader as h
    where h.OrderDate > '2008-05-01'
)

--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
select distinct h.CustomerID
from Sales.SalesOrderHeader as h
where h.CustomerID in (
    select h.CustomerID
    from Sales.SalesOrderHeader as h
    where YEAR(h.OrderDate) = 2007
) 
and h.CustomerID not in (
    select h.CustomerID
    from Sales.SalesOrderHeader as h
    where YEAR(h.OrderDate) = 2008
)