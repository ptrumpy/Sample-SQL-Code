/* This code is used to compile a monthly list of items on sale that did not show up in previous months.  
Data comes from [johnson\dept_app_prod].Inventory_BE database*/

--List all Offers in Offer Hierarchy also in F21 Version 1
SELECT OFFER_ID, DropDate, Min(Rank) AS MinOfRank, OfferYear
into ##ptAllWorkingOffers
FROM trumpy.F21WORK f INNER JOIN trumpy.OfferHierarchy o 
ON f.OFFER_ID = o.Offer
GROUP BY OFFER_ID, DropDate, OfferYear;
GO
--Packs by Rank, Max Year
SELECT DISTINCT PackNum as OFFER_PRODUCT_ID, Rank, Year, CatID, SalePrefix
into ##ptRankByMaxYearPack
FROM (NFIM.dbo.PIC704 f LEFT JOIN trumpy.OfferHierarchy o ON f.CatID = o.Offer) LEFT JOIN ##ptAllWorkingOffers a 
ON f.CatID = a.OFFER_ID
WHERE (((o.Rank)=a.MinOfRank) AND ((f.Year)=a.OfferYear) AND ((o.SalePrefix)=0));
GO
--Pack by Year, MinRank
SELECT OFFER_PRODUCT_ID, Min(Rank) AS Rank
into ##ptPackByYearMinRank
FROM ##ptRankByMaxYearPack
GROUP BY OFFER_PRODUCT_ID;
GO
--Packs by Year, Offer
SELECT OFFER_PRODUCT_ID, OFFER_ID, Rank, OfferYear
into ##ptPackYearOffer
FROM ##ptAllWorkingOffers a LEFT JOIN ##ptPackByYearMinRank p 
ON a.MinOfRank = p.Rank
ORDER BY p.OFFER_PRODUCT_ID;
GO
--List all Active Offers if OfferHierachy also in F21 Version 1
SELECT OFFER_ID, DropDate, Min(Rank) AS Rank, OfferYear
into ##ptActiveOffers
FROM trumpy.F21WORK f INNER JOIN trumpy.OfferHierarchy o ON f.OFFER_ID = o.Offer
WHERE (((o.DropDate)<GetDate()))
GROUP BY f.OFFER_ID, o.DropDate, o.OfferYear;
GO
--Pack By Year, MinRank
SELECT OFFER_PRODUCT_ID, Min(Rank) AS Rank
into ##ptPackByYearRank
FROM ##ptRankByMaxYearpack
GROUP BY OFFER_PRODUCT_ID;
GO
--Pack By Year, Offer for Sale Offers
SELECT OFFER_PRODUCT_ID, a.OFFER_ID, p.Rank, a.OfferYear
into ##ptPackByYearOfferSaleOffers
FROM ##ptAllWorkingOffers a LEFT JOIN ##ptPackByYearRank p ON a.MinOfRank = p.Rank
Where OFFER_PRODUCT_ID Is Not Null
ORDER BY p.OFFER_PRODUCT_ID;
GO

Select distinct PackNum, Max(YEAR) as Year 
into ##ptMax704Year
from NFIM.dbo.PIC704
Where Year in (Year(GETDATE()), Year(GetDate())-1)
group by PackNum
order by PackNum

--Get Complete Sale Items List
SELECT DISTINCT m.PackNum, Description, m.Year, Round(Max(ORIGINALRETAIL),2) AS RETAIL, GetDate() AS MonthAdded
into ##ptAllSaleItems
FROM ##ptMax704Year m Left Join NFIM.dbo.PIC704 p on p.PackNum = m.PackNum and p.Year = m.Year
WHERE (((DiscountReasonCode) In ('RL','LP','LT','UP','OR')))  
GROUP BY m.PackNum, Description, m.Year 
ORDER BY m.pACKnUM;
GO

--Add Company based on logic in above steps
SELECT a.PackNum, a.Description, a.RETAIL, a.MonthAdded,
Case When p.OFFER_ID Is Null Then y.OFFER_ID
Else p.OFFER_ID End AS Offer, a.Year as MaxYear, 
Case Left(Case When p.OFFER_ID Is Null Then y.OFFER_ID
Else p.OFFER_ID End,1)
When 'D' Then 'Seventh'
When 'E' Then 'Seventh'
When 'J' Then 'Ginnys'
When 'W' Then 'M & M'
When 'N' Then 'Country Door'
When 'X' Then 'RaceTeamGear'
When 'A' Then 'Swiss'
When 'B' Then 'Swiss'
When 'C' Then 'Swiss'
When 'Y' Then 'Tender'
When 'V' Then 'Midnight Velvet'
When 'R' Then 'XmasVillage'
When 'P' Then 'Ashro'
When 'K' Then 'Home @ 5'
When 'M' Then 'MV Style'
When 'F' Then 'Wisconsin Cheeseman'
When 'S' Then 'Wards'
When 'G' Then 'Grand Pointe'
When '2' Then 'One Step Ahead'
End AS Company
into ##ptSaleItemsWithHierarchy
FROM (##ptAllSaleItems a LEFT JOIN ##ptPackYearOffer p ON a.PackNum = p.OFFER_PRODUCT_ID)
LEFT JOIN ##ptPackByYearOfferSaleOffers y
ON a.PackNum = y.OFFER_PRODUCT_ID;
GO

Insert Into trumpy.CummSaleItems (CatPack, Retail, Description, MonthAdded, Company)
SELECT DISTINCT s.PackNum, s.RETAIL, s.Description, s.MonthAdded, s.Company
FROM ##ptSaleItemsWithHierarchy s LEFT JOIN trumpy.CummSaleItems c ON s.PackNum = c.CatPack
WHERE (((c.CatPack) Is Null)) ;
GO