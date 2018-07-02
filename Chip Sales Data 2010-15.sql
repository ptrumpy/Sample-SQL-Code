If exists
(select * 
 from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#ptChipItem'))
Drop table #ptChipItem
Select '6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end as ItemNumber, i.Season, i.PrimaryCatalogCode, i.Description, PageNumber, PgpPicture, RetailPrice1, NewFlag, MerchandiserCode, BuyerCode, ExclusiveFlag, ImportCode, PercentSpace/100 as PagePct, Case
When i.DiscountReasonCode !='RL' Then i.RDCategory
Else '99' End as RDCategory, Case
When i.DiscountReasonCode !='RL' Then RdDescription
Else 'Sale Items' End as RdDescription, Case
When i.DiscountReasonCode !='RL' Then i.SfCategory
Else '99' End as SfCategory, Case
When i.DiscountReasonCode !='RL' Then SfDescription
Else '' End as SfDescription, GrossProfitPct, GrossProfit,
OperatingProfit, DropShipCode, HeavyCharge,
Case When CreditCostAmt > 0 Then case when RetailPrice1 = 0 then 0 else CreditCostAmt/RetailPrice1 end 
Else CreditCost/100 End as CreditCost, i.DiscountReasonCode, Case when RetailPrice1 = 0 then 0 else (ReturnReplacementCost/RetailPrice1) end as ReturnReplacementCost, InvVarCost, LaborShipAccum, PostageCharge, DataProcessingCost,PlantVarOther, PlantVarLabCost, OrderProcessingCost, BurdenFixedCost,
CollectionAmt as Ship_Rev, MaterialCost, UnitCost, RetailMember1, EstFinalQty, EstFinalSales, PgpKillCode, i.SeasonFlag
into #ptChipItem 
From MDW1.dbo.Item i Left Join MDW2.dbo.RDCategory r on r.RDCategory = (Select Case
When i.DiscountReasonCode !='RL' Then i.RDCategory
Else '99' End as RDCategory)
Left Join MDW2.dbo.SfCode s On i.SfCategory = s.SfMasterCode and s.RdMasterCode = (Select Case
When i.DiscountReasonCode !='RL' Then i.RDCategory
Else '99' End as RDCategory)
Where i.Season > 2008 
Order by i.RDCategory, SFCategory, '6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end

If exists
(select * 
 from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#ptChipOrdLnDetail'))
drop table #ptChipOrdLnDetail
 Select Left(d.FoeDate,4) as Year, d.CompanyCode, '6' + case when left(o.itemnumber,2) = '00' then Right(o.itemnumber,5) else right(o.ItemNumber,6) end as ItemNumber,
o.AllocatedSeason as CatalogYear, AllocatedCatalog as CatalogCodePrefix, o.AccountNumber, o.OrderNumber, o.AddressSequence, o.LineSequence, o.Season, o.UnitPrice,
CASE When AddressSequence = '000' Then isnull(itemqty,0) end as lostunitsdemanded, CASE When AddressSequence = '000' Then isnull(itemqty,0) * o.UnitPrice end as lostdollarsdemanded,
CASE When AddressSequence <> '000' Then isnull(itemqty,0) end as unitssales, CASE When AddressSequence <> '000' Then isnull(itemqty,0) * o.UnitPrice end as dollarssales
into #ptChipOrdLnDetail
from MDW1.dbo.OrderlineAllAllocate o join MDW1.dbo.OrdersAll d on o.AccountNumber = d.AccountNumber and o.OrderNumber = d.OrderNumber--LEft join MDW1.dbo.item i on o.catalogcodeprefix = i.PrimaryCatalogCode and o.CatalogYear = i.Season and o.itemnumber = i.itemnumber 
Where
d.FoeDate between '20100101' and '20151231' and ItemErrorFlag  in(' ','5') and AvailabilityFlag in(' ','1')  and 
d.OrderStatus = 'F' and zsubcode not in ('A','B') and addressIncompleteCode = '' and LineError17 in ('0',' ') and lineerror22 in ('0',' ')

If exists
(select * 
 from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#ptChipOrdLn'))
drop table #ptChipOrdLn
Select Year, CompanyCode, ItemNumber, CatalogYear, CatalogCodePrefix, Season, Sum(LostUnitsDemanded) as LostUnitsDemanded, Sum(LostDollarsDemanded) as LostDollarsDemanded,
 Sum(UnitsSales) as UnitsSales, Sum(DollarsSales) as DollarsSales
into #ptChipOrdLn
From #ptChipOrdLnDetail
group by Year, CompanyCode, ItemNumber, CatalogYear, CatalogCodePrefix, Season

If exists
(select * 
 from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#ptChipSubTot'))
Drop table #ptChipSubTot
Select o.Year, o.CompanyCode, i.PrimaryCatalogCode, i.Season, i.ItemNumber, Description,  RetailPrice1,
  GrossProfitPct, GrossProfit, HeavyCharge,
 CreditCost, ReturnReplacementCost, InvVarCost , LaborShipAccum, PostageCharge, DataProcessingCost, PlantVarOther, PlantVarLabCost, OrderProcessingCost, BurdenFixedCost,
 Ship_Rev, EstFinalQty, IsNull(Lostunitsdemanded,0) as UnitsLost, IsNull(Lostdollarsdemanded,0) as DollarsLost, UnitsSales, DollarsSales, MaterialCost, UnitCost
 into #ptChipSubTot
From #ptChipOrdLn o
Left Join #ptChipItem i  On
o.CatalogYear = i.Season and o.CatalogCodePrefix = i.PrimaryCatalogCode and o.ItemNumber = i.ItemNumber
where i.ItemNumber != '670000' 

Select Year, CompanyCode, PrimaryCatalogCode, Season, ItemNumber, Description, UnitsLost, DollarsLost, UnitsSales, DollarsSales, ReturnReplacementCost * DollarsSales as ReturnDollars, InvVarCost*UnitsSales as InvVarCost, LaborShipAccum * UnitsSales as LaborCost,  PostageCharge * UnitsSales as PostageCharge, Ship_Rev*UnitsSales as Ship_Rev,UnitCost*UnitsSales as UnitCost
into #ptEnd
from #ptChipSubTot

Select YEar,  CompanyDescription, Sum(UnitsSales) as UnitsSold, Sum(DollarsSales) as DollarsSold, Sum(UnitsSales+UnitsLost) as UnitsDemanded, Sum(DollarsSales+DollarsLost) as DollarsDemanded, 
	Sum(DollarsSales-ReturnDollars-InvVarCost-LaborCost-PostageCharge-UnitCost+Ship_Rev) as GPDollars, Case when Sum(DollarsSales) = 0 then 0 else Sum(DollarsSales-ReturnDollars-InvVarCost-LaborCost-PostageCharge-UnitCost+Ship_Rev)/Sum(DollarsSales) End as GPPCt
	from #ptEnd e join MDW1.dbo.Company c on e.CompanyCode = c.Company
	group by Year, CompanyDescription