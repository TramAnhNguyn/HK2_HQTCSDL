---------------------------------------TUAN 6------------------------------------

--In-line Table Valued Functions:
--View có tham số
--Thực thi một câulệnh Select như trong một view
--nhưng có thể bao gồm các tham số giống thủ tục


--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

--Mau-------------------------------------------------
create function Ten_Ham(@bien kieu)
returns table
as
return
	(Select
	from
	where
	group by
	having)
go

--goi ham
select * from ten_ham(gia_tri_thuc)
-------------------------------------------------------

--B1: Tao ham
create function SumOfOrder(@thang int, @nam int)
returns table
as
	return(select d.SalesOrderID, h.OrderDate, SubToTal=sum(OrderQty*UnitPrice)
		   from sales.SalesOrderDetail d join Sales.SalesOrderHeader h
		   on d.SalesOrderID=h.SalesOrderID
		   where datepart(mm, OrderDate)=@thang and  datepart(yy, OrderDate)=@nam
		   group by d.SalesOrderID, OrderDate
		   having sum(OrderQty*UnitPrice)> 7000)
go

--B2: Xem du lieu
select d.SalesOrderID, h.OrderDate, SubToTal=sum(OrderQty*UnitPrice)
from sales.SalesOrderDetail d join Sales.SalesOrderHeader h
	 on d.SalesOrderID=h.SalesOrderID
group by d.SalesOrderID, OrderDate
having sum(OrderQty*UnitPrice)> 7000

--B3: Thuc thi
select * from SumOfOrder(8, 2005)

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01

go
create function NewBonus()
returns table
as
return
	(Select h.SalesPersonID, NewBonus=Bonus+sum(SubToTal)*0.01, SumOfSubToTal=sum(SubToTal)
	from Sales.SalesPerson p join Sales.SalesOrderHeader h
	on p.BusinessEntityID=h.SalesPersonID
	group by h.SalesPersonID, Bonus)
go

--Xem du lieu
select h.SalesPersonID, NewBonus=Bonus+sum(SubToTal)*0.01, SumOfSubToTal=sum(SubToTal)
	from Sales.SalesPerson p join Sales.SalesOrderHeader h
	on p.BusinessEntityID=h.SalesPersonID
	group by h.SalesPersonID, Bonus

	--Thuc thi
select * from NewBonus()

select * from Sales.SalesPerson
select * from Sales.SalesOrderHeader


--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
--và [Purchasing].[PurchaseOrderDetail])

--B1: Tao ham
create function SumOfProduct(@MaNCC int)
returns table
as
return
	(select pv.ProductID, SumOfProduct=sum(OrderQty), SumOfSubToTal=sum(SubToTal)
	from Purchasing.ProductVendor pv join Purchasing.PurchaseOrderHeader poh 
		on poh.VendorID=pv.BusinessEntityID join Purchasing.PurchaseOrderDetail pod
		on pod.PurchaseOrderID=poh.PurchaseOrderID
	where poh.VendorID=@MaNCC
	group by pv.ProductID)
go
--B2: Xem du lieu
select * from Purchasing.ProductVendor
select * from [Purchasing].[PurchaseOrderHeader]
select * from [Purchasing].[PurchaseOrderDetail]

select pv.ProductID, SumOfProduct=sum(OrderQty), SumOfSubToTal=sum(SubToTal)
	from Purchasing.ProductVendor pv join Purchasing.PurchaseOrderHeader poh 
		on poh.VendorID=pv.BusinessEntityID join Purchasing.PurchaseOrderDetail pod
		on pod.PurchaseOrderID=poh.PurchaseOrderID
	group by pv.ProductID

--B3: Thuc thi
select * from SumOfProduct(1658)

--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case.. When … Then …
--(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader])

--B1: Tao ham
create function Discount_Func()
returns table
as
return
	(select soh.SalesOrderID, soh.SubTotal, Discount=
	(	
		case
			when SubTotal< 1000 then 0
			when SubTotal >=1000 and SubToTal<5000 then SubTotal*0.05
			when SubToTal >=5000 and SubToTal<10000 then SubTotal*0.1
			else SubTotal *0.15
		end
	)
	from [Sales].[SalesOrderHeader] soh
	)
go
--B2: Xem du lieu
select * from [Sales].[SalesOrderHeader]
--B3: Thuc thi
select * from Discount_Func()

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
--B1:Function
create function TotalOfEmp(@MonthOrder int, @YearOrder int)
returns table
as
return
	(select b.SalesPersonID, Total = Sum(b.SubTotal)
        from Sales.SalesOrderHeader as b
        where month(b.OrderDate) = @MonthOrder and year(b.OrderDate) = @YearOrder
        group by b.SalesPersonID)
go

--B2:Data
select b.SalesPersonID, Total = Sum(b.SubTotal)
        from Sales.SalesOrderHeader as b
        group by b.SalesPersonID

--B3:Implement
select * from TotalOfEmp(1, 2008)

drop function dbo.TotalOfEmp
go
-- Multi-statement Table Valued Functions:

--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function

