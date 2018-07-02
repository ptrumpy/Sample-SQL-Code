
--Get info on offers involved in study
-- and go back two years earlier to collect historical listing and performance info for model attributes


--Get unique Item ID by concatenating itemnumber and description
drop table #newitemids
select distinct(a.season),  a.itemnumber,  a.description, itemnumber+description as newitemid, RDCategory + SfCategory as RDSFC
into #newitemids
from mdw1.dbo.item a
--(1979039 row(s) affected)

--Append information from item table to item IDs on pricing, costs, page location, categorization, etc
drop table #pwtiteminfo
select a.season, b.seasonflag, a.itemnumber, c.newitemid, a.primarycatalogcode, a.retailprice1, a.retailprice2, a.unitcost, a.pagenumber, a.percentspace, a.sfcategory, a.rdcategory, 
       a.retailprice1-a.grossprofit as gpcosts, a.retailprice1-a.operatingprofit as opcosts, a.buyercode, a.importcode, a.combinablecode,
	   a.originalcompanycode,
	   case when  a.FinalSalesQuantity = 0 then a.actqty else a.FinalSalesQuantity  end as FinalSalesQuantity, 
	   case when  a.finalsalesdollars = 0 then a.actsales else a.finalsalesdollars  end as finalsalesdollars 	  
into #pwtiteminfo
from (mdw1.dbo.item a inner join mdw1.dbo.catalogcodes b on a.primarycatalogcode = b.catalog and a.season = b.mailyear)
left join #newitemids c on a.season = c.season and a.itemnumber = c.itemnumber
where a.season in('2007','2008','2009','2010','2011','2012','2013') --and b.companycode in('W')
--(986875 row(s) affected) (checks out as distinct by season, primarycatalogcode, newitemid ) 

-- Check that item IDs are fully populated - should be zero count
select count(*) from #pwtiteminfo
  where newitemid is null 
--0

-- Find catalog codes that appear in Adcode table and summarize circulation for mailings only 
drop table #pwtcatalogcirc
select season, mailseason, companycode, catalog, 
       min(case when substring(releasedate,5,4) not in('0701','0101') then releasedate else '99999999' end) as releasedate,
	   sum(actualqty) as circulation,
	   sum(case when buyertype in('B','C') then actualqty else 0 end) as buyercirc,
	   sum(case when buyertype in('X','0','1','2','3','4','5','6','7','8','9') then actualqty else 0 end) as crosscirc,
	   sum(case when buyertype in('P','W') then actualqty else 0 end) as promocirc,
	   sum(budspu*actualqty) as budgetsales
into #pwtcatalogcirc
from mdw1.dbo.adcode 
where companycode not in('T') and actualqty > 0 and 
    not (companycode = 'S' and catalog = 'AH' and mailseason = 'S' and season = '2013') and 
   season in('2007','2008','2009','2010','2011','2012','2013') and
   substring(advcode,1,2) not in('99','1Z')
group by season, mailseason, companycode, catalog
--(907 row(s) affected)

/*
select * from #pwtcatalogcirc
where companycode = '7' and season = '2010'
order by season, catalog

select * from mdw1.dbo.adcode 
where companycode = '7' and season = '2010'
 and releasedate = '20100616' 
 

drop table #mrmcheck2
select season, companycode, catalog, count(*) as records
into #mrmcheck2
from #pwtcatalogcirc
group by season, companycode, catalog

select records, count(*) as counts
from #mrmcheck2 
group by records
order by records 

select a.*
from #pwtcatalogcirc a inner join  #mrmcheck2 b
on a.season = b.season and a.companycode = b.companycode and a.catalog = b.catalog
where b.records = 2 
order by a.season, a.companycode, a.catalog
*/


-- Merge item info and circulation history 
drop table #pwtitemcatalog
select a.*,
       b.companycode, b.mailseason, b.releasedate, b.circulation, b.buyercirc, b.crosscirc, b.promocirc, b.budgetsales
into #pwtitemcatalog 
from #pwtiteminfo a left join #pwtcatalogcirc b on a.season = b.season and a.primarycatalogcode = b.catalog 
--(986875 row(s) affected)  

select top 10 * from #pwtitemcatalog

