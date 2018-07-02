select Year, 'Q' + cast(DatePart(Quarter,RcptDate) as char(1)) as Quarter, Sku, QtyRcvd, LeadTime
into ##ptLeadTimes
from Pic430
where RcptDate >'20081231'

Select Year, Quarter, SKu, Case when Sum(QtyRcvd) = 0 then 0 else Sum(QtyRcvd*LeadTime)/Sum(QtyRcvd) End as LeadTime
into ##ptSummary
from ##ptLeadTimes
Group by Year, Quarter, SKu
 
select distinct CompNum, Year(WeekBeginDate) as Year, 'Q' + cast(DatePart(Quarter,WeekBeginDate) as char(1)) as Quarter, Rd, Owner as Company 
into ##ptGlobalInventory
from Kimball.Merch2.dbo.GlobalInventory g left join Kimball.Odw1.dbo.FiscalCalendar f on g.CalendarSeq = f.CalendarSeq


select distinct s.*, g.RD, g.Company
 from ##ptSummary s Left Join ##ptGlobalInventory g on s.Year = g.Year and s.Quarter = g.Quarter and s.Sku = g.CompNum
 order by s.Year, s.Quarter