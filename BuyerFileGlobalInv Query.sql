select GetDate() as Date, pl.OrdPre, pl.ShipPackNum, p.Description, g.ComponentNum, e.LastRcptDate, pl.Building as ShipLoc, pl.LaneTote, pl.RenoFulfillCode, m.Bldg as BldgLocOfInv, m.QOH as QOHInBldgLoc, 
	Usage.AvgDailyUsage, Round(LastUsage.LastUsage,0) as LastUsage, Round(Usage.AvgNewOrders,0) as AvgNewOrders, isNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) as FutureDemand, 
	IsNull(Usage.AvgDailyUsage,0)  + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0) as TotalDemand, IsNull(e.UnShippedQty,0) as TotalUnshipped, IsNull(c.UnShippedQty,0) as ExpedUnShipped, 
	ShipLoc.OH as ShipLocQOH, Net.NetTotals, Net.NetTotals -(IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7)+ IsNull(e.UnshippedQty,0)) as NetQtyAvail, 
	ShipLoc.OH- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)) as ShipLocQtyAvail, 
	Case When (Case When Usage.AvgNewOrders = 0 then 0 else (Net.NetTotals -(IsNull(Usage.AvgDailyUsage,0) + IsNull(Usage.AvgNewOrders,0) + IsNull(c.UnshippedQty,0)))/Usage.AvgNewOrders End) < 0 then 0 else
	Case When Usage.AvgNewOrders = 0 then 0 else (Net.NetTotals -(IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(c.UnshippedQty,0)))/Usage.AvgNewOrders End End as NetDaysInv, 
	Case When (Case When Usage.AvgNewOrders = 0 then 0 else (ShipLoc.OH- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(c.UnshippedQty,0)))/Usage.AvgNewOrders End) < 0 then 0 else
	Case When Usage.AvgNewOrders = 0 then 0 else (ShipLoc.OH- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(c.UnshippedQty,0)))/Usage.AvgNewOrders End End as NetDaysInShipLoc,
	NonNet.NonNetTotals as NonNetTotals, bo.FirstDateOnBO, e.RecycleDate, DateDiff(d,e.RecycleDate,GetDate()) as DaysRcycling,pl.QAHold, pl.NLOWhenGoneFlag, pl.NLOPhoneDate, pl.NLSDate, pl.NLARStockBypass,
	 b.BuyerName, DMR.DMR, r.RecycleReason, r.AreaResponsible
From  paclab pl join  (Select * from Minvboh where QtyCode <>'IM') m on m.PackNum = pl.ShipPackNum
	left Join Pic680 p on m.PackNum = p.PartNum
	left Join PIC100G g on m.PackNum = g.ShipPackNum
	left Join PIC830 e on m.PackNum = e.PackNum
	left Join Cop597 c on m.PackNum = c.PackNum
	left join (Select PartNum, min(FirstDateOnBO) as FirstDateOnBO  from pic894 group by partnum) bo on m.PackNum = bo.PartNum 
	left join Buyer_Info b on p.BuyerCode = b.BuyerCode   
	left join Cop551 c5 on m.PackNum = c5.PackNum
	--left join RpInv ON pl.ShipPackNum = RpInv.item_Number
	join RecycleCodes r on c5.RecycleCode = r.RecycleCode
	left join (select detitemnumber, 
	   'DMR  ' + DMRNUM + ' ' + cast(Disposition as varchar(max)) + ' ' + Format(DispDate,'d','en-US')  as DMR,
		cast(Year(DispDate) as varchar(4)) + Right('0' + cast(Month(DispDate) as varchar(2)),2) + Right('0' + Cast(Day(DispDate) as varchar(2)),2) as DispDate 
from [clu1prd2014\charlie,14503].PPQAD_QASPEC.dbo.vw_RPOffload) DMR on m.PackNum = DMR.DetITemNumber
left join 
(select ShipPack, ceiling(avg(ShipUsageTot)) as AvgDailyUsage, ceiling(Avg(NewOrders)) as AvgNewOrders from PIC587D
group by SHipPack) Usage on m.PackNum = Usage.ShipPack
left Join (select distinct ShipPack, Last_Value(ShipUsageTot) OVER ( partition by shippack order by  shippack) LastUsage  
from PIC587D
where ShipUsageTot > 0) LastUsage on m.PackNum = LastUsage.ShipPack
Left Join (Select packnum, Sum(QOH) as OH 
from minvboh
where (Bldg in('809','811','819','853','863','845','074') or Bldg is null) and QtyCode = 'OH'
group by packnum) ShipLoc on m.PackNum = ShipLoc.packnum
left Join BuildingInfo bldg on pl.Building = bldg.BldgNum
Left Join (Select m.PackNum, Sum(m.QOH) as NetTotals  from minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where b.Classification = 'Nettable Inventory' group by m.PackNum) Net on m.PackNum = NEt.PackNum
Left Join (Select m.PackNum, Sum(m.QOH) as NonNetTotals  from minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where b.Classification = 'Non Nettable' group by m.PackNum) NonNet on m.PackNum = NonNEt.PackNum
where pl.Building <>'074' And pl.building Is Not Null AND pl.dropshipcode =''
order by OrdPre, m.PackNum



SELECT COP551.PackNum, RecycleCodes.AreaResponsible
FROM COP551 RIGHT JOIN RecycleCodes ON COP551.RecycleCode = RecycleCodes.RecycleCode
--GROUP BY COP551.PackNum, RecycleCodes.AreaResponsible
ORDER BY COP551.PacknUm;


