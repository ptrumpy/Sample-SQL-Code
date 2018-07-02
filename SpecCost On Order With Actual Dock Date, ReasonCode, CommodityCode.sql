IF EXISTS (SELECT     *
                                                  FROM          tempdb..sysobjects
                                                  WHERE      id = object_id(N'tempdb.dbo.##PTMaxDate')) DROP TABLE ##PTMaxDate;

SELECT        ItemNumber, MAX(RecordDate) AS Mdate
INTO ##PTMaxDate
                               FROM            bakery.dbo.ItemMaster
                               GROUP BY ItemNumber;

IF EXISTS (SELECT     *
                                                  FROM          tempdb..sysobjects
                                                  WHERE      id = object_id(N'tempdb.dbo.##ptItemMaster')) DROP TABLE ##ptItemMaster;

SELECT        a.RecordDate, a.RecordType, a.ItemNumber, a.ItemType, a.ItemClass, a.ItemStatus, a.UOM, a.ItemDescription, a.ItemDescription2, a.Weight, a.CommodityCode, 
                         a.DrawingNbr, a.DrawSizePChk, a.ItemBillLevel, a.EngTextId, a.InvUnitCost, a.ExcInvPriorityCode, a.GLAccountNumber, a.TextPProdHold, a.StdCostRollupCode, 
                         a.OrderPrefix, a.BuyerDiv, a.ItemCategory, a.CompanyCode, a.Planner, a.Buyer, a.ShopPlanID, a.MakeBuyerCode, a.DemandPolicy, a.WorkCenter, a.PlannerTextID, 
                         a.SafteyStockQty, a.MinOrderQty, a.MaxOrderQty, a.LotSizeOrderQty, a.MinOrderQtyMod, a.MaxOrderQtyMod, a.SetUpCost, a.FixedLeadTime, a.PlannerLeadTime, 
                         a.MFGReleaseLeadTime, a.MFGPickLeadTime, a.VendorLeadTime, a.InspectLeadTime, a.OnHandQty, a.HOrderQty, a.ThisWkNetDmdQty, a.LastWkNetDmdQty, 
                         a.YTDIssueQty, a.StdCtgyCode, a.SCPersStyle, a.IPAPicCode, a.PrefVendorNbr, a.MFGVendorNbr, a.YTDReceipts, a.YTDEstimate, a.PurchaseOnOrder, 
                         a.MFGProdOnOrder, a.YrBegBalance, a.YTDScrap, a.RequiredQty, a.TotOnOrder, a.YTDProd, a.YTDOnOrder, a.BegEstQty, a.BegEstWOCryOvInv, a.InvCheckSw, 
                         a.DeductMethodCode, a.PriorYrBegBal, a.CIPhysicalCost, a.PriorCIPhyCost, a.PhyCostChangeDate, a.YTDEndingBalance, a.DropShipCode, a.QACarryOverCode, 
                         a.LotControlled, a.CIBoxQty, a.CountryCode, a.FreightFwdCd, a.CantGoBedroom, a.ShelfLife, a.NFPackInd, a.TempCodeCryOvr, a.SchedCatCode, a.KillWaitCd, 
                         a.ItemAddDate, a.PriorYrScrap, a.SPLCode, a.EstimateUpdate, a.PriorYrIssues, a.PriorYrReceipts, a.CryOvrInventory, a.CratePalletQty, a.EstCompSubQty, a.ToteQty, 
                         a.TempCode, a.PackSchedCode, a.OpportunityBuy, a.SchedClassCode, a.MiscEst, a.NfSubEst, a.MailOrdEst, a.MailOrdEst2, a.MailOrdEst3, a.MailOrdEst4, 
                         a.SalesForecastEst, a.MaxEstQty, a.ProdEstQty, a.PurchEstQty, a.PlusSubEst, a.MinusSubEst, a.OrigProdEst, a.LeftToSched, a.SpecEst, a.LocSpecEst, 
                         a.AuthProdQty, a.TotAuthProdQty, a.SavedEst, a.LateOrderEst, a.FreebieEst, a.PriorYrActSales, a.HighestEst, a.HighestEstDate, a.MopStartupEst, a.KillEstQty, 
                         a.RevisedEstQty, a.WaitEstQty, a.SpringEst, a.TotalSpringEst, a.SavedSpringEst, a.PhasedOutEst, a.TempEst, a.TempKillEst, a.NonFoodSpringEst, 
                         a.TotNonFdSpringEst, a.FaxCaompanyCode, a.PriorEst, a.OffSeasonMOPEst, a.SeasonUpsellSeasonEst, a.WholesaleEst, a.UsageEst, a.OtherEstQty, 
                         a.AuthorizedQty, a.NetSubQty, a.OkEstQty, a.SFExcessQty, a.NetReqQty
