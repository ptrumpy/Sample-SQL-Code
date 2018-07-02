select compItem,  Max(RecordDate) as RecordDate
into #ptMaxRecDate
from Merch2.dbo.pxfbillxref
group by compItem

--Get ShipItemPLN for CompItem Max Rc Date
drop table #ptXref
select distinct x.CompItem, max(x.CatItemPack) as CatItemPack
into #ptXref
from Merch2.dbo.pxfbillxref x join #ptMaxRecDate m on x.CompItem = m.CompItem and x.RecordDate = m.RecordDate
--where x.compitem = '04582'
group by x.CompItem

drop table #ptMaxRD
select distinct season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, Max(RdCategory) as RD
into #ptMaxRD
from MDW1.dbo.Item
where season > 2011
group by season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end

drop table #ptRDSFC
select distinct r.Season, r.ITemNumber, Max(r.RD) as RD, i.SFCategory as SFC, i.PrimaryShippingLocation, Min(Case WHen i.ImportCode = 'GS' then 'GSO' else 'Non_GSO' end) as GSO
into #ptRDSFC
from #ptMaxRD r join MDW1.dbo.item i on r.Season = i.season and r.ItemNumber = ('6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end) and r.RD = i.RdCategory
group by r.Season, r.ITemNumber, i.SFCategory, i.PrimaryShippingLocation

select distinct PackNum
into #pt2013 
from pIC704All where year = 2013

select distinct PackNum
into #pt2014
from PIC704All where YEar = 2014

Select t1.PackNum, Case When t2.packNum is null then 'N' else '' End as New 
into #ptNew2014
from #pt2014 t1 Left join #pt2013 t2 on t1.PackNum = t2.PackNum

select distinct PackNum
into #pt2015
from PIC704All where YEar = 2015

Select t1.PackNum, Case When t2.packNum is null then 'N' else '' End as New 
into #ptNew2015
from #pt2015 t1 Left join #pt2014 t2 on t1.PackNum = t2.PackNum

select distinct PackNum
into #pt2016
from PIC704All where YEar = 2016

Select t1.PackNum, Case When t2.packNum is null then 'N' else '' End as New 
into #ptNew2016
from #pt2016 t1 Left join #pt2015 t2 on t1.PackNum = t2.PackNum

select distinct PackNum
into #pt2017
from PIC704All where YEar = 2017

Select t1.PackNum, Case When t2.packNum is null then 'N' else '' End as New 
into #ptNew2017
from #pt2017 t1 Left join #pt2016 t2 on t1.PackNum = t2.PackNum


drop table #ptPOList
select left (p.rcptDate, 6) as MonthYear, LefT(p.rcptdate,4) as Year, substring(p.rcptdate,5,2) as Month, p.Sku, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.UnitCost, Sum(p.QtyRcvd) as UnitsRcvd,Sum(p.QtyRcvd*p.UnitCost) as DollarsRcvd, Max(p.QtyDue) as UnitsOrdered, Max(p.QtyDue*p.UnitCost) as DollarsOrdered
into #ptPOList
from PIC430All p 
where p.Year in(2017,2014,2015,2016) --and sku = '04582'
group by left (p.rcptDate, 6), LefT(p.rcptdate,4), substring(p.rcptdate,5,2), p.Sku,p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.UnitCost
order by left (p.rcptDate, 6),p.Sku, p.PoLnRel

select ItemNumber, UOM, ItemDescription, ItemType, ItemClass, ItemStatus, CountryCode 
into #ptItemMaster
from bakery.[dbo].[vw_ItemMaster]
--where itemnumber = '04582'

Drop table #ptMaxCalSeq
select year(Weekbegindate) as year, Max(CalendarSeq) as CalendarSeq
into #ptMaxCalSeq
from ODW1.dbo.fiscalcalendar where year(weekbegindate) in (2014,2015,2016)
group by year(weekbegindate)
union 
Select year(weekbegindate) as year, max(g.CalendarSeq) from Merch2.dbo.GlobalInventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
group by year(weekbegindate)

drop table #ptActive
select distinct s.Year,PackNum, 'Y' as Active 
into #ptActive
from Merch2.dbo.GlobalInventory g join #ptMaxCalSeq s on g.CalendarSeq = s.CalendarSeq
where  ExcessNoReOrderFlag is null and (KWO !='K' or KWO is null) and NewProposedDisp !='liquidate' --and year = 2016
order by year