-- Build line prefix groups from item table
drop table #pwtcatalogtype
select mailyear, catalog, companycode, seasonflag, typeflag, description,
   case 
     when typeflag = 'C' then 'Catalog'
	 when typeflag = 'I' and description like '%WEB SITE%' then 'Internet-Main'
	 when typeflag = 'I' and (description like '%PRODUCT%' or description like '%SPECIAL%' or description like '%WEB STUFFER%'
	                          or description like '%INTERNET%') then 'Internet-Product'
	 when typeflag = 'I' and description like '%MEGA%' then 'Internet-Mega'
	 when typeflag = 'S' then 'Statement' 
	 when typeflag = 'U' then 'Upsell'
	 else 'Unknown'
	end as catalogtype 
into #pwtcatalogtype
from mdw1.dbo.catalogcodes
where mailyear in('2007','2008','2009','2010','2011','2012','2013') --and companycode in('W')
--(2657 row(s) affected)

-- merge on line prefix type to item tables
-- this table is item info and circ stats of the primarcatalogcode merged with catalog type info
drop table #pwtitemcatalogtype 
select a.*, b.seasonflag as catalogseasonflag, b.typeflag, b.catalogtype, b.description
into #pwtitemcatalogtype
from #pwtitemcatalog a left join #pwtcatalogtype b on a.primarycatalogcode = b.catalog and a.season = b.mailyear
--(986875 row(s) affected)

select top 10 * from #pwtitemcatalogtype

-- Now remerge item table to itself to get history of item
-- build some crude measures of performance
-- for catalog offers only
-- first get catalog totals for indexes
drop table #pwtcatalogtotal
select season, seasonflag, primarycatalogcode,
   max(case when pagenumber between '001' and '350' then pagenumber else '000' end) as tot_pages,
   sum(finalsalesquantity) as tot_quantity,
   sum(finalsalesdollars) as tot_dollars
into #pwtcatalogtotal
from #pwtitemcatalogtype
where catalogtype = 'Catalog' 
group by season, seasonflag, primarycatalogcode
-- (618 row(s) affected)

-- get prior activity by item
-- first make copy of #pwtitemcatalogtype including only catalog offers with valid releasedates
drop table #pwtitemcatalogtype_equal_catalog_only
select * 
into #pwtitemcatalogtype_equal_catalog_only
from #pwtitemcatalogtype
where catalogtype = 'Catalog' and releasedate < '99999999'
--(264323 row(s) affected)

select top 1000  * from #pwtitemcatalogtype_equal_catalog_only  

-- Join table of items appearing in catalogs back to itself by item ID to find prior listings of item 
-- and to totals for catalogs to get totals for offer item appears within
drop table #pwtitempriorhistory 
select a.season, a.seasonflag, a.itemnumber, a.newitemid, a.primarycatalogcode, a.releasedate,
    min(b.releasedate) as firstreleasedate,
	max(b.releasedate) as lastreleasedate, 
	--count(b.itemnumber) as priorlistings,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then 1 else 0 end) as priorlistings,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then b.percentspace/100 else 0 end) as prior_pagespace,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then b.finalsalesquantity else 0 end) as prior_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then b.finalsalesdollars else 0 end) as prior_sales,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and isnumeric(c.tot_pages) = 1 then cast (c.tot_pages as integer) else 0 end ) as prior_tot_pages,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then c.tot_quantity else 0 end) as prior_tot_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 then c.tot_dollars else 0 end) as prior_tot_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 then b.percentspace/100 else 0 end) as prior_6m_pagespace,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 then b.finalsalesquantity else 0 end) as prior_6m_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 then b.finalsalesdollars else 0 end) as prior_6m_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 and isnumeric(c.tot_pages) = 1 then cast (c.tot_pages as integer) else 0 end ) as prior_6m_tot_pages,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 then c.tot_quantity else 0 end) as prior_6m_tot_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 183 then c.tot_dollars else 0 end) as prior_6m_tot_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 then b.percentspace/100 else 0 end) as prior_12m_pagespace,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 then b.finalsalesquantity else 0 end) as prior_12m_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 then b.finalsalesdollars else 0 end) as prior_12m_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 and isnumeric(c.tot_pages) = 1 then cast (c.tot_pages as integer) else 0 end ) as prior_12m_tot_pages,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 then c.tot_quantity else 0 end) as prior_12m_tot_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 365 then c.tot_dollars else 0 end) as prior_12m_tot_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 then b.percentspace/100 else 0 end) as prior_24m_pagespace,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 then b.finalsalesquantity else 0 end) as prior_24m_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 then b.finalsalesdollars else 0 end) as prior_24m_dollars,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 and isnumeric(c.tot_pages) = 1 then cast (c.tot_pages as integer) else 0 end )  as prior_24m_tot_pages,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 then c.tot_quantity else 0 end) as prior_24m_tot_quantity,
	sum(case when datediff(day,b.releasedate,a.releasedate) > 0 and datediff(day,b.releasedate,a.releasedate) < 730 then c.tot_dollars else 0 end) as prior_24m_tot_dollars
