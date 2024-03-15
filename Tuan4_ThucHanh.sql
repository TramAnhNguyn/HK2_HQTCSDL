-----------------Tuan 4---------
--I)  Batch
--1)  Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của  sản phẩm 
--có ProductID=’778’;  nếu  @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên  500  đơn  hàng”,  ngược  lại  thì  in  ra  chuỗi  “Sản  phẩm  778  có  ít  đơn  đặt
--hàng”
--Khai bao batch
declare @tongsoHD int, @masp int

--Gan gia tri cho bien
set @masp=778
set @tongsoHD=(select count(SalesOrderID)
				from Sales.SalesOrderDetail
				where ProductID=@masp)

--In ket qua ra xua so result (dung select)
select @masp as MaSP, @tongsoHD as TongHD

 --du kien in ra 
if @tongsoHD > 500
	print 'San pham' + cast(@masp as char(4)) +'co tren 500 don hang'
else
	print 'San pham' + cast(@masp as char(4)) + 'co it don dat hang'
go


--2)  Viết  một  đoạn  Batch  với  tham  số  @makh  và  @n  chứa  số  hóa  đơn  của  khách 
--hàng @makh, tham số @nam  chứa năm lập hóa đơn (ví dụ @nam=2008),    nếu
--@n>0  thì  in  ra  chuỗi:  “Khách  hàng  @makh  có  @n  hóa  đơn  trong  năm  2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng  @makh không có hóa đơn nào 
--trong năm 2008”
select * from [Sales].[SalesOrderHeader]

declare @makh int, @n int, @nam int
set @nam=2008
set @makh=29825   --29672
set @n =(select count(*)
		from Sales.SalesOrderHeader
		where CustomerID=@makh and year(OrderDate)=@nam)
select @makh as MaKH, @n as SoHD, @nam as Nam
if @n>0 
	print 'Khach hang' +' '+ cast(@makh as char(5)) + 'co' +' '+ cast(@n as char(5))+ 'hoa don trong nam' + cast(@nam as char(5))
else
	print N'Khách hàng'+' '+ cast(@makh as char(5))+' '+ N'không có hóa đơn nào trong năm' +' '+ cast(@nam as char(5))
go


--3)  Viết  một  batch  tính  số  tiền  giảm  cho  những  hóa  đơn  (SalesOrderID)  có  tổng 
--tiền>100000,  thông  tin  gồm  [SalesOrderID],  SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như  sau:
--  Những hóa đơn có SubTotal<100000 thì không  giảm,
--  SubTotal từ 100000 đến <120000 thì giảm 5% của  SubTotal
--  SubTotal từ 120000 đến <150000 thì giảm 10% của  SubTotal
--  SubTotal từ 150000 trở lên thì giảm 15% của  SubTotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)
select * from 
[Sales].[SalesOrderDetail]

select SalesOrderID, SubTotal=sum(LineTotal),				
	Discount=
	case
		when sum(LineTotal) >=100000 and sum(LineTotal) <120000 then 0.05*sum(LineTotal) 
		when sum(LineTotal) >=120000 and sum(LineTotal) <150000 then 0.1*sum(LineTotal)
		when sum(LineTotal) <100000 then 0
		else 0.15*sum(LineTotal)
	end
from [Sales].SalesOrderDetail
group by SalesOrderID
having sum(LineTotal)>100000
go


--4)  Viết một Batch với 3 tham số:  @masp, @mancc, @soluongcc, chứa giá trị của 
--các  field  [ProductID],[BusinessEntityID],[OnOrderQty],  với  giá  trị  truyền  cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc,   nếu
--@soluongcc trả về giá  trị là null  thì in  ra chuỗi  “Nhà cung  cấp 1650  không cung 
--cấp sản phẩm  4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là  5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
select * from [Purchasing].[ProductVendor]
declare @masp int,
		@mancc int,
		@soluongcc int
set @mancc=1650
set @masp=4

if @soluongcc = null
	print N'Nhà cung  cấp'+cast(@mancc as char(5))+' '+N'không cung cấp sản phẩm'+cast(@masp as char(5))
else
	print N'Nhà cung cấp'+cast(@mancc as char(5))+' '+N'cung cấp sản phẩm 4 với số lượng là'+' '+cast(@soluongcc as char(5))

--5)  Viết  một  batch  thực  hiện  tăng  lương  giờ  (Rate)  của  nhân  viên  trong 
--[HumanResources].[EmployeePayHistory]  theo  điều  kiện  sau:  Khi  tổng  lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì  dừng.
go
create view hreph1 as
	select hreph.BusinessEntityID, hreph.ModifiedDate, hreph.PayFrequency, hreph.Rate, hreph.RateChangeDate
	from HumanResources.EmployeePayHistory as hreph
go


--Test result
select * from hreph1

while (
    select sum(rate)
    from hreph1 ) < 7000
    BEGIN
        update hreph1
        set rate = rate * 1.1
        if (select max(rate)
        from hreph1) > 500
            BREAK
        ELSE
            continue
end

drop view hreph1
go
