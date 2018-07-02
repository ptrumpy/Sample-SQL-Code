Declare @Date date, @IncludeRemoves char(1)
Set @Date = '2016-09-30'
set @IncludeRemoves = '1'
select isnull(s.Sector,'') as Sector, a.CompanyCode, Case when food.FoodBook = 'Y' and nonfood.NonFoodBook = 'Y' then 'B'
	When food.FoodBook= 'Y' and nonfood.NonFoodBook is null then 'F'
	When nonfood.NonFoodBook = 'Y' and food.FoodBook is null then 'N' End as CompanyType, 
'6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end as OrderablePack,
 '6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end as ShipNumber,     im.SchedCatCode, im.ShelfLife, Max(k.KWO) as KWO, Max(k.Page) as Page, a.Description, Min(a.UpsellType) as Code, 
 im.CIPhysicalCost as UnitCost, a.RetailPrice1 as Retail, im.OnHandQty as OHUnits, im.OnHandQty * im.CIPhysicalCost as OHDollarsAtCost, c.DailySAlesUnits, c.DailySalesDollars,im.TotOnOrder, Est.TotEst, Est.TotSales,
 Max(a.ActQty)as YTDSalesUnits, Max(a.ActSales) as YTDSalesDollars,p.UnShippedQty                                    
