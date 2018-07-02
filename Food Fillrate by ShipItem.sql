USE [Merch2]
GO
/****** Object:  StoredProcedure [SWISS_COLONY\Dornacker].[FillRateByProduct]    Script Date: 1/30/2017 1:49:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [SWISS_COLONY\Trumpy].[FillRateByShipItem]
	-- Add the parameters for the stored procedure here
	@CalendarSeq as decimal(8,0),
	@Company as char(1),
	@Season as varchar(3),
	@Merch as varchar(25),
	@Buyer as varchar(50)

AS
BEGIN
SET NOCOUNT ON;
    
--If exists
--(select * 
-- from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#temptest'))
--	drop table #temptest
--	SELECT MAX(RecordDate) as RecordDate, ItemNumber, Planner, SchedCatCode
--	INTO #temptest
--	FROM [KIMBALL].bakery.dbo.ItemMaster
--	GROUP BY ItemNumber, Planner, SchedCatCode

Select f.CalendarSeq, f.Year, f.season, f.companycode, f.catalogcodeprefix, Case When f.ItemNumber < 100000 then f.ItemNumber + 600000 else f.ItemNumber + 6000000 End as ItemNumber, Case When i.ConvNumber < 100000 then i.convNumber + 600000 else i.convNumber + 6000000 End as convNumber, f.rdcategory, merchname, f.merchandisercode, f.name, f.vendorcode, f.unitsshipped, f.unitsdemanded, f.dollarsdemanded, 
f.unitsbackordercurrent, f.unitsbackordercummulative, f.unitslost, f.dollarslost, f.unitsshipdelete, f.dollarsshipdelete, f.unitsnotship, f.unitsdeleted, f.unitsshippingdelete, f.unitsnla, c.CompanyDescription, 
r.RDDescription, e.mediagrp, i.VendorName, i.Description
into #ptFillrate
from Merch2.dbo.FillRate_Merge f Join MDW1.dbo.Company c On 
c.Company = f.companycode
Left Join MDW2.dbo.RDCategory r on r.RDCategory = f.rdcategory
Left Join Merch.dbo.eabmedia e On f.catalogcodeprefix = e.catcd and f.Year = e.Year
Left Join MDW1.dbo.Item i On f.year = i.Season and f.catalogcodeprefix = i.PrimaryCatalogCode and f.itemnumber = i.itemnumber
Join ODW1.dbo.FiscalCalendar q on f.CalendarSeq = q.CalendarSeq
where f.CalendarSeq = @CalendarSeq and f.companycode =IsNull(@Company,f.CompanyCode) and f.Season in (@Season) and f.merchname =IsNull(@Merch,f.merchname)  and  IsNull(f.name,'') =IsNull(@Buyer,IsNull(name,''))
AND r.RDCategory < '50' and r.RDCategory != '23' 


select distinct i.ItemNumber, i.catalogcodeprefix, i.Year, x.ShipItemPln, x.ShipQty
		into #ptPackList
	  from #ptFillrate i join Merch2.dbo.F21OfferDaily f on i.Catalogcodeprefix = f.offer_Id and i.year = cast(f.offer_Year as varchar(4))
	   JOIN Merch2.dbo.PxfBillXRefVw x ON x.CatItemPack = i.ItemNumber
	  where f.Season_id in(@Season) 
	   and (CompanyCode in('S','T','F') or RdCategory < '50') and x.RecordType <> 'D'
Union
select distinct i.ItemNumber,i.CatalogCodePRefix, i.Year, x.ShipItemPln, x.ShipQty

	  from #ptFillrate i join Merch2.dbo.F21OfferDaily f on i.CatalogcodePrefix = f.offer_Id and i.YEar = cast(f.offer_Year as varchar(4))
	  LEFT JOIN Merch2.dbo.PxfBillXRefVw x ON x.CatItemPack =  i.convNumber
	   where f.Season_id in(@Season) 
	   and (i.CompanyCode in('S','T','F') or i.RdCategory < '50')  and x.RecordType <> 'D' and i.itemnumber not in (Select x.CatItemPack from Merch2.dbo.PxfBillXRefVw)



select ItemNumber, CatalogCodePrefix, Year, Count(distinct ShipItemPln) as ShipCount 
into #ptShipCount
from #ptPackList
group by itemnumber, catalogCodePrefix, Year

select f.*, p.ShipItemPln, p.ShipQty, i.CIPhysicalCost, s.ShipCount,  i.planner, i.schedcatcode, i.onhandqty, se.sector, i.CIPhysicalCost*ShipQty as ShipCost, i.ItemDescription 
into #ptShipCost
from #ptFillrate f join #ptPacklist p on f.catalogcodeprefix = p.catalogcodeprefix and f.ItemNumber = p.ItemNumber and f.Year = p.year
join #ptShipCount s on f.ItemNumber = s.itemnumber and f.catalogcodeprefix = s.catalogcodeprefix and f.year = s.year
join bakery.dbo.vw_ItemMaster i on p.ShipItemPln = i.ItemNumber 
Left Join SupplyChain_Misc.dbo.Sector se ON se.SchedCategoryCode = i.SchedCatCode
order by Year, CatalogCodePrefix, ItemNumber, ShipITemPln

select sc.itemnumber, sc.catalogcodeprefix, sc.year, sum(ShipCost) as PackCost
into #ptPackCost
from #ptShipCost sc
group by sc.itemnumber, sc.catalogcodeprefix, sc.year

select sc.*, pc.PackCost, case when pc.PackCost = 0 then 0 else sc.ShipCost/pc.PackCost End as PctTotCost
into #ptEnd
from #ptShipCost sc join #ptPackCost pc on sc.itemnumber = pc.itemNumber and sc.catalogcodeprefix = pc.catalogcodeprefix and sc.Year = pc.Year


select calendarSeq, Year, season, companycode, catalogcodeprefix, itemnumber, convnumber, rdcategory, merchname, merchandisercode, name, vendorcode, unitsshipped*Shipqty as unitsshipped, unitsdemanded * ShipQty as unitsdemanded,
dollarsdemanded * PctTotCost as dollarsdemanded, unitsbackordercurrent * ShipQty as unitsbackordercurrent, unitsbackordercummulative * ShipQty as unitsbackordercummulative, unitslost * ShipQty as unitslost, dollarslost * PctTotCost as dollarslost,
unitsshipdelete*ShipQty as unitsshipdelete, dollarsshipdelete * PctTotCost as dollarsshipdelete, unitsnotship*ShipQty as unitsnotship, unitsdeleted * ShipQty as unitsdeleted, unitsshippingdelete * ShipQty as unitsshippingdelete, unitsnla*ShipQty as unitsnla,
CompanyDescription, rdDescription, mediagrp, vendorname, ShipItemPln, ShipQty, ciPhysicalCost, ShipCount, planner, schedcatcode, onhandqty, sector, ShipCost, PackCost, PctTotCost, ItemDescription 
into #ptFillrateShip
from #ptEnd 

Select CalendarSeq, Year, Season, CompanyCode, CompanyDescription, ShipItemPln as Ship, ItemDescription, rdcategory, rddescription, merchname, merchandisercode, name, vendorcode, vendorname, planner, schedcatcode, sector, Sum(unitsshipped)as UnitsShipped, Sum(unitsdemanded) as unitsdemanded,
Sum(dollarsdemanded) as dollarsdemanded, Sum(unitsbackordercurrent) as unitsbackordercurrent, Sum(unitsbackordercummulative) as unitsbackordercummulative, Sum(unitslost) as unitslost, sum(dollarslost) as dollarslost,
Sum(unitsshipdelete) as unitsshipdelete, Sum(dollarsshipdelete) as dollarsshipdelete, Sum(unitsnotship) as unitsnotship, Sum(unitsdeleted) as unitsdeleted, sum(unitsshippingdelete) as unitsshippingdelete, Sum(unitsnla) as unitsnla, min(onhandqty) as onhandqty
from #ptFillrateShip
group by CalendarSeq, Year, Season, CompanyCode, CompanyDescription, ShipItemPln, ItemDescription, rdcategory, rddescription, merchname, merchandisercode, name, vendorcode, vendorname, planner, schedcatcode, sector

END