----------------------------Mẫu------------------------------------
--B1: Tao ham
create function Ten_ham(@bien kieu)
returns @bang table(cot1 kieu, cot2 kieu)  --khai bao cau truc bang
as
begin
	INSERT @bang   --bien kieu table
	SELECT
		FROM
		WHERE
		GROUP BY
		HAVING
	return   -- phai co
end
go

--B2: Goi ham
select * from SumOfOrder_Multi(8, 2005)
go
-----------------------------------------------------------------

--Cau 4_Multi
create function SumOfOrder_Multi(@thang int, @nam int)
returns @bang table(SalesOrderID int, OrderDate datetime,
					SubTotal money)   --khai bao cau truc bang
as
begin 
	insert @bang   --bien kieu table
	select d.SalesOrderID, h.OrderDate, SubToTal=sum(OrderQty*UnitPrice)
		   from sales.SalesOrderDetail d join Sales.SalesOrderHeader h
		   on d.SalesOrderID=h.SalesOrderID
		   where datepart(mm, OrderDate)=@thang and  datepart(yy, OrderDate)=@nam
		   group by d.SalesOrderID, OrderDate
		   having sum(OrderQty*UnitPrice)> 7000
	return
end
go

--goi ham
select * from SumOfOrder_Multi(8, 2005)

--Cau 5_Multi
--B1: Tao ham
create function NewBonus_Multi()
returns @bang table(SalesPersonID int, NewBonus money,
								SumOfSubToTal money)
as
begin
	insert @bang
	Select h.SalesPersonID, NewBonus=Bonus+sum(SubToTal)*0.01, SumOfSubToTal=sum(SubToTal)
	from Sales.SalesPerson p join Sales.SalesOrderHeader h
	on p.BusinessEntityID=h.SalesPersonID
	group by h.SalesPersonID, Bonus
	return
end
go

--B2: Thuc thi
select * from NewBonus_Multi()

--Cau 6_Multi
--B1: Tao ham
create function SumOfProduct_Multi(@MaNCC int)
returns @bang table(ProductID int, SumOfProduct int,
					SumOfSubTotal int)
as
	begin
		insert @bang
		select pv.ProductID, SumOfProduct=sum(OrderQty), SumOfSubToTal=sum(SubToTal)
		from Purchasing.ProductVendor pv join Purchasing.PurchaseOrderHeader poh 
		on poh.VendorID=pv.BusinessEntityID join Purchasing.PurchaseOrderDetail pod
		on pod.PurchaseOrderID=poh.PurchaseOrderID
	where poh.VendorID=@MaNCC
	group by pv.ProductID
	return
	end
go
--B2: Thuc thi
select * from SumOfProduct_Multi(1650)

--Cau 7_Multi
--B1: Tao ham
create function Discount_Func_Multi()
returns @bang table(SalesOrderID int, SubToTal money, Discount money)
as
begin
	insert @bang
	select soh.SalesOrderID, soh.SubTotal, Discount=
	(	
		case
			when SubTotal< 1000 then 0
			when SubTotal >=1000 and SubToTal<5000 then SubTotal*0.05
			when SubToTal >=5000 and SubToTal<10000 then SubTotal*0.1
			else SubTotal *0.15
		end
	)
	from [Sales].[SalesOrderHeader] soh
	return
end
go
--B2: Thuc thi
select * from Discount_Func_Multi()

--Cau 8_Multi
--B1: Tao ham
create function TotalOfEmp_Multi(@MonthOrder int, @YearOrder int)
returns @bang table(SalesOrderID int, ToTal money)
as
begin
	insert @bang
		select b.SalesPersonID, Total = Sum(b.SubTotal)
        from Sales.SalesOrderHeader as b
        where month(b.OrderDate) = @MonthOrder and year(b.OrderDate) = @YearOrder
        group by b.SalesPersonID
		return
end
go
--B2: Thuc thi
select * from TotalOfEmp_Multi(1, 2008)

--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết
--quả là bảng lương của nhân viên đó.
--Ví dụ thực thi hàm: select * from SalaryOfEmp(288)
--Kết quả là:
-- Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân
--viên
--Ví dụ: thực thi hàm select * from SalaryOfEmp(Null)
--Kết quả là 316 record
--(Dữ liệu lấy từ 2 bảng [HumanResources].[EmployeePayHistory] và
--[Person].[Person] )

--B1: Tao ham
create function SalaryOfEmp(@MaNV int)
returns @salary table(BusinessEntityID int, FName nvarchar(50),
					LName nvarchar(50), Salary money)
as
begin
	if @MaNV is not null
		insert @salary
		select p.BusinessEntityID, p.FirstName, p.LastName, eph.Rate
		from Person.Person p join HumanResources.EmployeePayHistory eph
			on p.BusinessEntityID=eph.BusinessEntityID
		where p.BusinessEntityID=@MaNV
	else
		insert @salary
		select p.BusinessEntityID, p.FirstName, p.LastName, eph.Rate
		from Person.Person p join HumanResources.EmployeePayHistory eph
			on p.BusinessEntityID=eph.BusinessEntityID
	return
end
go
--B2:Thuc thi
select * from SalaryOfEmp(null)
select * from SalaryOfEmp(280)
