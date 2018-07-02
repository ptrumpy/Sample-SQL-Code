select cal.year_445 as year, cal.month_445 as Month, cal.week_445 as Week, a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3) as POLineRel,  cast(a.ActualDockdate as datetime) as ActualDockdate,a.itemnumber, Sum(a.qtyreceived) as UnitsReceived,i.curspecmatlcost, Sum(i.curSpecMatlCost*a.qtyreceived) as CurSpecMatlCostReceived,  a.purchasePrice, Sum(a.qtyreceived*a.purchaseprice) as UnitCostReceived, 
	e.Rdcategory as RD, e.sfcategory as SFC, rd.Division, a.vendornumber, v.vendorname 
from
(select r.itemnumber, r.vendornumber, r.qtyreceived, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.actualdockdate, r.transdate, r.porecorddate, r.recorddate,  max(i.recorddate) as costrecdate from 
(select itemnumber, vendornumber, qtyreceived, purchaseprice, contractnumber, linenumber, releasenumber, actualdockdate, transdate, porecorddate, recorddate from merch2.[dbo].[vw_ReceiptsHistoryPODetailPurchPrice]) r
 join (select itemnumber, [CurSpecMatlCost], recorddate from bakery.dbo.itemcost) i on  r.itemnumber = i.itemnumber and cast (r.transdate as datetime)  > i.recorddate
 group by r.itemnumber, r.vendornumber, r.qtyreceived, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.actualdockdate, r.transdate, r.porecorddate, r.recorddate
 having max(i.recorddate) <= cast(r.transdate as datetime)
 ) a  join bakery.dbo.ItemCost i on a.itemnumber = i.itemnumber and a.costrecdate = i.recorddate left join (select compitem, max(catitempack) as catitempack from merch2.dbo.[PxfBillXRefVw] 
group by compitem) pxf on a.itemnumber = pxf.compitem join tempwork.dbo.eabitem2 e on pxf.catitempack = e.ItemNumber6 left join SupplyChain_Misc.dbo.rdcategory rd on e.rdcategory = rd.rdcategory
left join (select distinct vendornum, max(vendorname) as VendorName from supplychain_misc.dbo.pic430All group by vendornum) v on a.vendornumber = v.vendornum join SupplyChain_misc.dbo.SeasonOverTime_ForwardCalendar cal on a.transdate = cal.yyyymmdd
 --where a.recorddate is null
 where a.transdate  >= '20150219' --and contractnumber like '%7CL281379%'
-- and e.rdcategory is null
 group by  cal.year_445, cal.month_445, cal.week_445,a.itemnumber, a.vendornumber,a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3),  cast(a.actualdockdate as datetime), i.curspecmatlcost, a.purchaseprice, e.rdcategory, e.sfcategory, rd.division,v.vendorName
 union
select cal.year_445 as year, cal.month_445 as Month, cal.week_445 as Week, a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3) as POLineRel,  cast(a.actualdockdate as datetime) as transdate,a.itemnumber, Sum(a.qtyreceived) as UnitsReceived,i.curspecmatlcost, Sum(i.curSpecMatlCost*a.qtyreceived) as CurSpecMatlCostReceived,  a.purchasePrice, Sum(a.qtyreceived*a.purchaseprice) as UnitCostReceived, 
	e.Rdcategory as RD, e.sfcategory as SFC, rd.Division, a.vendornumber, v.vendorname 
from
(select r.itemnumber, r.vendornumber, r.qtyreceived, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.actualdockdate, r.transdate, r.porecorddate, r.recorddate,  max(i.recorddate) as costrecdate from 
(select itemnumber, vendornumber, qtyreceived, purchaseprice, contractnumber, linenumber, releasenumber, actualdockdate, transdate, porecorddate, recorddate from merch2.[dbo].[vw_ReceiptsHistoryPODetailPurchPrice]) r
 join (select i.itemnumber, i.[CurSpecMatlCost], i.recorddate from bakery.dbo.itemcost i join (Select itemnumber, min(recorddate) as rdate from bakery.dbo.itemcost group by itemnumber) r on i.itemnumber = r.itemnumber and i.recorddate = r.rdate) i on  r.itemnumber = i.itemnumber 
 group by r.itemnumber, r.vendornumber, r.qtyreceived, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.actualdockdate, r.transdate, r.porecorddate, r.recorddate
 ) a  join bakery.dbo.ItemCost i on a.itemnumber = i.itemnumber and a.costrecdate = i.recorddate left join (select compitem, max(catitempack) as catitempack from merch2.dbo.[PxfBillXRefVw] 
group by compitem) pxf on a.itemnumber = pxf.compitem join tempwork.dbo.eabitem2 e on pxf.catitempack = e.ItemNumber6 left join SupplyChain_Misc.dbo.rdcategory rd on e.rdcategory = rd.rdcategory
left join (select distinct vendornum, max(vendorname) as VendorName from supplychain_misc.dbo.pic430All group by vendornum) v on a.vendornumber = v.vendornum join SupplyChain_misc.dbo.SeasonOverTime_ForwardCalendar cal on a.transdate = cal.yyyymmdd
 --where a.recorddate is null
 where a.transdate  >= '20150101' and a.transdate <= '20150218'  --and contractnumber like '%7CL281379%'
-- and e.rdcategory is null
 group by  cal.year_445, cal.month_445, cal.week_445,a.itemnumber, a.vendornumber,a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3),  cast(a.actualdockdate as datetime), i.curspecmatlcost, a.purchaseprice, e.rdcategory, e.sfcategory, rd.division,v.vendorName
 order by cast(a.actualdockdate as datetime)