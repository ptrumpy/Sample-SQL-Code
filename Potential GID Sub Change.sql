--Use Inventory_BE
--Distinct LIQUIDATION_CODES
--Select Sku, MAX(Liquidation_Code) as LiquidationCode
--into #ptLiqCodes
--from trumpy.F21Work
--group by Sku

--Get MaxYear for Packs in Pic704
Select distinct PackNum, Max(Year) as Year
into ##ptMaxPic704Year
from SupplyChain_Misc.dbo.PIC704All
group by PackNum

--Distinct RD, SFC Numbers
Select distinct p.Year, p.PackNum, p.RD, p.SFC, p.TwoDigitMerchCode as MerchCode, p.BuyerCode, Max(PostPaidFlag) as PostPaidFlag
into ##ptSFC
from SupplyChain_Misc.dbo.PIC704All p Left Join ##ptMaxPic704Year y on p.Year = y.Year and p.PackNum = y.PackNum
group by p.Year, p.PackNum, p.RD, p.SFC, p.TwoDigitMerchCode, p.BuyerCode
GO

--Distinct SFC Numbers from F21 in case not in PIC704
Select distinct Offer_Year,OFFER_PRODUCT_ID, Category_ID as RD, Right(SUB_CATEGORY_ID,2) as SFC 
into ##ptSFC2
from trumpy.F21Work
GO
--Sum QOH from MINVBOH file
SELECT PackNum, Sum(QOH) AS TotFPOnHand
into ##ptAllQOH
FROM SupplyChain_Misc.dbo.MINVBOH
WHERE ((QtyCode='OH'))
GROUP BY PackNum;
GO
--Add Dropdate to PIC704All info
SELECT PackNum, p.Description, Year, CatID, 
Case 
 When Ret2 = 0 then RetOne
 When Ret2 > 0 then Ret2 End  AS Retail, DiscountReasonCode, s.DropDate
into ##ptPic704WithDropDate
FROM SupplyChain_Misc.dbo.PIC704All p INNER JOIN trumpy.OfferHierarchy s ON
p.Year = s.OfferYear AND p.CatID = s.Offer
Join Merch2.dbo.F21OfferDaily o On
o.Offer_Year = p.Year and o.Offer_ID = p.catID
WHERE (s.DropDate>'2007-12-14') and (DiscountReasonCode Is Null or DiscountReasonCode = '' or DiscountReasonCode = 'ER' or DiscountReasonCode = 'EB' or DiscountReasonCode = 'LL' or DiscountReasonCode = 'WS' or DiscountReasonCode = 'LR' or DiscountReasonCode = 'FF' or DiscountReasonCode = 'MP') and (o.Division_ID !='GP' or o.Division_ID is null);
GO

