drop table #ptPacksRequiringAction
--build initial dataset
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
	 b.BuyerName, IsNull(DMR.DMR,'') as DMR,c5.RecycleReason, c5.RecycleCode, c5.AreaResponsible, g.VendorName,isnull(sub.ReplPack1,'') as ReplacementPack, isnull(sub2.OrdPack,'') as OrderedPack, g.VendorNum, rd.rd, RpInv.Status_code, rpinv.BldgHostID
into #ptPacksRequiringAction
From (select c.PackNum, c.RecycleCode, r.RecycleReason, r.AreaResponsible from COP551 c left join recyclecodes r  on Rtrim(c.RecycleCode) = rTrim(r.RecycleCode) group by c.PackNum, c.RecycleCode, r.RecycleReason, r.AreaResponsible) c5 left join   
paclab pl on pl.ShipPackNum = c5.PackNum left join  (Select PackNum, Bldg, Sum(QOH) as QOH from Minvboh where QtyCode <>'IM' group by PackNum, Bldg) m on m.PackNum = c5.PackNum
	left Join PIC100G g on pl.ShipPackNum = g.ShipPackNum
	left Join Pic680 p on g.ShipPackNum = p.PartNum
	left Join PIC830 e on pl.ShipPackNum = e.PackNum
	left Join Cop597 c on pl.ShipPackNum = c.PackNum
	left join (Select PartNum, min(BODate) as FirstBoDate  from pic894 where BOStatus <> 'h' group by partnum) bo on pl.ShipPackNum = bo.PartNum 
	left join Buyer_Info b on p.BuyerCode = b.BuyerCode  
	left join pic503 p5 on pl.ShipPackNum = p5.ShipPack 
	left join (select wh_id, item_number, status_code, bldgnum, BldgHostID, count(1) as count from rpinv join supplychain_misc.dbo.InventoryMatrix imx on rtrim(rpinv.wh_id) = rtrim(imx.location) and rtrim(rpinv.status_code) = rtrim(imx.statuscode)group by wh_id, item_number, status_code, bldgnum, BldgHostID) RpInv ON pl.ShipPackNum = RpInv.item_Number and m.bldg = rpinv.BldgNum
    left join BuildingInfo bld on m.Bldg = bld.BldgNum
	left join (select r.detitemnumber, 
	   'DMR  ' + r.DMRNUM + ' ' + cast(r.Disposition as varchar(max)) + ' ' + Format(r.DispDate,'d','en-US')  as DMR,
		cast(Year(r.DispDate) as varchar(4)) + Right('0' + cast(Month(r.DispDate) as varchar(2)),2) + Right('0' + Cast(Day(r.DispDate) as varchar(2)),2) as DispDate 
from [clu1prd2014\charlie,14503].PPQAD_QASPEC.dbo.vw_RPOffload r 
join (select detitemnumber, max(dispdate) as Dispdate from [clu1prd2014\charlie,14503].PPQAD_QASPEC.dbo.vw_RPOffload
group by detitemnumber) b on r.detitemnumber = b.detitemnumber and r.DispDate = b.DispDate) DMR on pl.ShipPackNum = DMR.DetITemNumber
left join 
(select ShipPack, ceiling(avg(ShipUsageTot)) as AvgDailyUsage, ceiling(Avg(NewOrders)) as AvgNewOrders from PIC587D
group by SHipPack) Usage on m.PackNum = Usage.ShipPack
left Join (Select p.ShipPack, ShipUsageTot as LastUsage from PIC587d p join 
(select shippack, Max(RecordDate) as RecordDate from Pic587d 
group by shippack) b on p.Shippack = b.Shippack and p.RecordDate = b.RecordDate) LastUsage on m.PackNum = LastUsage.ShipPack
left Join (Select packnum, Sum(QOH) as OH 
from minvboh
where (Bldg in(Null,'809','811','819','853','863','845','074') or Bldg is null) --and QtyCode = 'OH'
group by packnum) ShipLoc on ShipLoc.PackNum = m.packnum
left join BuildingInfo bldg on m.Bldg = bldg.BldgNum
Left Join (Select m.PackNum, Sum(m.QOH) as NetTotals  from minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where m.QtyCode <>'IM' and b.GlobalInvLocationTable = 'Y' group by m.PackNum) Net on pl.ShipPackNum = NEt.PackNum
Left Join (Select m.PackNum, Sum(m.QOH) as NonNetTotals  from minvboh m join BuildingInfo b on m.Bldg = b.BldgNum where  m.QtyCode <>'IM' and b.GlobalInvLocationTable = 'N' group by m.PackNum) NonNet on pl.ShipPackNum = NonNEt.PackNum
Left Join PIC190 sub on c5.PackNum = sub.OrdPack and sub.SubStatus =''
Left Join PIC190 sub2 on c5.PackNum = sub2.ReplPack1 and sub2.SubStatus =''
left join (select b.ShipItemPln, a.rd
from (select '6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end as Itemnumber, max(rdcategory) as RD from 
mdw1.dbo.item i join 
(select itemnumber, max(Season) as maxYear
from mdw1.dbo.item i 
group by ItemNumber) maxyear on i.itemnumber = maxyear.itemnumber
where season > 2012
group by '6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end) a 
left join merch2.dbo.[PxfBillXRefVw] b on a.ItemNumber = b.catitempack
where shipitempln is not null) rd on pl.shippacknum = rd.shipitempln
where pl.Building <>'074' and pl.building Is Not Null AND (pl.dropshipcode ='' or pl.DropShipCode =' ') and ((Net.NetTotals <= 0 and e.UnshippedQty > 0) or (c5.RecycleReason is not null)) 
order by OrdPre, ComponentNum

--add all recycle reasons to one field
SELECT Date, OrdPre, [ShippackNum], Description, ComponentNum, LastRcptDate, ShipLoc, LaneTote, RenoFulfillCode, InvLoc, InvLocOH, OHBldgDesc, Classification, 
	AvgDailyUsage, LastUsage, AvgNewOrders, FutureDemand, TotalDemand, TotalUnshipped, ExpedUnShipped, ShipLocQOH, NetTotals, NetQtyAvail, ShipLocQtyAvail, 
	NetDaysInv, NetDaysInShipLoc, NonNetTotals, FirstBODate, RecycleDate, DaysRcycling, QAHold, NLOWhenGoneFlag, NLOPhoneDate, NLSDate, NLARStockBypass,
	BuyerName, DMR, STUFF((SELECT distinct ', ' + A.[RecycleReason] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] FOR XML PATH('')),1,1,'') As [RecycleReason], STUFF((SELECT distinct ', ' + A.[AreaResponsible] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] FOR XML PATH('')),1,1,'')as  AreaResponsible, 
