select compItem,  Max(RecordDate) as RecordDate
into #ptMaxRecDate
from Merch2.dbo.pxfbillxref
group by compItem

--Get ShipItemPLN for CompItem Max Rc Date
select distinct x.CompItem, x.CatItemPack
into #ptXref
from Merch2.dbo.pxfbillxref x join #ptMaxRecDate m on x.CompItem = m.CompItem and x.RecordDate = m.RecordDate

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
into #pt2012 
from pIC704All where year = 2012

select distinct PackNum
into #pt2013
from PIC704All where YEar = 2013

Select t1.PackNum, Case When t2.packNum is null then 'N' else '' End as New 
into #ptNew2013
from #pt2013 t1 Left join #pt2012 t2 on t1.PackNum = t2.PackNum

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


drop table #ptPOList
select left (p.rcptDate, 6) as MonthYear, LefT(p.rcptdate,4) as Year, substring(p.rcptdate,5,2) as Month, p.Sku, r.RD, rd.RDDescription, r.SFC, sf.SfDescription as SFCDescription, Max(x.CatItemPack) as CatItemPack, v.UOM, v.ItemDescription, r.GSO, v.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, r.PrimaryShippingLocation, p.UnitCost, isnull(n1.New,'') as New2013, isnull(n2.New,'') as New2014, isnull(n3.New,'') as New2015, isNull(n4.New,'') as New2016, Sum(p.QtyRcvd) as UnitsRcvd,Sum(p.QtyRcvd*p.UnitCost) as DollarsRcvd, Max(p.QtyDue) as UnitsOrdered, Max(p.QtyDue*p.UnitCost) as DollarsOrdered
into #ptPOList
from PIC430All p 
left join bakery.dbo.vw_itemmaster v on p.Sku = v.ItemNumber and ItemType in(1,2) join #ptXref x on p.Sku = x.CompItem left join #ptRDSFC r on x.CatItemPack = r.ItemNumber and (left(p.rcptdate,4)) = r.Season 
left join #ptNew2013 n1 on x.CatItemPack = n1.PackNum
left join #ptNew2014 n2 on x.CatItemPack = n2.PackNum
left join #ptNew2015 n3 on x.CatItemPack = n3.PackNum
left join #ptNew2016 n4 on x.CatItemPack = n4.PackNum
left join MDW2.dbo.RDCategory rd on r.RD = rd.RDCategory
left join MDW2.dbo.SFCode sf on r.RD = sf.RDMasterCode and r.SFC = sf. SfMasterCode
where p.Year in(2013,2014,2015,2016) 
group by left (p.rcptDate, 6), LefT(p.rcptdate,4), substring(p.rcptdate,5,2), p.Sku, rd.RDDescription,r.RD,r.SFC, sf.SfDescription,v.UOM, v.ItemDescription, r.GSO, v.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, r.PrimaryShippingLocation, p.UnitCost, n1.New, n2.New, n3.New, n4.New
order by left (p.rcptDate, 6),p.Sku, p.PoLnRel


Drop table #ptMaxCalSeq
select year(Weekbegindate) as year, Max(CalendarSeq) as CalendarSeq
into #ptMaxCalSeq
from ODW1.dbo.fiscalcalendar where year(weekbegindate) in (2013,2014,2015)
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

Select p.MonthYear, p.Year, p.Month, p.Sku, p.RD, Max(p.SFC) as SFC, max(p.SFCDescription) as SFCDescription, Max(p.CatITemPack) as CatItemPack, p.UOM, p.ItemDescription, p.GSO, p.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.PrimaryShippingLocation, p.UnitCost, p.New2013, p.New2014, p.New2015, p.New2016, p.UnitsRcvd, p.DollarsRcvd, p.UnitsOrdered, p.DollarsOrdered, Max(g.Active) as Active
from #ptPOList p left join  #ptActive g on rtrim(p.Year) = rtrim(g.Year) and rtrim(p.CatItemPack) = rtrim(g.PackNum)
 where  POLnRel = '7CL235674%'
group by p.MonthYear, p.Year, p.Month, p.Sku, p.RD,  p.UOM, p.ItemDescription, p.GSO, p.CountryCode, p.BuyerCode, p.POLnRel, p.VendorNum, p.VendorName, p.PrimaryShippingLocation, p.UnitCost, p.New2013, p.New2014, p.New2015, p.New2016, p.UnitsRcvd, p.DollarsRcvd, p.UnitsOrdered, p.DollarsOrdered
order by Sku, PoLnRel