--List all Offers in Offer Hierarchy also in F21 Version 1
SELECT CatID, OfferYear, DropDate, Min(Rank) AS MinOfRank
into ##ptAllWorkingOffers
FROM SupplyChain_Misc.dbo.PIC704All f INNER JOIN trumpy.OfferHierarchy o 
ON f.CatID = o.Offer
GROUP BY CatID, DropDate, OfferYear;
GO
--Drop Dates By Year, Pack
SELECT DISTINCT PackNum, o.DropDate, f.Year, Offer
into ##ptDropDateByYearPackAllOffers
FROM ##ptAllWorkingOffers a Right Join (SupplyChain_Misc.dbo.PIC704All f LEFT JOIN trumpy.OfferHierarchy o
ON f.CatID = o.Offer) ON a.CatID = f.CatID
WHERE (((o.DropDate)=a.DropDate) AND ((f.Year)=a.OfferYear));
GO
--DropDate By Year, Pack with no DRC
SELECT d.PackNum, Max(d.DropDate) AS MaxOfDropDate, DiscountReasonCode
into ##ptDropDateNoDRC
FROM ##ptDropDateByYearPackAllOffers d INNER JOIN ##ptPic704WithDropDate p 
ON (d.PackNum = p.PackNum) AND (d.Year = p.Year) AND (d.Offer = p.CatID)
GROUP BY d.PackNum, p.DiscountReasonCode
HAVING (((p.DiscountReasonCode) Is Null Or (p.DiscountReasonCode)='EB' Or (p.DiscountReasonCode)='LL' Or (p.DiscountReasonCode)='ER'  or (DiscountReasonCode = 'WS') or (DiscountReasonCode = 'LR') or (DiscountReasonCode = 'FF') Or DiscountReasonCode = 'MP' Or p.DiscountReasonCode = ''));
GO
--Packs by Max DropDate
SELECT PackNum, Max(MaxOfDropDate) AS MaxOfDropDate
into ##ptMaxDropDate
FROM ##ptDropDateNoDRC
GROUP BY PackNum;
GO
--Orig Retails By pack, Offer
SELECT DISTINCT m.PackNum, Min(p.Retail) AS Retail
into ##ptOrigRetByPackOffer
FROM ##ptMaxDropDate m INNER JOIN ##ptPIC704WithDropDate p
ON (m.PackNum = p.[PackNum]) AND (m.MaxOfDropDate = p.DropDate)
GROUP BY m.PackNum;
GO
--Canc PO Qty
--SELECT SKU,  Sum(Qty) as Qty
--into ##ptCancPOQty
--FROM F21SchedRcpts
--where (((CancBeforeDate)>GetDate()))
--GROUP BY SKU;
--GO
--Packs by Rank, Max Year
SELECT DISTINCT PackNum, Rank, Year, Offer, SalePrefix
into ##ptRankByMaxYearPack
FROM (SupplyChain_Misc.dbo.PIC704All f LEFT JOIN trumpy.OfferHierarchy o ON f.CatID = o.Offer) LEFT JOIN ##ptAllWorkingOffers a 
ON f.CatID = a.CatID
WHERE (((o.Rank)=a.MinOfRank) AND ((f.Year)=a.OfferYear) AND ((o.SalePrefix)=0));
GO
--Pack by Year, MinRank
SELECT PackNum, Min(Rank) AS Rank
into ##ptPackByYearMinRank
FROM ##ptRankByMaxYearPack
GROUP BY PackNum;
GO
--Packs by Year, Offer
SELECT PackNum, CatID, Rank, OfferYear
into ##ptPackYearOffer
FROM ##ptAllWorkingOffers a LEFT JOIN ##ptPackByYearMinRank p 
ON a.MinOfRank = p.Rank
ORDER BY p.PackNum;
GO
--Inv Over One Year old
SELECT PackNum, Min(InvDate) AS InvDate
into ##ptInvOverOneYear
FROM trumpy.InvOverOneYear
GROUP BY PackNum;
GO
--All Future Offers already built to F21
SELECT OFFER_ID, DropDate, Min(Rank) AS Rank, OfferYear
into ##ptFutureOffers
FROM trumpy.F21WORK f LEFT JOIN trumpy.OfferHierarchy o ON f.OFFER_ID = o.Offer
WHERE (((o.DropDate)>GetDate()))
GROUP BY f.OFFER_ID, o.DropDate, o.OfferYear;
GO
--Future Drop Date By Year Pack
SELECT DISTINCT OFFER_PRODUCT_ID, o.DropDate, OFFER_YEAR, Offer
into ##ptFutureDropDateByYearPack
FROM (trumpy.F21WORK f LEFT JOIN trumpy.OfferHierarchy o ON
f.OFFER_ID = o.Offer) LEFT JOIN ##ptFutureOffers u ON f.OFFER_ID = u.OFFER_ID
WHERE (((o.DropDate)=u.[DropDate]) AND ((f.OFFER_YEAR)=u.OfferYear));
GO
--Future Drop Dates with No DRC
SELECT OFFER_PRODUCT_ID, Min(f.DropDate) AS DropDate, DiscountReasonCode
into ##ptFutDropDatesNoDRC
FROM ##ptFutureDropDateByYearPack f INNER JOIN ##ptPic704WithDropDate p
ON (f.Offer = p.CatID) AND (f.OFFER_YEAR = p.Year) AND (f.OFFER_PRODUCT_ID = p.PackNum)
GROUP BY f.OFFER_PRODUCT_ID, p.DiscountReasonCode
HAVING (((p.DiscountReasonCode) Is Null Or (p.DiscountReasonCode)='EB' Or (p.DiscountReasonCode)='LL' Or (p.DiscountReasonCode)='ER' or (DiscountReasonCode = 'WS') or (DiscountReasonCode = 'IP') or (DiscountReasonCode = 'FF' or DiscountReasonCode = 'MP')));
GO
--Min Future DropDate
SELECT OFFER_PRODUCT_ID, DropDate
into ##ptMinFutDropDate
FROM ##ptFutDropDatesNoDRC
GROUP BY OFFER_PRODUCT_ID, DropDate;
GO
--Fut Orig Retails by Pack, Offer
SELECT DISTINCT OFFER_PRODUCT_ID, Min(Retail) AS Retail
into ##ptFutOrigRetailsByPackOffer
FROM ##ptMinFutDropDate m INNER JOIN ##ptPIC704WithDropDate p ON (m.OFFER_PRODUCT_ID = p.PackNum) AND (m.DropDate = p.DropDate)
GROUP BY m.OFFER_PRODUCT_ID;
GO
--Box A/B (Adds "Y" tp BoxAB field if multiple boxes shipped) Changed to use PacLab field instead of Pic100G query
SELECT DISTINCT ShipPackNum, ShipsMultiBox as BOXAB
into ##ptBoxAB
FROM SupplyChain_Misc.dbo.Paclab 
WHERE ShipsMultiBox = 'Y';
GO
--Highest Retails before Spring 08 (Change seasons when moving forward)
SELECT OFFER_PRODUCT_ID, SKU, Max(SKU_UNIT_PRICE) AS SKU_UNIT_PRICE
into ##ptHighestRetails
FROM trumpy.F21WORK 
WHERE (((SEASON_ID) Not In ('S08','F08','S09','F09')))
GROUP BY OFFER_PRODUCT_ID, SKU;
GO