into #pwtitempriorhistory
from #pwtitemcatalogtype_equal_catalog_only a left join 
	    #pwtitemcatalogtype_equal_catalog_only b on b.newitemid = a.newitemid and a.releasedate >= b.releasedate
		    inner join #pwtcatalogtotal c on b.season = c.season and b.seasonflag = c.seasonflag and b.primarycatalogcode = c.primarycatalogcode
group by a.season, a.seasonflag, a.itemnumber, a.newitemid, a.primarycatalogcode, a.releasedate
--(264323 row(s) affected)


 
--- join history to item definition file

drop table #pwtitemfinal
select a.*, 
       b.firstreleasedate, b.lastreleasedate, b.priorlistings, b.prior_pagespace, b.prior_quantity, b.prior_sales, 
	   b.prior_tot_pages, b.prior_tot_quantity, b.prior_tot_dollars,
	   b.prior_6m_pagespace, b.prior_6m_quantity, b.prior_6m_dollars, b.prior_6m_tot_pages, b.prior_6m_tot_quantity, b.prior_6m_tot_dollars,
	   b.prior_12m_pagespace, b.prior_12m_quantity, b.prior_12m_dollars, b.prior_12m_tot_pages, b.prior_12m_tot_quantity, b.prior_12m_tot_dollars,
	   b.prior_24m_pagespace, b.prior_24m_quantity, b.prior_24m_dollars, b.prior_24m_tot_pages, b.prior_24m_tot_quantity, b.prior_24m_tot_dollars,
	   c.tot_pages 
into #pwtitemfinal
from #pwtitemcatalogtype a left join #pwtitempriorhistory b on a.season = b.season and a.primarycatalogcode = b.primarycatalogcode and a.itemnumber = b.itemnumber 
       left join #pwtcatalogtotal c on a.season = c.season and a.seasonflag = c.seasonflag and a.primarycatalogcode = c.primarycatalogcode 
--(986875 row(s) affected) 

select count(*) from #pwtitemfinal where newitemid is null 
--0 

select top 100 * from #pwtitemfinal
-- this currently needed to get other company internet main items in separate program. 
drop table tempwork.dbo.pwtitemfinal
select *
into tempwork.dbo.pwtitemfinal
from #pwtitemfinal
--(986875 row(s) affected)

---****************** TO HERE HAVE WORKED ONLY WITH ITEM AND CATALOG TYPES AND CIRC.  NOW START LOOKING AT ORDERS AND LINEITEMS
select * from #pwtitemfinal where primarycatalogcode = 'VV' order by itemnumber, season
select top 100 * from mdw1.dbo.ordersall
select top 100 * from mdw1.dbo.orderlineall


-- Get Demand by itemnumber, season, order catalog and line prefix and whether or not item appeared in order catalog	
drop table #pwtitemsales
select a.accountnumber, a.ordernumber, a.foedate, a.companycode, a.catalog, a.advcodeyear, a.receiveddate, 
   case 
	   when buyertype in('B','C') then 'B'
	   when buyertype in('X','0','1','2','3','4','5','6','7','8','9') then 'X'
	   when buyertype in('P','W') then 'P' 
	   else 'O'
   end as btype,
   b.catalogcodeprefix, b.itemnumber, b.season,
   Case When c.RdCategory + c.SfCategory is null then d.RDSFC else c.RDCategory + c.SfCategory end as RDSFC,
   case when isnull(c.seasonflag,'X') in('S','F') then 1 else 0 end as itemincatalog,
   b.itemqty, 
   b.itemqty*b.unitprice as itemsls,
   b.addresssequence, b.linesequence, b.notavailableflag, b.backorderedflag, b.shippedflag , d.newitemid 
into #pwtitemsales
from mdw1.dbo.ordersall a inner join mdw1.dbo.orderlineall b on a.accountnumber = b.accountnumber and a.ordernumber = b.ordernumber
   left join #pwtitemfinal c on b.itemnumber = c.itemnumber 
   and a.catalog = c.primarycatalogcode 
   and a.advcodeyear = c.season
   left join #newitemids d on b.catalogyear = d.season and b.itemnumber = d.itemnumber 
