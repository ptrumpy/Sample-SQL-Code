Select CompanyCode, DateName(dw,(Case When DatePart(dw,FoeDate) between '1' and '6' Then DateAdd(dw,1,FoeDate)
			When DatePart(dw,FoeDate) = '7' Then DateAdd(dw,2,FoeDate) End)) as FoeDate, Sum(ItemQty) from MDW1.dbo.CurrentOrderLineAllocate o Left Join MDW1.dbo.CurrentOrders d on 
d.AccountNumber = o.AccountNumber and d.OrderNumber = o.OrderNumber where FoeDate between DATEADD (wk , -52 , '20150401' )
 and '20150401' and ItemErrorFlag = ' ' and AvailabilityFlag in(' ','1')  and d.OrderStatus = 'F'
group by CompanyCode, DateName(dw,(Case When DatePart(dw,FoeDate) between '1' and '6' Then DateAdd(dw,1,FoeDate)
			When DatePart(dw,FoeDate) = '7' Then DateAdd(dw,2,FoeDate) End))
order by CompanyCode, DateName(dw,(Case When DatePart(dw,FoeDate) between '1' and '6' Then DateAdd(dw,1,FoeDate)
			When DatePart(dw,FoeDate) = '7' Then DateAdd(dw,2,FoeDate) End))