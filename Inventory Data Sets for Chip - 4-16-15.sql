select Year(WeekEndDate) as Year, Month(WeekEndDate) as Month, Max(g.CalendarSeq) as CalSeq
into #ptMaxCalSeq
from [SWISS_COLONY\Trumpy].[ExecutiveSummary_Inv]  g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where YEar(WeekEndDate) > 2012
group by Year(WeekEndDate), Month(WeekEndDate)
order by Year(WeekEndDate), Month(WeekEndDate)

--Get MaxYear for Packs in Pic704
Select distinct PackNum, Max(Year) as Year
into ##ptMaxPic704Year
from [johnson\dept_app_prod].NFIM.dbo.PIC704
group by PackNum

--Distinct RD, SFC Numbers
Select distinct p.Year, p.PackNum, p.PrimaryComp
into ##ptPriComp
from [johnson\dept_app_prod].NFIM.dbo.PIC704 p Join ##ptMaxPic704Year y on p.Year = y.Year and p.PackNum = y.PackNum
GO

Select 	g.*, p.PrimaryComp 
into ##ptStep1
from [SWISS_COLONY\Trumpy].[ExecutiveSummary_Inv] g Left Join ##ptPriComp p on g.PackNum = p.PackNum
GO

select itemNumber, Max(Season) as Season
into ##ptMaxItemYear
from Kimball.MDW1.dbo.Item where PrimaryCatalogCode =' ' 
group by itemnumber
GO
Select distinct Case WHen i.itemNumber < 100000 then i.itemnumber  + 600000 else i.ItemNumber + 6000000 end as ItemNumber, i.OriginalCompanyCode
into ##ptOrigCompany
from Kimball.MDW1.dbo.Item i  Join ##ptMaxItemYear m on i.itemnumber = m.itemnumber and i.Season = m.Season
where i.PrimaryCatalogCode = ' ' and i.OriginalCompanyCode is not null and i.OriginalCompanyCode !=''
GO

select s.Year, s.Month, s.CalSeq, Company, Sum(TotOnHand+OnOrder) as TotInv, Sum((TotOnHand+OnOrder)*CompCost) as TotInvDollars
from ##ptStep1 g Left Join ##ptOrigCompany o on g.ShipPackNum = o.ItemNumber join #ptMaxCalSeq s on g.CalendarSeq = s.CalSeq join [johnson\dept_app_prod].[Inventory_BE].[trumpy].[CatalogManagers] c on (Case When g.PrimaryComp is null or RTrim(g.PrimaryComp) = '' then o.OriginalCompanyCode else g.PrimaryComp End) = c.CompanyCode

--where CalendarSeq = '709' 
group by s.Year, s.Month, s.CalSeq, Company
order by s.Year, s.Month, Company


select * from Odw1.dbo.fiscalcalendar where calendarSeq = '725'



--Get Info for GlobalInventory after we started capturing all data
select Year(WeekEndDate) as Year, Month(WeekEndDate) as Month, Max(g.CalendarSeq) as CalSeq
into #ptGlobalInvMaxCalSeq
from GlobalInventory  g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where YEar(WeekEndDate) > 2012
group by Year(WeekEndDate), Month(WeekEndDate)
order by Year(WeekEndDate), Month(WeekEndDate)

--Get Info for GlobalInventory before we started capturing all data
select Year(WeekEndDate) as Year, Month(WeekEndDate) as Month, Max(g.CalendarSeq) as CalSeq
into #ptInvMaxCalSeq
from Inventory  g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where YEar(WeekEndDate) > 2012
group by Year(WeekEndDate), Month(WeekEndDate)
order by Year(WeekEndDate), Month(WeekEndDate)

select Year, Month, CalendarSeq, Company, Sum(TotInv) as TotInv, Sum(TotInv$) as TotInvDollars
from GlobalInventory g join #ptGlobalInvMaxCalSeq s on g.CalendarSeq = s.CalSeq join [johnson\dept_app_prod].[Inventory_BE].trumpy.CatalogManagers c on g.PrimaryCompany = c.CompanyCode
group by Year, Month, CalendarSeq, Company
order by YEar, Month, Company

Union
Select CalendarSeq, SeasYrCo, Case substring(SeasYrCo,4,Len(SeasYrCo)-3)
When 'D' Then 'Seventh'
When 'J' Then 'Ginnys'
When 'X' Then 'Monroe'
When 'N' Then 'Country'
When 'R' Then 'Raceteam'
When 'Swiss' Then 'Swiss'
When 'Tend' Then 'Tender'
When 'V' Then 'Midnight'
When 'R' Then 'Christmas Village'
When 'P' Then 'Ashro'
When 'G' Then 'ChristmasV'
When 'K' Then 'HomeAt5'
When 'M' Then 'Monroe'
When 'F' Then 'Cheeseman'
When 'S' Then 'Wards'
When 'O' Then 'OSA'
When 'T' Then 'GrandPte'
End as Company, Sum(TotOnHand+ OnOrder) as TotInv, Sum((TotOnHand+OnOrder)*CompCost) as TotInvDollars
from Inventory g join #ptInvMaxCalSeq s on g.CalendarSeq = s.CalSeq
where CalendarSeq = '709' and (Case substring(SeasYrCo,4,Len(SeasYrCo)-3)
When 'D' Then 'Seventh'
When 'J' Then 'Ginnys'
When 'X' Then 'Monroe'
When 'N' Then 'Country'
When 'R' Then 'Raceteam'
When 'Swiss' Then 'Swiss'
When 'Tend' Then 'Tender'
When 'V' Then 'Midnight'
When 'R' Then 'Christmas Village'
When 'P' Then 'Ashro'
When 'G' Then 'ChristmasV'
When 'K' Then 'HomeAt5'
When 'M' Then 'Monroe'
When 'F' Then 'Cheeseman'
When 'S' Then 'Wards'
When 'O' Then 'OSA'
When 'T' Then 'GrandPte'
End) is null
group by CalendarSeq, SeasYrCo,Case substring(SeasYrCo,4,Len(SeasYrCo)-3)
When 'D' Then 'Seventh'
When 'J' Then 'Ginnys'
When 'X' Then 'Monroe'
When 'N' Then 'Country'
When 'R' Then 'Raceteam'
When 'Swiss' Then 'Swiss'
When 'Tend' Then 'Tender'
When 'V' Then 'Midnight'
When 'R' Then 'Christmas Village'
When 'P' Then 'Ashro'
When 'G' Then 'ChristmasV'
When 'K' Then 'HomeAt5'
When 'M' Then 'Monroe'
When 'F' Then 'Cheeseman'
When 'S' Then 'Wards'
When 'O' Then 'OSA'
When 'T' Then 'GrandPte'
End

select * from Inventory where CalendarSeq = '709' and SeasYrCo is null

select * from ODW1.dbo.FiscalCalendar