--Add Dropdate to PIC704All info
SELECT distinct OFFER_PRODUCT_ID, Offer_pRoduct_Desc, p.Offer_Year, p.OFFER_ID, Disc_Reason_Code, s.DropDate
into ##ptF21WorkWithDropDate
FROM trumpy.F21WORK p INNER JOIN trumpy.OfferHierarchy s ON
p.OFFER_Year = s.OfferYear AND p.OFFER_ID = s.Offer
Join Merch2.dbo.F21OfferDaily o On
o.Offer_Year = p.OFFER_Year and o.Offer_ID = p.OFFER_ID
WHERE (s.DropDate>'2007-12-14') and (Disc_Reason_Code Is Null or Disc_Reason_Code = '' or Disc_Reason_Code = 'ER' or Disc_Reason_Code = 'EB' or Disc_Reason_Code = 'LL' or Disc_Reason_Code = 'WS' or Disc_Reason_Code = 'LR' or Disc_Reason_Code = 'FF' or Disc_Reason_Code = 'MP') and (o.Division_ID !='GP' or o.Division_ID is null);
GO

--List all Offers in Offer Hierarchy also in F21 Version 1
SELECT Offer_ID, OfferYear, DropDate, Min(Rank) AS MinOfRank
into ##ptAllF21WorkingOffers
FROM trumpy.F21WORK f INNER JOIN trumpy.OfferHierarchy o 
ON f.Offer_ID = o.Offer
GROUP BY f.Offer_ID, DropDate, OfferYear;
GO

--Drop Dates By Year, Pack
SELECT DISTINCT Offer_product_Id as PackNum, o.DropDate, f.OFFER_YEAR as Year, Offer
into ##ptDropDateByYearPackAllF21Offers
FROM ##ptAllF21WorkingOffers a Right Join (trumpy.F21WORK f LEFT JOIN trumpy.OfferHierarchy o
ON f.Offer_ID = o.Offer) ON a.Offer_ID = f.Offer_ID
WHERE (((o.DropDate)=a.DropDate) AND ((f.Offer_Year)=a.OfferYear));
GO