where a.orderstatus = 'F' --and a.companycode in('W') 
and a.advcodeyear in('2009','2010','2011','2012','2013')
--(718082 row(s) affected) (77678366 row(s) affected)

--Get Default Catalogs using buyertype and mail qty
drop table #pwtrawlist
select season, companycode, catalog, min(releasedate) as releasedate, sum(actualqty) as actualqty
into #pwtrawlist
from mdw1.dbo.adcode 
where season >= '2008' and buyertype in('B','C','X') 
   and substring(advcode,1,1) <> '9' and testcontrol in('C',' ') 
   and not (season = '2008' and catalog = 'AG')  -- test booked marked as control
   and not (season = '2013' and catalog = 'SG')  -- SG includes a lot of product from other books - revisit this if product will be purchased for SG exclusively
   and releasedate is not null
group by season,  companycode, catalog
order by releasedate
--(416 row(s) affected)


Drop table #ptCatDefaults
select a.*, b.typeflag, b.season as season2, b.description, b.pricedefinition
into #ptCatDefaults
from #pwtrawlist a inner join mdw1.dbo.catalogcodes b on a.catalog = b.catalog and a.season = b.mailyear 
where b.description not like '%PROMO%' and b.description not like '%PROTI%' and b.typeflag = 'C' and a.actualqty > 10000 and a.companycode >= '7'
order by companycode, season, releasedate
--(276 row(s) affected)

select * from #ptCatDefaults where CompanyCode = 'G' and Season = 2013

--Build table to assign default catalog
drop table #pwtitemtiming 
select i.season, i.seasonflag, itemnumber, newitemid, primarycatalogcode, i.releasedate, catalogtype, i.description, c.CompanyCode
into #pwtitemtiming
from #pwtitemfinal i inner Join #ptCatDefaults c on  i.Season = c.season and i.PrimaryCatalogCode = c.catalog
where c.releasedate is not null 
--from #pwtitemfinal i Left Join #ptCatDefaults c on  i.Season = c.season and i.PrimaryCatalogCode = c.catalog
--(174498 row(s) affected) (174498 row(s) affected)

/*
drop table #mrmcheck3
select newitemid, releasedate, companycode, count(*) as records
into #mrmcheck3
from #pwtitemtiming
group by newitemid, releasedate, companycode


select records, count(*) as counts 
from #mrmcheck3
group by records
order by records 

select top 1000 * from #mrmcheck3 
where records > 1 

select releasedate, companycode, count(*) as dupitems
from #mrmcheck3
where records > 1 
group by releasedate, companycode
order by releasedate, companycode


select * from
#pwtitemtiming
--where newitemid =  '004538614K/SS DIAM CRSS RNG'
where newitemid =  '0000400JOLLY TOPPER TOWER  ' 
order by releasedate
*/




--Find most recent appearance of item in a default catalog before order
drop table #pwtitemlast
select a.accountnumber, a.ordernumber, a.companycode, a.catalog, a.advcodeyear, a.receiveddate, a.catalogcodeprefix, a.itemnumber, b.newitemid, a.season, a.itemincatalog,
      max(b.releasedate) as releasedate, a.RDSFC
into #pwtitemlast
from #pwtitemsales a inner join #pwtitemtiming b on a.newitemid = b.newitemid and a.CompanyCode = b.CompanyCode
where b.releasedate < a.receiveddate
group by a.accountnumber, a.ordernumber,a.companycode, a.catalog, a.advcodeyear, a.receiveddate, a.catalogcodeprefix, a.itemnumber, b.newitemid, a.season, a.itemincatalog, a.RDSFC
--(536292 row(s) affected) (53255379 row(s) affected)
select top 10 * from #pwtitemlast

-- and append information regarding it to record
drop table #pwtitemdefault
select a.*, b.season as defaultseason, b.primarycatalogcode as defaultcatalogcode
into #pwtitemdefault
from #pwtitemlast a inner join #pwtitemtiming b on a.newitemid = b.newitemid and a.releasedate = b.releasedate and a.CompanyCode = b.CompanyCode
--(536292 row(s) affected) (53255379 row(s) affected)
select top 100 * from #pwtitemdefault 


