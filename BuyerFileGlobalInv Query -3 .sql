select distinct CONVERT(VARCHAR(10), GETDATE(), 101) as Date, 
pl.OrdPre, pl.ShipPackNum, p.Description, g.ComponentNum, Convert(varchar(10),cast(e.LastRcptDate as Date),101) as LastRcptDate, pl.Building as ShipLoc, pl.LaneTote, pl.RenoFulfillCode, m.Bldg as InvLoc, isnull(m.QOH,0) as InvLocOH, bld.Description as OHBldgDesc, 
Case bld.Classification
	When 'Nettable Inventory' Then 'Net'
    When 'Non Nettable' Then 'Non Net'
	End as Classification,
	isnull(Usage.AvgDailyUsage,0) as AvgDailyUsage, Round(isnull(LastUsage.LastUsage,0),0) as LastUsage, Round(isnull(Usage.AvgNewOrders,0),0) as AvgNewOrders, isNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) as FutureDemand, 
	IsNull(Usage.AvgDailyUsage,0)  + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0) as TotalDemand, IsNull(e.UnShippedQty,0) as TotalUnshipped, IsNull(c.UnShippedQty,0) as ExpedUnShipped, 
	isnull(ShipLoc.OH,0) as ShipLocQOH, isnull(Net.NetTotals,0) as NetTotals, isnull(Net.NetTotals,0) -(IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7)+ IsNull(e.UnshippedQty,0)) as NetQtyAvail, 
	isnull(ShipLoc.OH,0)- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)) as ShipLocQtyAvail, 
	Round(--Case When (Case When Usage.AvgNewOrders = 0 then 0 else (isnull(Net.NetTotals,0) -(IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)))/Round(Usage.AvgNewOrders,0) End) < 0 then 0 else
	Case When isnull(Usage.AvgNewOrders,0) = 0 then 0 else (isnull(Net.NetTotals,0) -(IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)))/Round(Usage.AvgNewOrders,0) End --End
	,0) as NetDaysInv, 
	Round(--Case When (Case When Usage.AvgNewOrders = 0 then 0 else (isnull(ShipLoc.OH,0)- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)))/Round(Usage.AvgNewOrders,0) End) < 0 then 0 else
	Case When isnull(Usage.AvgNewOrders,0) = 0 then 0 else (isnull(ShipLoc.OH,0)- (IsNull(Usage.AvgDailyUsage,0) + (IsNull(Usage.AvgNewOrders,0) * 7) + IsNull(e.UnshippedQty,0)))/Round(Usage.AvgNewOrders,0) End --End
	,0) as NetDaysInShipLoc,
	isNull(NonNet.NonNetTotals,0) as NonNetTotals, Convert(varchar(10),Cast(bo.FirstBODate as Date),101) as FirstBODate
	, Case When e.RecycleDate = '000000' then '' else Convert(varchar(10),cast(e.RecycleDate as Date),101) End as RecycleDate, Case when e.RecycleDate='000000' then 0 else DateDiff(d,Convert(varchar(10),cast(e.RecycleDate as Date),101),GetDate()) End as DaysRcycling
	,pl.QAHold, pl.NLOWhenGoneFlag, Case When pl.NLOPhoneDate is null then '' else convert(varchar(10),pl.NLOPhoneDate,101) End as NLOPhoneDate, Case when pl.NLSDate is null then '' else convert(varchar(10),pl.NLSDate,101) End as NLSDate, pl.NLARStockBypass,
	 b.BuyerName, IsNull(DMR.DMR,'') as DMR,c5.RecycleReason, c5.RecycleCode, c5.AreaResponsible, g.VendorName,isnull(sub.ReplPack1,'') as ReplacementPack, isnull(sub2.OrdPack,'') as OrderedPack