--DropDate By Year, Pack with no DRC
SELECT d.PackNum, Max(d.DropDate) AS MaxOfDropDate, p.Disc_Reason_Code
into ##ptDropDateNoDRCF21
FROM ##ptDropDateByYearPackAllF21Offers d INNER JOIN ##ptF21WorkWithDropDate p 
ON (d.PackNum = p.OFFER_PRODUCT_ID) AND (d.Year = p.Offer_Year) AND (d.Offer = p.Offer_ID)
GROUP BY d.PackNum, p.Disc_Reason_Code
HAVING ((p.Disc_Reason_Code) Is Null Or (p.Disc_Reason_Code)='EB' Or (p.Disc_Reason_Code)='LL' Or (p.Disc_Reason_Code)='ER'  or (p.Disc_Reason_Code = 'WS') or (p.Disc_Reason_Code = 'LR')
or (p.Disc_Reason_Code = 'FF') or (p.Disc_Reason_Code = 'MP')  Or (p.Disc_Reason_Code = ''));
GO

--Packs by Max DropDate
SELECT PackNum, Max(MaxOfDropDate) AS MaxOfDropDate
into ##ptMaxDropDateF21
FROM ##ptDropDateNoDRCF21
GROUP BY PackNum;
GO

--Packs by Rank, Max Year
SELECT DISTINCT Offer_product_ID as packNum, Rank, Offer_Year, Offer, SalePrefix
into ##ptRankByMaxYearPackF21
FROM (trumpy.F21WORK f LEFT JOIN trumpy.OfferHierarchy o ON f.Offer_ID = o.Offer) LEFT JOIN ##ptAllF21WorkingOffers a 
ON f.Offer_ID = a.Offer_ID
WHERE (((o.Rank)=a.MinOfRank) AND ((f.Offer_Year)=a.OfferYear) AND ((o.SalePrefix)=0));
GO

--Pack by Year, MinRank
SELECT PackNum, Min(Rank) AS Rank
into ##ptPackByYearMinRankF21
FROM ##ptRankByMaxYearPackF21
GROUP BY PackNum;
GO

--Packs by Year, Offer
SELECT PackNum, Offer_ID, Rank, OfferYear
into ##ptPackYearOfferF21
FROM ##ptAllF21WorkingOffers a LEFT JOIN ##ptPackByYearMinRankF21 p 
ON a.MinOfRank = p.Rank
ORDER BY p.PackNum;
GO

Select distinct packNum, Season_ID as Season
into #ptSeason
from ##ptPackYearOfferF21 p Left Join trumpy.F21WORK f
on p.packNum = f.Offer_Product_ID and p.OFFER_ID = f.OFFER_ID and p.OfferYear = f.OFFER_YEAR 
GO

Select Sku, SUM(Demand) as FutureDemand 
into #ptFutureDemand
from SupplyChain_Global_Inventory.dbo.FutureDemand 
group by Sku
GO

--ColorSizeFutureDemand(Added 1/27/2012 to try to capture future demand for sets/kits)
Select * 
into #ptTestBoxAB
from SupplyChain_Misc.dbo.Paclab where ShipsMultiBox = 'Y'
GO
Select distinct b.ShipPackNum, b.ShipsMultiBox as BoxAB, p.ColorSize 
into #ptBoxABColorSize
from #ptTestBoxAB b Left Join SupplyChain_Misc.dbo.PIC736 p on b.ShipPackNum = p.ShipPack
where ColorSize = 'Y' order by ShipPackNum
GO
select distinct PackNumber, ShipPackNum, ComponentNum, SetPackNum 
into #ptDistinctSets
from SupplyChain_Misc.dbo.PIC100G 
GO