-- join defaults to line detail
drop table #pwtitemsalesdefault
select a.*, b.defaultseason, b.defaultcatalogcode
into #pwtitemsalesdefault
from #pwtitemsales a left join #pwtitemdefault b on a.accountnumber = b.accountnumber and a.ordernumber = b.ordernumber and
   a.catalog = b.catalog and a.advcodeyear = b.advcodeyear and a.receiveddate = b.receiveddate and
   a.catalogcodeprefix = b.catalogcodeprefix and a.itemnumber = b.itemnumber  and a.season = b.season
--((718084 row(s) affected) - count up from 718082?? (77678418 row(s) affected)

-- add itemindefaultcatalog flag
drop table #pwtitemsalesfinal
select a.*,
   case when isnull(c.seasonflag,'X') in('S','F') then 1 else 0 end as itemindefaultcatalog
into #pwtitemsalesfinal
from #pwtitemsalesdefault a
   left join #pwtitemfinal c on a.newitemid = c.newitemid and a.defaultcatalogcode = c.primarycatalogcode and a.defaultseason = c.season
--(718084 row(s) affected) (77678418 row(s) affected)
select * from #pwtitemsalesfinal where  ordernumber = '12491126'
-- Add line prefix groups and item info to demand file 
drop table #pwtitemsalesdetail
select a.*, 
   case when b.companycode = a.companycode then b.catalogtype else 'Unknown' end as linetype, 
   c.seasonflag, c.catalogtype as ordertype,
   cast(a.season as int) - cast(a.defaultseason as int) as diffyears
into #pwtitemsalesdetail 
from #pwtitemsalesfinal a left join #pwtcatalogtype b on a.catalogcodeprefix = b.catalog and a.season = b.mailyear
       left join #pwtcatalogtype c on a.catalog = c.catalog and a.advcodeyear = c.mailyear        
--(718084 row(s) affected) (77678418 row(s) affected)
--select * from #pwtitemsalesdetail where catalogcodeprefix = 'ZN' and season = 2013 and linetype !='Internet-Mega'
--select top 100 * from #pwtitemsalesdetail where itemindefaultcatalog = 1 and diffyears > 1
select * from #pwtitemsalesdetail where  ordernumber = '12491126'
-- Apply rules to data to develop linecatalog, lineseason, and ruleused 
drop table tempwork.dbo.pwtitemsalesdetailfinal_w_v2
select a.*, WeekInCalendarYear as Week, 
   case 
      when a.linetype = 'Catalog' then catalogcodeprefix
	  when a.ordertype = 'Catalog'  and itemincatalog = 1 then catalog 
	  when a.itemindefaultcatalog = 1  then defaultcatalogcode
	  when a.linetype = 'Internet-Mega' then a.CompanyCode + '$'
	  else a.CompanyCode + '%'
   end as linecatalog ,
   --when typeflag = 'I' and description like '%MEGA%' then 'Internet-Mega'
   case 
      when a.linetype = 'Catalog' then a.season
	  when a.ordertype = 'Catalog' and itemincatalog = 1 then advcodeyear
	  when a.itemindefaultcatalog = 1  then defaultseason
	  when a.linetype = 'Internet-Mega' then a.season
	  else a.season
   end as lineseason ,
   case 
      when a.linetype = 'Upsell' then '06'
      when a.linetype = 'Catalog' then '01'
	  when a.ordertype = 'Catalog'  and itemincatalog = 1 then '02'
	  when a.itemindefaultcatalog = 1 --and diffyears < 2 
	  then '03'
	  when a.linetype = 'Internet-Mega' then '04'
	  else '05'
   end as ruleused
into tempwork.dbo.pwtitemsalesdetailfinal_w_v2 
from  #pwtitemsalesdetail a Join mdw1.dbo.Calendar b on b.DayDate = (Cast(a.FoeDate as smalldatetime))
--(718084 row(s) affected) (77678418 row(s) affected)

select * from  tempwork.dbo.pwtitemsalesdetailfinal_w_v2 where ordernumber = '12491126'


select LineSeason, Week, RuleUsed, CatalogCodePrefix as Traditional, Catalog as OrderLevel,  LineCatalog as Catalog,  Max(RDSFC) as RDSFC, itemnumber,  Sum(itemqty) as Qty, Sum(itemsls) as Dollars 
from   tempwork.dbo.pwtitemsalesdetailfinal_w_v2 
where --advcodeyear != season
--and
LineSeason in(2013) --and DefaultCatalogCode in ('JJ','JB','JK','JM') 
and CompanyCode = 'G'
group by LineSeason, Week, RuleUsed,  ItemNumber, Catalog, CatalogCodePrefix, LineCatalog
order by LineSeason, Week, RuleUsed



