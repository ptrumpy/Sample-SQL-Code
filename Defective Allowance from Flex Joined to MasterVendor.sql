SELECT distinct TProd.ID, TProd.PackNumber, TProd.ProductName 
      --,TSeasProd.Season
	  ,TMerch.MerchCode, TMerch.MerchLastName
      ,TSource.VendorID, TSource.Name
      ,TCSheet.CostSheetSequence
	  ,TCSheetReq.DefectAllowance
	  ,TCSheetReq.CostSheetStatus
	  ,TCSheetReq.CostSheetType
	  ,m.Vendor
	  ,m.Name as VendorName
	  into #ptDefAllow
FROM [Source].[flex].[tbl_Product] TProd 
		inner join (select ID, PackNumber, Max(DateInserted) NewestDate from source.flex.tbl_Product group by id, PackNumber) PrdNew 
					on TProd.id = PrdNew.id and TProd.PackNumber=PrdNew.PackNumber and TProd.DateInserted=PrdNew.NewestDate 
		inner join (source.flex.tbl_MerchantCode TMerch 
								inner join (select ID, max(dateinserted) MerchDate from source.flex.tbl_MerchantCode group by id) MerchNew on TMerch.Id=MerchNew.Id and TMerch.Dateinserted= Merchnew.MerchDate)
					on TProd.MerchantCodeId = TMerch.Id
		inner join (source.flex.tbl_source TSource 
								inner join (select id, max(ProductId) mProductID, max(dateinserted) NewDateSource from source.flex.tbl_Source group by id) SrcNew 
											on TSource.id=SrcNew.id and TSource.DateInserted= SrcNew.NewDateSource
								left join (source.flex.tbl_CostSheet TCSheet 
													inner join (select id, max(dateinserted) NewCSDate from source.flex.tbl_costsheet group by id) CSNew 
																on TCSheet.id = CSNew.id and TCSheet.DateInserted = CSNew.NewCSDate
													inner join (source.flex.tbl_CostSheetRequest TCSheetReq
																	inner join (select max(id) RequestID, CostSheetId 
																					from source.flex.tbl_CostSheetRequest 
																					group by CostSheetId) c 
																	on TCSheetReq.Id=c.RequestID)
													on TCSheet.id = TCSheetReq.CostSheetId)
											on cast(TSource.Id as varchar) = TCSheet.SourceId) 										
					on TProd.ID = SrcNew.mProductID
		inner join (source.flex.tbl_SeasonProduct TSeasProd inner join (Select ID, productid, max(dateinserted) NewDateSeason from source.flex.tbl_SeasonProduct group by id, productid) SPNew 
											on TSeasProd.id=SPNew.id and TSeasProd.productid=SPNew.productid and TSeasProd.DateInserted=SPNew.NewDateSeason)
					on TProd.id = SPNew.ProductId
					join (Select distinct Vendor, VendorPlmNumber, Name from [clu1prd2014\charlie,14503].vendisc.dbo.MasterVendor) m on TSource.VendorID = m.VendorPlmNumber
Where TCSHEETREQ.DefectAllowance > 0 and TSource.PrimarySource = 'Y'--TProd.PackNumber in (6722951) --and TCSheetReq.seasonid = 'Spring 2016' and TSeasProd.Season = TCSheetReq.SeasonID
Order by TCSheet.CostSheetSequence--TSeasProd.Season, TMerch.MerchLastName, TProd.PackNumber;

--99612,99729,131322,41226,

IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.##ptAdj'))
 DROP TABLE ##ptAdj
 --Get adjustments 
SELECT a.AccountNumber, a.OrderNumber, ItemNo, s.ShippedItem, a.OriginalAddressSequence, a.OriginalLineitemSequence, a.OriginalShipItemSequence, 
       Qty, CASE a.Type WHEN 'RR' THEN a.UnitPrice * Qty ELSE a.RefundAmount + a.Postage + a.ItemPostage
       END AS RetDollars
INTO ##ptAdj
FROM MDW1.dbo.AdjustmentItem a JOIN MDW1.dbo.ShipItemAll s 
	ON a.AccountNumber = s.AccountNumber AND a.OrderNumber = s.OrderNumber AND 
       a.OriginalAddressSequence = s.AddressSequence AND a.OriginalLineitemSequence = s.LineitemSequence AND 
       a.OriginalShipItemSequence = s.ShipItemSequence
WHERE     ShipDelDate between '20150810' and '20160809'and statuscode in ('S','P') 

--Get shipments(2011 and forward)
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.##ptShp'))
DROP TABLE ##ptShp

SELECT AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, Shippeditem, 
       CatalogYear, ItemPrefix, ShippedQty AS ShipQty, ShippedQty * UnitPrice AS ShipDollars
INTO ##ptShp
FROM MDW1.dbo.ShipItemAll
WHERE StatusCode in ('S','P') AND ShipDelDate between '20150810' and '20160809'

--Join Adjustments with Shipments
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.##ptCombined'))
DROP TABLE ##ptCombined

SELECT s.AccountNumber, s.OrderNumber, s.AddressSequence, s.ShipItemSequence, LineItemSequence, s.OrderedItem, s.ShippedITem, 
        s.CatalogYear, ItemPrefix, Qty AS RetQty, ShipQty, RetDollars,  
      ShipDollars
INTO ##ptCombined
FROM ##ptShp s LEFT JOIN ##ptAdj a 
	ON a.AccountNumber = s.AccountNumber AND a.OrderNumber = s.OrderNumber AND 
   a.OriginalAddressSequence = s.AddressSequence AND a.OriginalLineitemSequence = s.LineitemSequence AND 
   a.OriginalShipItemSequence = s.ShipItemSequence

   IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptPackTotals'))
DROP TABLE #ptPackTotals

   select '6' + case when left(Ordereditem,2) = '00' then Right(Ordereditem,5) else right(OrderedITem,6) end as OrderedItem, Sum(isnull(ShipQty,0)) as ShipQty, Sum(isnull(RetQty,0)) as RetQty, Sum(isnull(ShipDollars,0)) as ShipDollars, Sum(isnull(RetDollars,0)) as RetDollars
   into #ptPackTotals
   from ##ptCombined
   group by '6' + case when left(Ordereditem,2) = '00' then Right(Ordereditem,5) else right(OrderedITem,6) end

   select distinct Left(a.Vendor,5) as VendorNum, a.VendorName, a.PackNumber, a.ProductName as Description, a.DefectAllowance/100 as DefectiveAllowance, b.ShipQty, b.RetQty, Format(b.RetQty/cast(b.ShipQty as Decimal(9,0)),'p') as RetUnitsPct, b.ShipDollars, b.RetDollars, Format(b.RetDollars/b.ShipDollars,'p') as RetDollarsPct
   from #ptDefAllow a join #ptPackTotals b on a.PackNumber = b.OrderedItem