--Select distinct b.ShipPackNum as PackNum, p.ShipPackNum, ComponentNum,Sum(Demand) as Demand
--into #ptColorSizeDemand
--from #ptBoxABColorSize b Left Join #ptDistinctSets p on b.ShipPackNum = p.PackNumber 
--Left Join FutureDemand f on f.Sku = p.SetPackNum
--Group by b.ShipPackNum, p.ShipPackNum, ComponentNum
--Having SUM(Demand) is not null
--GO
Select distinct p.ShipPackNum, ComponentNum,Sum(Demand) as Demand
into #ptColorSizeDemand
from #ptBoxABColorSize b Left Join #ptDistinctSets p on b.ShipPackNum = p.PackNumber 
Left Join FutureDemand f on f.Sku = p.SetPackNum
Group by  p.ShipPackNum, ComponentNum
Having SUM(Demand) is not null
GO

--Get number of packs a shippack is in
SELECT ShipPackNum
 ,Count(PackNumber) AS PackCount
INTO #ptPackCount
FROM SupplyChain_Misc.dbo.Pic100G
GROUP BY ShipPackNum
HAVING Count(PackNumber) > 1


--Step one of weekly build of Global Inventory File
SELECT DISTINCT p.CompNum, BuyerCode,  p.MerchCode, MarketingDesc, CompDesc, i.VendorNum, Vendor, i.RD,  p.packnum, case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End as NewPackNum,
p.ShipPackNum, y.CatID, y.OfferYear, CompOnHand, Case
When a.TotFPOnHand Is Null then 0
Else a.TotFPOnHand End AS TotFPOH, CompOnHand + Coalesce(a.TotFPOnHand,0) AS TotOH, CompOnOrder, CompCost, 
Case 
When Left(CatID,1) = 'A' Then ExcessQty
When Left(CatID,1) = 'B' Then ExcessQty
When OverUnits Is Null then ExcessQty
Else OverUnits End AS OverUnits, 
Case
When o.Retail>0 then o.Retail
Else r.Retail End  AS OrigRetail, 
 CommCode, convert(varchar, InvDate, 101)
AS [PreMar2007], p.OpportunityBuy, 
Case
WHEN QAHold != '' Then 'Y'
Else QAHold End AS QAHold, NLS, p.Bldg, HoldDescription, p.Cube, z.BOXAB, NLARStck, PredispositionCode, NLARStockBypass, UnShipped, pc.PackCount, pf.CombinableCode, l.NLOWhenGoneFlag
--into ##ptWeeklyStepOne
FROM (((((((((SupplyChain_Global_Inventory.trumpy.PIC291DA p 
left join (select * from supplyChain_Misc.dbo.pic190 where substatus = '') sub on p.packnum = sub.OrdPack
LEFT JOIN SupplyChain_Misc.dbo.MerchantCodes m ON p.MerchCode = m.MerchCode) LEFT JOIN ##ptAllQOH a ON p.ShipPackNum = a.PackNum) LEFT JOIN ##ptOrigRetByPackOffer o
ON (case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End) = o.PackNum) LEFT JOIN trumpy.PIC779 i ON (p.CompNum = i.CompNum) AND (p.ShipPackNum = i.PackNum))
LEFT JOIN (SupplyChain_Misc.dbo.Paclab l LEFT JOIN trumpy.QAHold q ON l.QAHold = q.HoldCode) ON p.ShipPackNum = l.ShipPackNum) 
LEFT JOIN ##ptPackYearOffer y ON p.PackNum = y.PackNum) LEFT JOIN ##ptInvOverOneYear x
ON (case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End) = x.PackNum) LEFT JOIN F21OverUnits u ON p.ShipPackNum = u.SKU) LEFT JOIN ##ptFutOrigRetailsByPackOffer r 
ON (case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End) = r.OFFER_PRODUCT_ID) LEFT JOIN ##ptBoxAB z ON ((case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End) = z.ShipPackNum)
Left Join ExcessExclusion e on p.ShipPackNum = e.Sku
Left Join #ptPackCount pc on p.ShipPackNum = pc.ShipPackNum
Left Join SupplyChain_Misc.dbo.PIC503 pf on p.ShipPackNum = pf.ShipPack

WHERE (((p.CompNum)<>'89000') and p.Bldg !='804') and (case when sub.replPack1 is not null then sub.replpack1 else p.PackNum End)<>p.packnum;
GO





select * from supplyChain_Misc.dbo.pic190 where substatus = ''