USE [SupplyChain_Misc]
GO
/****** Object:  StoredProcedure [dbo].[FoodUpsell]    Script Date: 7/3/2018 9:38:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Phil Trumpy>
-- Create date: <10/20/2016>
-- Description:	<Food Upsell report>
-- =============================================
ALTER PROCEDURE [dbo].[FoodUpsell] 
	-- Add the parameters for the stored procedure here
	@Date Date,
	@Season varchar(3),
	@Season2 varchar(3),
	@DueDate Date
	

AS
BEGIN
Declare @LocalDate Date
Declare @CurrentDate date
Declare @DueDateLocal date
	
Set @LocalDate = @Date
Set @CurrentDate = DateAdd(day,1,@LocalDate)
Set @DueDateLocal = @DueDate
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	select distinct a.itemnumber,
	 Case When Month(@CurrentDate) between 7 and 12 then 
		Case
			when a.PrimaryCatalogCode = 'AG' then pgpkillcode
			when a.PrimaryCatalogCode = 'RG' then pgpkillcode
			when a.PrimaryCatalogCode = 'FA' then pgpkillcode
			when a.PrimaryCatalogCode = 'YY' then pgpkillcOde
		Else ''
		END
	 When Month(@CurrentDate) between 1 and 6 then
		Case
			when a.PrimaryCatalogCode= 'BA' then pgpkillcode
			when a.PrimaryCatalogCode= 'BD' then pgpkillcode
			when a.PrimaryCatalogCode= 'BF' then pgpkillcode
			when a.PrimaryCatalogCode= 'BG' then pgpkillcode
			when a.PrimaryCatalogCode= 'FR' then pgpkillcode
			when a.PrimaryCatalogCode= 'YY' then pgpkillcode
		Else ''	 
		End
	End as KWO,
	Case When Month(@CurrentDate) between 7 and 12 then 
		Case
			when a.PrimaryCatalogCode = 'AG' then PageNumber
			when a.PrimaryCatalogCode = 'RG' then PageNumber
			when a.PrimaryCatalogCode = 'FA' then PageNumber
			when a.PrimaryCatalogCode = 'YY' then PageNumber
		Else ''
		END
	 When Month(@CurrentDate) between 1 and 6 then
		Case
			when a.PrimaryCatalogCode= 'BA' then PageNumber
			when a.PrimaryCatalogCode= 'BD' then PageNumber
			when a.PrimaryCatalogCode= 'BF' then PageNumber
			when a.PrimaryCatalogCode= 'BG' then PageNumber
			when a.PrimaryCatalogCode= 'FR' then PageNumber
			when a.PrimaryCatalogCode= 'YY' then PageNumber
		Else ''
		End
	End as Page
		into #ptKWOPage
		from mdw1.dbo.Item a inner join
 Merch2.dbo.F21OfferDaily f on a.PrimaryCatalogcode = f.offer_Id and a.season = f.offer_Year
	  where f.Season_id = @Season 
	   and (CompanyCode in('S','T','F') or RdCategory < 50)
	   --(3019 row(s) affected) 00:00:00

	   --select count(*) from #ptKWOPage
--Get Max Date of Records from PXF
SELECT        CatItemPack, SetItem, ShipItemPln, CompItem, MAX(RecordDate) AS Rdate
into #ptMaxPXFDate
FROM            merch2.dbo.PxfBillXref
GROUP BY CatItemPack, SetItem, ShipItemPln, CompItem

--Select Records that match the max record date from #ptMaxPXFDate
SELECT        a.RecordType, a.RecordDate, a.CatItemPack, a.SetItem, a.ShipItemPln, a.CompItem, a.VendorNumber, a.ShipRetailPct, a.ShipQty, a.CompDualShipCnt, 
                         a.DualShipPack, a.ActiveCatFlag, a.BuyerDiv, a.FoodConvPack, a.CountryName, a.SkuSeq, a.ShipLocDiv, a.CompPiClass, a.ShipInEffectDate, a.ShipTextCode, 
                         a.CompType, a.CompUsage, a.CompBOMQty, a.CompIssueCtl, a.CompInEffectDate, a.PickUpCatyear, a.ShipInRevisionLevel, a.CompInRevisionLevel, 
                         a.CompImportClass, a.CompOriginCode, a.CompFollowupDays, a.CompPidTextId, a.CompPinTextId
INTO #ptPXF
FROM            merch2.dbo.PxfBillXref AS a INNER JOIN #ptMaxPXFDate b 
                              ON a.CatItemPack = b.CatItemPack AND a.SetItem = b.SetItem AND 
                         a.ShipItemPln = b.ShipItemPln AND a.CompItem = b.CompItem AND a.RecordDate = b.Rdate	   

--get sales at pack and sku and sum up
select distinct season,x.CatItemPack, convnumber as itemnumber, x.ShipItemPln, GrossProfit, 
Case When x.shipQty = 0 then EstFinalQty*x.ShipRetailPct ELSE EstFinalQty*x.ShipQty End as TotEst, 
CASE WHEN x.shipQty = 0 THEN ActQty*x.ShipRetailPct ELSE ActQty*x.ShipQty End as TotSales
	  into #ptSales
	  from mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.PrimaryCatalogcode = f.offer_Id and i.season = cast(f.offer_Year as varchar(4))
	  LEFT JOIN #ptPXF x ON x.CatItemPack = '6' + case when left(i.ItemNumber,2) = '00' then Right(i.ItemNumber,5) else right(i.ItemNumber,6) end
	  where f.Season_id in(@Season, @Season2) 
	   and (CompanyCode in('S','T','F') or RdCategory < '50') and x.ActiveCatFlag = 'A'
Union
select distinct i.season,x.CatItemPack, i.convnumber, x.ShipItemPln, i.GrossProfit, 
Case When x.shipQty = 0 then i.EstFinalQty*x.ShipRetailPct ELSE i.EstFinalQty*x.ShipQty End as TotEst,
CASE WHEN x.shipQty = 0 THEN i.ActQty*x.ShipRetailPct ELSE i.ActQty*x.ShipQty End as TotSales
	  from mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.PrimaryCatalogcode = f.offer_Id and i.season = cast(f.offer_Year as varchar(4))
	  LEFT JOIN #ptPXF x ON x.CatItemPack =  '6' + case when left(i.convNumber,2) = '00' then Right(i.convNumber,5) else right(i.convNumber,6) end
	  left join mdw1.dbo.item i2 on i.itemNumber = i2.itemnumber AND i.ConvNumber = i2.ConvNumber 
	  where f.Season_id in('F16','S17') 
	   and (i.CompanyCode in('S','T','F') or i.RdCategory < '50') and x.ActiveCatFlag = 'A' and i.Itemnumber <> i.ConvNumber and x.CatItemPack <> x.ShipItemPln
--(7930 row(s) affected) 00:00:09

--Select count(*) from #ptSales
SELECT CatItemPack, SetItem, ShipItemPln, CompItem, MAX(RecordDate) AS Rdate
into #ptXrefMaxDate
FROM merch2.dbo.PxfBillXref
GROUP BY CatItemPack, SetItem, ShipItemPln, CompItem


Select a.CatItemPack, a.ShipItemPln, a.ActiveCatFlag 
into #ptXref
from merch2.dbo.pxfbillxref a join
#ptXrefMaxDate b
on a.CatItemPack = b.catItempack and a.SetItem = b. SetItem and a.ShipItemPLN = b.ShipItemPln and a.CompItem = b.CompItem and a.RecordDate = b.RDate
where a.ActiveCatFlag = 'A'

SELECT    ItemNumber, MAX(RecordDate) AS Mdate
into #ptMaxIM
FROM  bakery.dbo.ItemMaster
GROUP BY ItemNumber

select a.* 
into #ptIM
from bakery.dbo.ItemMaster a join #ptMaxIM b on a.Itemnumber = b.ItemNumber and a.RecordDate = b.MDate 


select CatItemPack, ItemNumber, OnHandQty, OnHandQty*ciPhysicalCost as OnHandDollars
	  into #ptOH
	  from #ptIM i 
	  LEFT JOIN #ptXref x ON x.CatItemPack = i.ItemNumber
	  where ActiveCatFlag = 'A'
Union
select CatItemPack, itemnumber,OnHandQty, OnHandQty*ciPhysicalCost as OnHandDollars
	  from #ptIM i
	  LEFT JOIN #ptXref x ON x.ShipItemPln = ItemNumber
	  where  x.CatItemPack <> x.ShipItemPln and ActiveCatFlag = 'A'
	  
	  --(173232 row(s) affected) 00:00:12

	 -- Select count(*) from #ptOH

--get max Rec Date by item for ItemDaily
select season,itemnumber,primarycatalogcode,max(i.recorddate) as Mdate
into #ptMaxRecDate
	  from mdw1.dbo.ItemDaily i join Merch2.dbo.F21OfferDaily f on rtrim(i.PrimaryCatalogcode) = f.offer_Id and i.season = (cast(f.offer_Year as varchar(4)))
	  where cast(left(i.recorddate,11) as datetime) <= @CurrentDate and f.Season_id = @Season
	  and f.Media_ID = 'UPS' and i.UpsellType in ('A','E','P','R')
	   and (CompanyCode in('S','T','F') or RdCategory < '50') 
	  group by season,itemnumber,primarycatalogcode
	  --(128 row(s) affected) 00:00:45

	  --select count(*) from #ptMaxRecDate
--get previous day's sales
select a.CompanyCode, b.itemnumber,sum(isnull(itemqty,0)) as DailySalesUnits, Sum(isnull(itemqty,0)*UnitPrice) as DailySalesDollars
into #ptDailySales
from mdw1.dbo.currentorders a inner join mdw1.dbo.currentorderlines b on a.accountnumber=b.accountnumber and a.ordernumber=b.ordernumber and b.addresssequence!='000'
join Merch2.dbo.F21OfferDaily f on b.CatalogcodePrefix = f.offer_Id and b.CatalogYear = (cast(f.offer_Year as varchar(4)))
left join Mdw1.dbo.Item i on b.CatalogCodePrefix = i.PrimaryCatalogCode and b.CatalogYear = i.Season and b.itemNumber = i.ItemNumber
where-- cast(left(i.recorddate,11) as datetime) <= @CurrentDate and 
f.Season_id = @Season
and a.orderstatus = 'F' and b.notavailableflag='0' --and b.itemnumber='0001461'
and f.Media_ID = 'UPS' and (a.CompanyCode in('S','T','F') or RdCategory < '50') and a.FoeDate = cast(year(@LocalDate) as varchar(4)) +  Right('0' + cast(Month(@LocalDate) as varchar(2)),2) + Right('0' + cast(day(@LocalDate) as varchar(2)),2)
group by a.companycode,b.itemnumber
--(40 row(s) affected) 00:00:02

--Select count(*) from #ptDailySales
SELECT PartNum, SUM(OrdQty) - SUM(QtyRcvd) AS Mfg_Ord
INTO #ptMfgOrder
FROM SupplyChain_Misc.dbo.PIC705 p
--RIGHT  JOIN #UnitsPerOfferShipItem u ON u.CatItemPack = p.PartNum
WHERE Convert(Date,DueDate) <= @DueDateLocal
GROUP BY PartNum

select isnull(s.Sector,'') as Sector, a.CompanyCode, Case when food.FoodBook = 'Y' and nonfood.NonFoodBook = 'Y' then 'B'
	When food.FoodBook= 'Y' and nonfood.NonFoodBook is null then 'F'
	When nonfood.NonFoodBook = 'Y' and food.FoodBook is null then 'N' End as CompanyType, 
'6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end as OrderablePack,
 '6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end as ShipNumber,     im.SchedCatCode, im.ShelfLife, Max(k.KWO) as KWO, Max(k.Page) as Page, a.Description, Min(a.UpsellType) as Code, 
 im.CIPhysicalCost as UnitCost, a.RetailPrice1 as Retail, OH.OnHandQty as OHUnits, OH.OnHandDollars as OHDollarsAtCost, c.DailySAlesUnits, c.DailySalesDollars,im.TotOnOrder, Est.TotEst, Est.TotSales, 
 Max(a.ActQty)as YTDSalesUnits, Max(a.ActSales) as YTDSalesDollars, Max(isnull(mfg_ord,0)) as Mfg_ord, p.UnShippedQty                                    
from mdw1.dbo.ItemDaily a inner join #ptMaxRecDate b on a.season=b.season and a.itemnumber=b.itemnumber and a.primarycatalogcode=b.primarycatalogcode and a.RecordDate=b.Mdate
Join bakery.dbo.vw_ItemMaster im on ('6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end) = im.ItemNumber 
left Join SupplyChain_Misc.dbo.Sector s on im.SchedCatCode = s.SchedCategoryCode
LEFT JOIN SupplyChain_Misc.dbo.PIC830 p ON p.PackNum = ('6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end)
Left Join (Select CatItempack, Sum(OnHandQty) as OnHandQty, Sum(OnHandDollars) as OnHandDollars
from #ptOH
group by CatItemPack) OH on ('6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end) = OH.CatItemPack
LEFT join #ptKWOPage k on a.ItemNumber = k.ItemNumber
	  left Join #ptDailySales c on a.ItemNumber = c.ItemNumber and a.companycode = c.companycode
left join (select distinct itemnumber, 'Y' as FoodBook from Mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.primaryCatalogcode = f.offer_Id and i.Season = (cast(f.offer_Year as varchar(4)))
where-- cast(left(i.recorddate,11) as datetime) <= @CurrentDate and 
f.Season_id = @Season
and f.Media_ID = 'UPS' and i.CompanyCode in('S','T','F')) as Food on a.itemnumber = food.itemnumber
left join (select distinct itemnumber, 'Y' as NonFoodBook from Mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.primaryCatalogcode = f.offer_Id and i.Season = (cast(f.offer_Year as varchar(4)))
where-- cast(left(i.recorddate,11) as datetime) <= @CurrentDate and 
f.Season_id = @Season
and f.Media_ID = 'UPS' and i.CompanyCode not in('S','T','F') and i.RdCategory < 50) nonfood on a.itemnumber = nonfood.itemnumber
left join (select ShipItemPln as itemNumber, Sum(TotEst) as TotEst, Sum(TotSales) as TotSales
from #ptSales b
	   group by ShipItemPln) Est on ('6' + Case when left(a.itemNumber,2) = '00' then right(a.itemnumber,5) else right(a.itemNumber,6) end) = Est.itemnumber
	   left join #ptMfgOrder mfg on ('6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end) = mfg.PartNum
where a.UpsellType in ('A','E','P','R') --and a.ItemNumber = '0071013'
group by s.Sector, a.CompanyCode, Case when food.FoodBook = 'Y' and nonfood.NonFoodBook = 'Y' then 'B'
	When food.FoodBook= 'Y' and nonfood.NonFoodBook is null then 'F'
	When nonfood.NonFoodBook = 'Y' and food.FoodBook is null then 'N' End, '6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end, '6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end,
     im.SchedCatCode, im.ShelfLife, a.Description, im.CIPhysicalCost, a.RetailPrice1, OH.OnHandQty, OH.OnHandDollars, p.UnShippedQty,c.DailySAlesUnits, c.DailySalesDollars, im.TotOnOrder, Est.TotEst, Est.TotSales
	 --(128 row(s) affected) 00:00:04

END



