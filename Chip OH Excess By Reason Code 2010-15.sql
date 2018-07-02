--Drop table #ptMaxMonthlyDate
select Year(WeekBeginDate) as Year, Month(WeekBEginDate) as Month, Max(WeekBeginDate)  as Date
into #ptMaxMonthlyDate
from GlobalInventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where Year(WeekBEginDate) < 2016
group by Year(WeekBeginDate),Month(WeekBeginDate)
order by Year(WeekBeginDate),Month(WeekBeginDate)

--Drop table #ptMonthlyInv
Select m.Year, m.Month, g.Owner, g.LiquidationCode, Sum(g.TotOnHand) as OHUnits, Sum(g.TotOH$) as OHDollars, Sum(TotOHExcess) as OHExcessUnits, Sum(TotOHExcessDollars) as OHExcessDollars,
 Count(Distinct ShipPackNum) as SKUCount, Count(Distinct PackNum) as PackCount
 into #ptMonthlyInv
 from GlobalInventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq join #ptMaxMonthlyDate m on f.WeekBeginDate = m.Date
 group by m.Year, m.Month, g.Owner, g.LiquidationCOde

 --select Year, Avg(OHUnits) as AvgOHUnits, Avg(OHDollars) as AvgOHDollars, Avg(OHExcessUnits) as AvgOHExcessUnits, Avg(OHExcessDollars) as AvgOHExcessDollars, Avg(SKUCount) as AvgSkuCount, Avg(PackCOunt) as AvgPackCount
 --from #ptMonthlyInv
 --group by Year
 --Order by Year

-- Drop table #ptMaxMonthlyDateOld
select Year(WeekBeginDate) as Year, Month(WeekBEginDate) as Month, Max(WeekBeginDate)  as Date
into #ptMaxMonthlyDateOld
from Inventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where Year(WeekBEginDate) > 2009
group by Year(WeekBeginDate),Month(WeekBeginDate)
order by Year(WeekBeginDate),Month(WeekBeginDate)

--Drop table #ptMonthlyInvOld
Select m.Year, m.Month, Substring(g.SeasYrCo,4,5) as Owner, g.LiquidationCode, Sum(g.TotOnHand) as OHUnits, Sum(g.TotOnHand*CompCost) as OHDollars, Sum(CASE WHEN OnOrder = 0 THEN OverUnits WHEN OverUnits - OnOrder < 0 THEN 0 ELSE (OverUnits - OnOrder) END) OHExcessUnits, 
Sum(CASE WHEN OnOrder = 0 THEN OverUnits WHEN OverUnits - OnOrder < 0 THEN 0 ELSE (OverUnits - OnOrder) END *CompCost) as OHExcessDollars,
 Count(Distinct ShipPackNum) as SKUCount, Count(Distinct PackNum) as PackCount
 into #ptMonthlyInvOld
 from Inventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq join #ptMaxMonthlyDateOld m on f.WeekBeginDate = m.Date
 where cast(Year as varchar(4)) + cast(Month as varchar(2)) !='20135'
 group by m.Year, m.Month, Substring(SeasYrCo,4,5), g.LiquidationCode

 --Drop table #ptTotInv
 select Year, Month, Owner, LiquidationCode, OHUnits,OHDollars, OHExcessUnits, OHExcessDollars, SKUCount, PackCOunt
 into #ptTotInv
 from #ptMonthlyInv
  Union
 select Year, Month, Owner, LiquidationCode, OHUnits,OHDollars, OHExcessUnits, OHExcessDollars, SKUCount, PackCOunt
 from #ptMonthlyInvOld
  Order by Year

  Update #ptTotInv 
  Set Owner = 'Ginnys' where Owner = 'J'
   Update #ptTotInv 
  Set Owner = 'Seventh' where Owner = 'D'
   Update #ptTotInv 
  Set Owner = 'Wards' where Owner = 'S'
   Update #ptTotInv 
  Set Owner = 'Country' where Owner = 'N'
   Update #ptTotInv 
  Set Owner = 'ChristmasV' where Owner = 'G'
    Update #ptTotInv 
  Set Owner = 'Ashro' where Owner = 'P'
   Update #ptTotInv 
  Set Owner = 'Raceteam' where Owner = 'R'
    Update #ptTotInv 
  Set Owner = 'HomeAt5' where Owner = 'K'
   Update #ptTotInv 
  Set Owner = 'GrandP' where Owner = 'T'
    Update #ptTotInv 
  Set Owner = 'Midnight' where Owner = 'V'
   Update #ptTotInv 
  Set Owner = 'Monroe' where Owner = 'X'
  Update #ptTotInv 
  Set Owner = 'Cheeseman' where Owner = 'F'
  Update #ptTotInv 
  Set Owner = 'Tender' where Owner = 'Tend'

select Year, Owner, LiquidationCode, --Avg(OHUnits) as AvgOHUnits, Avg(OHDollars) as AvgOHDollars, 
Avg(OHExcessUnits) as AvgOHExcessUnits, Avg(OHExcessDollars) as AvgOHExcessDollars--, Avg(SKUCount) as AvgSkuCount, Avg(PackCOunt) as AvgPackCount

 from #ptTotInv
 group by Year, Owner, LiquidationCode
 Order by Year

 