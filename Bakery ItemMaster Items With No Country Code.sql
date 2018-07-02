SELECT        CatItemPack, SetItem, ShipItemPln, CompItem, MAX(RecordDate) AS Rdate
								into #ptPXF
                               FROM            Merch2.dbo.PxfBillXref
                               GROUP BY CatItemPack, SetItem, ShipItemPln, CompItem

SELECT        a.RecordType, a.RecordDate, a.CatItemPack, a.SetItem, a.ShipItemPln, a.CompItem, a.ShipRetailPct, a.ShipQty, a.CompDualShipCnt, a.DualShipPack, 
                         a.ActiveCatFlag, a.BuyerDiv, a.FoodConvPack, a.CountryName, a.SkuSeq, a.ShipLocDiv, a.CompPiClass, a.ShipInEffectDate, a.ShipTextCode, a.CompType, 
                         a.CompUsage, a.CompBOMQty, a.CompIssueCtl, a.CompInEffectDate, a.PickUpCatyear, a.ShipInRevisionLevel, a.CompInRevisionLevel, a.CompImportClass, 
                         a.CompOriginCode, a.CompFollowupDays, a.CompPidTextId, a.CompPinTextId
INTO #ptPXF2
FROM            Merch2.dbo.PxfBillXref AS a INNER JOIN #ptPXF b ON a.CatItemPack = b.CatItemPack AND a.SetItem = b.SetItem AND 
                         a.ShipItemPln = b.ShipItemPln AND a.CompItem = b.CompItem AND a.RecordDate = b.Rdate
						 WHERE a.RecordType <>'D'


select distinct ItemNumber, ItemType, ItemClass, ItemStatus, ItemDescription, CommodityCode, ItemCategory, Buyer, Countryname, CountryCode, CompOriginCode
from bakery.dbo.vw_itemmaster i join #ptPXF2 p on i.ItemNumber = p.CompItem where p.CountryName='' and i.CountryCode <>''