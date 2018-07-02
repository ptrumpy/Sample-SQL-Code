Select Season, Max(CalendarSeq) as CalendarSeq 
into #ptMaxCalSeq
from Merch2.dbo.Fillrate_MErge 
where right(Season,2) in ('13','14','15')
group by Season

select m.Season, RDcategory as RD, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, CatalogCodePrefix, cc.CompanyDescription, case when Sum(unitsdemanded) = 0 then 0 else (Sum(unitsdemanded) - Sum(Unitslost+UnitsNotShip))/Sum(cast(UnitsDemanded as decimal(9,2))) End as InitFill, Case When Sum(UnitsDemanded) = 0 then 0 else Sum(UnitsShipped+unitsbackordercurrent)/Sum(cast(UnitsDemanded as decimal(9,2))) End as FinalFill
from Fillrate_Merge m join #ptMaxCalSeq c on m.season = c.season and m.CalendarSeq = c.CalendarSeq
join MDW1.dbo.Company cc on m.CompanyCode = cc.Company
group by m.Season, RDcategory, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end, CatalogCodePrefix, cc.CompanyDescription