INTO ##ptItemMaster
FROM            bakery.dbo.ItemMaster AS a INNER JOIN
                             ##ptMaxDate b ON a.ItemNumber = b.ItemNumber AND a.RecordDate = b.Mdate

select cal.year_445 as year, cal.month_445 as Month, cal.week_445 as Week, 
a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3) as POLineRel,  cast(a.Dockdate as datetime) as Dockdate, cast(a.placeDate as Datetime) as POPlaceDate, a.itemnumber, Sum(a.onorderqty) as UnitsOnOrder,i.curspecmatlcost, Sum(i.curSpecMatlCost*a.onorderqty) as CurSpecMatlCostReceived,  a.purchasePrice, Sum(a.onorderqty*a.purchaseprice) as UnitCostReceived
,e.Rdcategory as RD, e.sfcategory as SFC, rd.Division, a.vendornumber, v.vendorname, a.ReasonCode, im.CommodityCode
from
(select r.itemnumber, r.vendornumber, r.onorderqty, outstandingqty, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.PlaceDate, r.dockdate, r.recorddate, max(reasoncode) as ReasonCode, max(i.recorddate) as costrecdate from 
(select a.itemnumber, a.vendornumber, a.onorderqty, outstandingqty, a.purchaseprice, a.contractnumber, a.linenumber, a.releasenumber, a.dtlstatus, a.PlaceDate, a.dockdate, a.recorddate, h.reasoncode from merch2.[dbo].[vw_PODetail_MAXRecordDate] a left join merch2.dbo.POHeader h on a.ContractNumber= h.ContractNumber) r
 join (select itemnumber, [CurSpecMatlCost], recorddate from bakery.dbo.itemcost) i on  r.itemnumber = i.itemnumber and cast (r.dockdate as datetime)  > i.recorddate
 where dtlstatus in(1,2)
 group by r.itemnumber, r.vendornumber, r.onorderqty, r.outstandingqty, r.purchaseprice, r.contractnumber, r.linenumber, r.releasenumber,  r.PlaceDate, r.dockdate, r.recorddate
 having max(i.recorddate) <= cast(r.dockdate as datetime)
) a  join bakery.dbo.ItemCost i on a.itemnumber = i.itemnumber and a.costrecdate = i.recorddate left join (select compitem, max(catitempack) as catitempack from merch2.dbo.[PxfBillXRefVw] 
group by compitem) pxf on a.itemnumber = pxf.compitem join tempwork.dbo.eabitem2 e on pxf.catitempack = e.ItemNumber6 left join SupplyChain_Misc.dbo.rdcategory rd on e.rdcategory = rd.rdcategory
left join (select distinct vendornum, max(vendorname) as VendorName from supplychain_misc.dbo.pic430All group by vendornum) v on a.vendornumber = v.vendornum join SupplyChain_misc.dbo.SeasonOverTime_ForwardCalendar cal on a.dockdate = cal.yyyymmdd
join ##ptItemMaster im on a.itemnumber = im.itemnumber
-- --where a.recorddate is null
 where a.dockdate  >= '20150219' --and contractnumber like '%7CL281379%'
-- and e.rdcategory is null
 group by  cal.year_445, cal.month_445, cal.week_445,
 a.itemnumber, a.vendornumber,a.contractnumber + ' ' + Right('00' + a.linenumber,3)+ Right('00' + a.releasenumber,3),  cast(a.dockdate as datetime), cast(a.placeDate as Datetime), i.curspecmatlcost, a.purchaseprice, e.rdcategory, e.sfcategory, rd.division,v.vendorName, a.ReasonCode, im.CommodityCode
