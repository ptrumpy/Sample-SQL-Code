select distinct '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, Max(RdCategory) as RD, max(sfCategory) as SFC, Description
into #ptItem
from MDW1.dbo.Item
where primaryCatalogCode <>'' and season >=2016
group by '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end, Description


SELECT   distinct     p.PONumber, p.PartNo, Max(pxf.ShipItemPln) as Ship, Max(item.Description) as PackDescription, p.OrderQty, p.QtyRcvd, v.cost_ea--Case when v.Cost_Ea is null then  s.StdCost else v.Cost_ea End as Cost_ea
,p.DockDate,
Max(item.RD) as RD,  Max(item.SFC) as SFC,CountryName, CompOriginCode, CompImportClass, pxf.VendorNumber, CASE WHEN v. Vendor IS NULL THEN p. Vendor ELSE v. Vendor END AS Vendor, 
 p.OutstandingQty AS AmountDue, p.Buyer 
FROM            PIC361 AS p LEFT OUTER JOIN
                         PIC705 AS s ON p.PartNo = s.PartNum AND p.PONumber = s.OrdNum 
						LEFT OUTER JOIN
                         VendorPartInfo AS v ON p.PartNo = v.CompNum 
							   left join Buyer_info bi on p.Buyer = bi.BuyerCode
							   left join Merch2.[dbo].[PxfBillXRefVw] pxf on p.partno = pxf.CompItem
							   left join #ptitem item on pxf.CatItemPack = item.ItemNumber
							  -- join Merch2.[dbo].[PODetail] pd on left(p.PONumber,Charindex(' ',p.PONumber)-1) = pd.contractnumber and p.partno = pd.itemnumber and p.ponumber like '% %'
WHERE        (p.OutstandingQty > 0) AND (bi.Division = 'N' or p.Buyer in ('Q','QQ')) AND (p.Status IN ('3', '4'))  AND
                         p.RecordDate = (CAST(CAST(Year(GetDate()) AS varchar(4)) + '-' + (CASE WHEN Month(GetDate()) 
                         < 10 THEN '0' + CAST(Month(GetDate()) AS varchar(2)) ELSE CAST(Month(GetDate()) AS varchar(2)) END) + '-' + CASE WHEN Day(GetDate()) 
                         < 10 THEN '0' + CAST(Day(GetDate()) AS varchar(2)) ELSE CAST(Day(GetDate()) AS varchar(2)) END AS varchar(11))) 
						 --and ponumber like 'S43449QQ%'
						 group by p.PONumber, p.PartNo, p.OrderQty, p.QtyRcvd, v.Cost_ea,--Case when v.Cost_Ea is null then  s.StdCost else v.Cost_ea End,
						 p.DockDate,
							CountryName, CompOriginCode, CompImportClass, pxf.VendorNumber, CASE WHEN v. Vendor IS NULL THEN p. Vendor ELSE v. Vendor END,p.OutstandingQty, p.Buyer
ORDER BY p.PartNo