Drop table #ptMaxCatPack
Select p.MonthYear, p.Year, p.Month, p.Sku, p.RD, Max(p.SFC) as SFC, max(p.SFCDescription) as SFCDescription, Max(p.CatITemPack) as CatItemPack, p.UOM, p.ItemDescription, p.GSO, p.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.PrimaryShippingLocation, p.UnitCost, p.UnitsRcvd, p.DollarsRcvd, p.UnitsOrdered, p.DollarsOrdered, Max(g.Active) as Active
into #ptMaxCatpack
from #ptPOList p left join  #ptActive g on rtrim(p.Year) = rtrim(g.Year) and rtrim(p.CatItemPack) = rtrim(g.PackNum)
 --where  POLnRel = '7CL235674%'
group by p.MonthYear, p.Year, p.Month, p.Sku, p.RD,  p.UOM, p.ItemDescription, p.GSO, p.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.PrimaryShippingLocation, p.UnitCost, p.UnitsRcvd, p.DollarsRcvd, p.UnitsOrdered, p.DollarsOrdered
order by Sku, PoLnRel

select p.MonthYear, p.Month, p.Sku, p.RD, p.SFC, p.SFCDescription, p.CatItemPack, p.UOM, p.ItemDescription, p.GSO, p.Countrycode, p.BuyerCode, p.PoLnRel, p.VendorNum, p.VendorName, p.PrimaryShippingLocation, p.UnitCost, p.UnitsRcvd, p.DollarsRcvd, p.UnitsOrdered, p.DollarsOrdered, p.Active,  isnull(n1.New,'') as New2014, isnull(n2.New,'') as New2015, isnull(n3.New,'') as New2016, isNull(n4.New,'') as New2017
from #ptMaxCatPack p 
Left Join #ptNew2014 n1 on p.CatItemPack = n1.PackNum
Left Join #ptNew2015 n2	on p.CatItemPack = n2.PackNum
Left Join #ptNew2016 n3 on p.CatItemPack = n3.PackNum
Left Join #ptNew2017 n4	on p.CatItemPack = n4.PackNum
order by p.Year, p.Month, p.sku, p.CatItemPack



select Substring(d.FoeDate,1,6) as MonthYear, Left(d.FoeDate,4) as Year, Substring(d.FoeDate,5,2) as Month, x.CompItem, r.RD, r.SFC,max(sf.sfdescription) as SFCDescription, MAx('6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end) as ItemNumber,
v.UOM, v.ItemDescription, r.GSO, v.CountryCode, i.BuyerCode, '' as POlnRel, i.VendorCode, i.VendorName, r.PrimaryShippingLocation,   v.InvUnitCost, n1.New as New2014, n2.New as New2015, n3.New as New2016, n4.New as New2017, Sum(o.itemQty) as UnitsShipped, Sum(o.itemQty*v.InvUnitCost) asDollarsShipped, count(1) as Count, max(g.Active) as Active
from MDW1.dbo.OrderLineAll o join MDW1.dbo.OrdersAll d on o.AccountNumber = d.AccountNumber and o.OrderNumber = d.OrderNumber
join MDW1.dbo.Item i on o.CatalogYear = i.Season and o.CatalogCodePrefix = i.PrimaryCatalogCode and o.ItemNumber = i.ItemNumber
join #ptXref x on ('6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end) = x.CatItemPack
left join #ptRDSFC r on ('6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end) = r.ItemNumber and i.Season = r.Season
left join bakery.dbo.vw_itemmaster v on x.CompItem = v.ItemNumber and ItemType in(1,2)
left join  #ptActive g on Left(d.FoeDate,4) = rtrim(g.Year) and '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end = rtrim(g.PackNum)
left join #ptNew2014 n1 on '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end = n1.PackNum
left join #ptNew2015 n2 on '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end = n2.PackNum
left join #ptNew2016 n3 on '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end = n3.PackNum
left join #ptNew2017 n4 on '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end = n4.PackNum
left join MDW2.dbo.SFCode sf on r.RD = sf.RDMasterCode and r.SFC = sf. SfMasterCode
where d.FoeDate >='20140101' and o.dropshipflag = '1' and o.addresssequence <>'000' and d.orderstatus = 'F'
group by Substring(d.FoeDate,1,6), Left(d.FoeDate,4), Substring(d.FoeDate,5,2), x.CompItem, 
i.VendorCode, i.VendorName, r.GSO, r.PrimaryShippingLocation, r.RD, r.SFC, v.CountryCode, i.BuyerCode, v.UOM, v.ItemDescription, v.InvUnitCost, n1.New, n2.New, n3.New, n4.new
order by Left(d.FoeDate,4), Substring(d.FoeDate,5,2), x.CompItem, MAx('6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end)



select count(*) from #ptPOList