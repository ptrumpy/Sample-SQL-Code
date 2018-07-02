--Get Max Ship Date from Ship Item
select '6' + case when left(ShippedItem,2) = '00' then Right(ShippedItem,5) else right(ShippedItem,6) end as ShippedItem, Max(ShipDelDate) as LastDateShipped
into #ptMaxShipDate
from ShipItem
where StatusCode = 'S'
group by '6' + case when left(ShippedItem,2) = '00' then Right(ShippedItem,5) else right(ShippedItem,6) end

--Max RecordDate by CompITem to used later
select compItem,  Max(RecordDate) as RecordDate
into #ptMaxRecDate
from Merch2.dbo.pxfbillxref
group by compItem, ShipItemPLN

--Get ShipItemPLN for CompItem Max Rc Date
select distinct x.CompItem, x.ShipItemPLN
into #ptXref
from Merch2.dbo.pxfbillxref x join #ptMaxRecDate m on x.CompItem = m.CompItem and x.RecordDate = m.RecordDate

--Get Last Rcpt Date by ShipItemPln
select x.ShipItemPLN, Max(p.RcptDate) as LastRcptDate
into #ptLastRcptDate
from NFIM.dbo.Pic430All p join #ptXref x on x.CompItem = p.Sku
where RcptDate > DateAdd(mm,-18,GetDate())
group by x.ShipItemPln

--Put Last Ship Date and Last Rcpt Date together
select m.PackNum, LastDateShipped, LastRcptDate
 from NFIM.dbo.Minvboh m left join #ptMaxShipDate s on m.PackNum = s.ShippedItem left join #ptLastRcptDate r on s.ShippedItem = r.ShipItemPLN 
where m.QtyCode = 'OH' and left(m.PackNum,1) = '6'
order by m.PackNum


