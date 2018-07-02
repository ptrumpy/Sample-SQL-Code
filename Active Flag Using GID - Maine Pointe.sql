Drop table #ptMaxCalSeq
select year(Weekbegindate) as year, Max(CalendarSeq) as CalendarSeq
into #ptMaxCalSeq
from ODW1.dbo.fiscalcalendar where year(weekbegindate) in (2013,2014,2015)
group by year(weekbegindate)
union 
Select year(weekbegindate) as year, max(g.CalendarSeq) from GlobalInventory g join ODW1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq
group by year(weekbegindate)

select distinct cast(s.Year as varchar(4)) + cast(PackNum as varchar(7)), s.Year,PackNum, 'Y' as Active from GlobalInventory g join #ptMaxCalSeq s on g.CalendarSeq = s.CalendarSeq
where  ExcessNoReOrderFlag is null and (KWO !='K' or KWO is null) and NewProposedDisp !='liquidate' and year = 2016
order by year


select * from globalinventory where calendarseq = (Select Max(CalendarSeq) from GlobalInventory) and PackNum = '607969'