into #ptPacksRequiringAction
From (select c.PackNum, c.RecycleCode, r.RecycleReason, r.AreaResponsible from COP551 c left join recyclecodes r  on Rtrim(c.RecycleCode) = rTrim(r.RecycleCode) group by c.PackNum, c.RecycleCode, r.RecycleReason, r.AreaResponsible) c5 left join   
SupplyChain_Misc.dbo.paclab pl on pl.ShipPackNum = c5.PackNum left join  (Select PackNum, Bldg, Sum(QOH) as QOH from SupplyChain_Misc.dbo.Minvboh where QtyCode <>'IM' group by PackNum, Bldg) m on m.PackNum = c5.PackNum
	left Join SupplyChain_Misc.dbo.PIC100G g on pl.ShipPackNum = g.ShipPackNum
	left Join SupplyChain_Misc.dbo.Pic680 p on g.ShipPackNum = p.PartNum
	left Join SupplyChain_Misc.dbo.PIC830 e on pl.ShipPackNum = e.PackNum
	left Join SupplyChain_Misc.dbo.Cop597 c on pl.ShipPackNum = c.PackNum
	left join (Select PartNum, min(BODate) as FirstBoDate  from SupplyChain_Misc.dbo.pic894 where BOStatus <> 'h' group by partnum) bo on pl.ShipPackNum = bo.PartNum 
	left join SupplyChain_Misc.dbo.pic503 p5 on pl.ShipPackNum = p5.ShipPack 
	left join SupplyChain_Misc.dbo.RpInv ON pl.ShipPackNum = RpInv.item_Number
    left join SupplyChain_Misc.dbo.BuildingInfo bld on m.Bldg = bld.BldgNum
	left join (select r.detitemnumber, 
	   'DMR  ' + r.DMRNUM + ' ' + cast(r.Disposition as varchar(max)) + ' ' + Format(r.DispDate,'d','en-US')  as DMR,
		cast(Year(r.DispDate) as varchar(4)) + Right('0' + cast(Month(r.DispDate) as varchar(2)),2) + Right('0' + Cast(Day(r.DispDate) as varchar(2)),2) as DispDate 
from [clu1prd2014\charlie,14503].PPQAD_QASPEC.dbo.vw_RPOffload r 
join (select detitemnumber, max(dispdate) as Dispdate from [clu1prd2014\charlie,14503].PPQAD_QASPEC.dbo.vw_RPOffload
group by detitemnumber) b on r.detitemnumber = b.detitemnumber and r.DispDate = b.DispDate) DMR on pl.ShipPackNum = DMR.DetITemNumber
left join 
(select ShipPack, ceiling(avg(ShipUsageTot)) as AvgDailyUsage, ceiling(Avg(NewOrders)) as AvgNewOrders from SupplyChain_Misc.dbo.PIC587D
group by SHipPack) Usage on m.PackNum = Usage.ShipPack
left Join (Select p.ShipPack, ShipUsageTot as LastUsage from SupplyChain_Misc.dbo.PIC587d p join 
(select shippack, Max(RecordDate) as RecordDate from SupplyChain_Misc.dbo.Pic587d 
group by shippack) b on p.Shippack = b.Shippack and p.RecordDate = b.RecordDate) LastUsage on m.PackNum = LastUsage.ShipPack
left Join (Select packnum, Sum(QOH) as OH 
from SupplyChain_Misc.dbo.minvboh
where (Bldg in(Null,'809','811','819','853','863','845','074') or Bldg is null) --and QtyCode = 'OH'
group by packnum) ShipLoc on ShipLoc.PackNum = m.packnum
left join SupplyChain_Misc.dbo.BuildingInfo bldg on m.Bldg = bldg.BldgNum
Left Join (Select m.PackNum, Sum(m.QOH) as NetTotals  from SupplyChain_Misc.dbo.minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where m.QtyCode <>'IM' and b.GlobalInvLocationTable = 'Y' group by m.PackNum) Net on pl.ShipPackNum = NEt.PackNum
Left Join (Select m.PackNum, Sum(m.QOH) as NonNetTotals  from SupplyChain_Misc.dbo.minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where  m.QtyCode <>'IM' and b.GlobalInvLocationTable = 'N' group by m.PackNum) NonNet on pl.ShipPackNum = NonNEt.PackNum
Left Join SupplyChain_Misc.dbo.PIC190 sub on c5.PackNum = sub.OrdPack
Left Join SupplyChain_Misc.dbo.PIC190 sub2 on c5.PackNum = sub2.ReplPack1
where pl.Building <>'074' And pl.building Is Not Null AND (pl.dropshipcode ='' or pl.DropShipCode =' ') and ((Net.NetTotals <= 0 and e.UnshippedQty > 0) or (c5.RecycleReason is not null))
order by OrdPre, ComponentNum

--add all recycle reasons to one field
SELECT Date, OrdPre, [ShippackNum], Description, ComponentNum, LastRcptDate, ShipLoc, LaneTote, RenoFulfillCode, InvLoc, InvLocOH, OHBldgDesc, Classification, 
	AvgDailyUsage, LastUsage, AvgNewOrders, FutureDemand, TotalDemand, TotalUnshipped, ExpedUnShipped, ShipLocQOH, NetTotals, NetQtyAvail, ShipLocQtyAvail, 
	NetDaysInv, NetDaysInShipLoc, NonNetTotals, FirstBODate, RecycleDate, DaysRcycling, QAHold, NLOWhenGoneFlag, NLOPhoneDate, NLSDate, NLARStockBypass,
	BuyerName, DMR, STUFF((SELECT distinct ', ' + A.[RecycleReason] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] FOR XML PATH('')),1,1,'') As [RecycleReason], STUFF((SELECT distinct ', ' + A.[AreaResponsible] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] FOR XML PATH('')),1,1,'')as  AreaResponsible, VendorName, ReplacementPack, OrderedPack
From #ptPacksRequiringAction B
Group By Date, OrdPre, [ShippackNum], Description, ComponentNum, LastRcptDate, ShipLoc, LaneTote, RenoFulfillCode, InvLoc, InvLocOH, OHBldgDesc, Classification, 
	AvgDailyUsage, LastUsage, AvgNewOrders, FutureDemand, TotalDemand, TotalUnshipped, ExpedUnShipped, ShipLocQOH, NetTotals, NetQtyAvail, ShipLocQtyAvail, 
	NetDaysInv, NetDaysInShipLoc, NonNetTotals, FirstBODate, RecycleDate, DaysRcycling, QAHold, NLOWhenGoneFlag, NLOPhoneDate, NLSDate, NLARStockBypass,
	BuyerName, DMR, VendorName, ReplacementPack, OrderedPack