STUFF((SELECT distinct ', ' + A.[Status_code] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] and A.InvLoc = B.INVLoc  FOR XML PATH('')),1,1,'') As [Status_Code], 
STUFF((SELECT distinct ', ' + A.[BldgHostID] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] and A.InvLoc = B.INVLoc and A.bldghostid is not null FOR XML PATH('')),1,1,'') As [BldgHostID], VendorName, ReplacementPack, OrderedPack, VendorNum, Max(rd) as RD
From #ptPacksRequiringAction B
Group By Date, OrdPre, [ShippackNum], Description, ComponentNum, LastRcptDate, ShipLoc, LaneTote, RenoFulfillCode, InvLoc, InvLocOH, OHBldgDesc, Classification, 
	AvgDailyUsage, LastUsage, AvgNewOrders, FutureDemand, TotalDemand, TotalUnshipped, ExpedUnShipped, ShipLocQOH, NetTotals, NetQtyAvail, ShipLocQtyAvail, 
	NetDaysInv, NetDaysInShipLoc, NonNetTotals, FirstBODate, RecycleDate, DaysRcycling, QAHold, NLOWhenGoneFlag, NLOPhoneDate, NLSDate, NLARStockBypass,
	BuyerName, DMR, VendorName, ReplacementPack, OrderedPack, VendorNum


select 	STUFF((SELECT distinct ', ' + A.[Status_code] FROM #ptPacksRequiringAction A
Where A.[ShipPackNum]=B.[ShippackNum] and A.InvLoc = B.INVLoc  FOR XML PATH('')),1,1,'') As [Status_Code]
From #ptPacksRequiringAction B
where b.shippacknum = '652223'
Group By Date, OrdPre, [ShippackNum], Description, ComponentNum, LastRcptDate, ShipLoc, LaneTote, RenoFulfillCode, InvLoc, InvLocOH, OHBldgDesc, Classification, 
	AvgDailyUsage, LastUsage, AvgNewOrders, FutureDemand, TotalDemand, TotalUnshipped, ExpedUnShipped, ShipLocQOH, NetTotals, NetQtyAvail, ShipLocQtyAvail, 
	NetDaysInv, NetDaysInShipLoc, NonNetTotals, FirstBODate, RecycleDate, DaysRcycling, QAHold, NLOWhenGoneFlag, NLOPhoneDate, NLSDate, NLARStockBypass,
	BuyerName, DMR, VendorName, ReplacementPack, OrderedPack, VendorNum


	select * from rpinv where item_number = '6632078'
	select * from inventorymatrix where bldgnum = '862'