from mdw1.dbo.ItemDaily a inner join
(--Get max record date for item in ItemDaily
	  select season,itemnumber,rtrim(primarycatalogcode) as primarycatalogcode,max(i.recorddate) as Mdate
	  from mdw1.dbo.ItemDaily i join Merch2.dbo.F21OfferDaily f on rtrim(i.PrimaryCatalogcode) = f.offer_Id and i.season = (cast(f.offer_Year as varchar(4)))
	  where cast(left(i.recorddate,11) as datetime) <= @Date and f.Season_id = (Case When Month(@Date) between 7 and 12 then 'F'+ Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End) 
	  and f.Media_ID = 'UPS' --and i.UpsellType in ('A','E','P')
	   and (CompanyCode in('S','T','F') or RdCategory < 50) 
	  group by season,itemnumber,rtrim(primarycatalogcode)
) b on a.season=b.season and a.itemnumber=b.itemnumber and rtrim(a.primarycatalogcode)=rtrim(b.primarycatalogcode) and a.RecordDate=b.Mdate
Join bakery.dbo.vw_ItemMaster im on ('6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end) = im.ItemNumber 
left Join SupplyChain_Misc.dbo.Sector s on im.SchedCatCode = s.SchedCategoryCode
LEFT JOIN SupplyChain_Misc.dbo.PIC830 p ON p.PackNum = ('6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end)
LEFT join (select distinct a.itemnumber,
	 Case When Month(@Date) between 7 and 12 then 
		Case
			when a.PrimaryCatalogCode = 'AG' then pgpkillcode
			when a.PrimaryCatalogCode = 'RG' then pgpkillcode
			when a.PrimaryCatalogCode = 'FA' then pgpkillcode
			when a.PrimaryCatalogCode = 'YY' then pgpkillcOde
		Else ''
		END
	 When Month(@Date) between 1 and 6 then
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
	Case When Month(@Date) between 7 and 12 then 
		Case
			when a.PrimaryCatalogCode = 'AG' then PageNumber
			when a.PrimaryCatalogCode = 'RG' then PageNumber
			when a.PrimaryCatalogCode = 'FA' then PageNumber
			when a.PrimaryCatalogCode = 'YY' then PageNumber
		Else ''
		END
	 When Month(@Date) between 1 and 6 then
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
		from mdw1.dbo.Item a inner join
 Merch2.dbo.F21OfferDaily f on a.PrimaryCatalogcode = f.offer_Id and a.season = f.offer_Year
	  where f.Season_id = (Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End) 
	   and (CompanyCode in('S','T','F') or RdCategory < 50)
	  ) k on a.ItemNumber = k.ItemNumber
	  left Join (select a.CompanyCode, b.itemnumber,sum(isnull(itemqty,0)) as DailySalesUnits, Sum(isnull(itemqty,0)*UnitPrice) as DailySalesDollars
from mdw1.dbo.currentorders a inner join mdw1.dbo.currentorderlines b on a.accountnumber=b.accountnumber and a.ordernumber=b.ordernumber and b.addresssequence!='000'
join Merch2.dbo.F21OfferDaily f on b.CatalogcodePrefix = f.offer_Id and b.CatalogYear = (cast(f.offer_Year as varchar(4)))
join Mdw1.dbo.Item i on b.CatalogCodePrefix = i.PrimaryCatalogCode and b.CatalogYear = i.Season and b.itemNumber = i.ItemNumber
where-- cast(left(i.recorddate,11) as datetime) <= @Date and 
f.Season_id = (Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End) 
and a.orderstatus = 'F' and b.notavailableflag='0' --and b.itemnumber='0001461'
and f.Media_ID = 'UPS' and (a.CompanyCode in('S','T','F') or RdCategory < '50') and a.FoeDate = dateadd(dd,-1,@Date)
group by a.companycode,b.itemnumber
) c on a.ItemNumber = c.ItemNumber and a.companycode = c.companycode
left join (select distinct itemnumber, 'Y' as FoodBook from Mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.primaryCatalogcode = f.offer_Id and i.Season = (cast(f.offer_Year as varchar(4)))
where-- cast(left(i.recorddate,11) as datetime) <= @Date and 
f.Season_id = (Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End) 
and f.Media_ID = 'UPS' and i.CompanyCode in('S','T','F')) as Food on a.itemnumber = food.itemnumber
left join (select distinct itemnumber, 'Y' as NonFoodBook from Mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.primaryCatalogcode = f.offer_Id and i.Season = (cast(f.offer_Year as varchar(4)))
where-- cast(left(i.recorddate,11) as datetime) <= @Date and 
f.Season_id = (Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End) 
and f.Media_ID = 'UPS' and i.CompanyCode not in('S','T','F') and i.RdCategory < 50) nonfood on a.itemnumber = nonfood.itemnumber
left join (select itemNumber, Sum(TotEst) as TotEst, Sum(TotSales) as TotSales
from 
(select distinct season,x.CatItemPack, convnumber as itemnumber,GrossProfit, EstFinalQty as TotEst, ActQty as TotSales
	  from mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.PrimaryCatalogcode = f.offer_Id and i.season = f.offer_Year
	  LEFT JOIN Merch2.dbo.PxfBillXRefVw x ON x.CatItemPack = '6' + case when left(i.ItemNumber,2) = '00' then Right(i.ItemNumber,5) else right(i.ItemNumber,6) end
	  where f.Season_id in((Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End),(Case When Month(@Date) between 7 and 12 then 'S' + Right(Year(@Date)+1,2) Else 'F' + Right(Year(@Date),2)End))
	   and (CompanyCode in('S','T','F') or RdCategory < 50) and x.ActiveCatFlag = 'A'
	   --group by season, x.CatItemPack, i.convnumber

Union

select distinct season,x.CatItemPack, itemnumber, GrossProfit, EstFinalQty as TotEst, ActQty as TotSales
	  from mdw1.dbo.Item i join Merch2.dbo.F21OfferDaily f on i.PrimaryCatalogcode = f.offer_Id and i.season = f.offer_Year
	  LEFT JOIN Merch2.dbo.PxfBillXRefVw x ON x.CatItemPack = '6' + case when left(i.ConvNumber,2) = '00' then Right(i.ConvNumber,5) else right(i.ConvNumber,6) end
	  where f.Season_id in((Case When Month(@Date) between 7 and 12 then 'F' + Right(Year(@Date),2) Else 'S' + Right(Year(@Date)-1,2)End),(Case When Month(@Date) between 7 and 12 then 'S' + Right(Year(@Date)+1,2) Else 'F' + Right(Year(@Date),2)End))
	   and (CompanyCode in('S','T','F') or RdCategory < 50) and x.ActiveCatFlag = 'A' and i.Itemnumber <> i.ConvNumber and x.CatItemPack <> x.ShipItemPln
	   --group by season, x.CatItemPack, itemnumber
	   ) b
	   group by itemnumber) Est on a.itemnumber = Est.itemnumber
where ((a.UpsellType in ('A','E','P') and @IncludeRemoves = '1') or (a.UpsellType in ('A','E','P','R') and @IncludeRemoves = '2'))
group by s.Sector, a.CompanyCode, Case when food.FoodBook = 'Y' and nonfood.NonFoodBook = 'Y' then 'B'
	When food.FoodBook= 'Y' and nonfood.NonFoodBook is null then 'F'
	When nonfood.NonFoodBook = 'Y' and food.FoodBook is null then 'N' End, '6' + case when left(a.itemnumber,2) = '00' then Right(a.itemnumber,5) else right(a.ItemNumber,6) end, '6' + case when left(a.convnumber,2) = '00' then Right(a.convnumber,5) else right(a.convNumber,6) end,
     im.SchedCatCode, im.ShelfLife, a.Description, im.CIPhysicalCost, a.RetailPrice1, im.OnHandQty, im.OnHandQty * im.CIPhysicalCost,  p.UnShippedQty,c.DailySAlesUnits, c.DailySalesDollars, im.TotOnOrder, Est.TotEst, Est.TotSales



	