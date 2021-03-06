select compItem,  Max(RecordDate) as RecordDate
into #ptMaxRecDate
from Merch2.dbo.pxfbillxref
group by compItem

--Get ShipItemPLN for CompItem Max Rc Date
select distinct x.CompItem, x.CatItemPack
into #ptXref
from Merch2.dbo.pxfbillxref x join #ptMaxRecDate m on x.CompItem = m.CompItem and x.RecordDate = m.RecordDate

select distinct season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, Max(RdCategory) as RD
into #ptMaxRD
from MDW1.dbo.Item
where season > 2012
group by season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end

select distinct r.Season, r.ITemNumber, r.RD, i.SFCategory as SFC, i.PrimaryShippingLocation 
into #ptRDSFC
from #ptMaxRD r join MDW1.dbo.item i on r.Season = i.Season and r.ItemNumber = ('6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end) and r.RD = i.RdCategory

select left (p.rcptDate, 6) as MonthYear, p.Sku, r.RD, r.SFC,x.CatItemPack, v.UOM, v.ItemDescription, v.CountryCode, p.POLnRel, p.VendorNum, p.VendorName, r.PrimaryShippingLocation, p.UnitCost, Sum(p.QtyRcvd) as UnitsRcvd, Max(p.QtyDue) as UnitsOrdered from PIC430All p 
left join bakery.dbo.vw_itemmaster v on p.Sku = v.ItemNumber and ItemType in(1,2) join #ptXref x on p.Sku = x.CompItem left join #ptRDSFC r on x.CatItemPack = r.ItemNumber and (left(p.rcptdate,4)) = r.Season 
where Year in(2013,2014,2015)
group by left (p.rcptDate, 6), p.Sku, x.CatItemPack, r.RD, r.SFC, v.UOM, v.ItemDescription, v.CountryCode,p.POLnRel, p.VendorNum, p.VendorName, r.PrimaryShippingLocation, p.UnitCost
order by left (p.rcptDate, 6),p.Sku, p.PoLnRel

