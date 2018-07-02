select g.CalendarSeq, WeekBeginDate, RD, SFC, ShipPackNum, PackNum, Owner, TotOnHand, TotOH$
from GlobalInventory g join ODW1.dbo.fiscalCalendar f on g.CalendarSeq = f.CalendarSeq
where WeekBeginDate between  '2013-12-31' and '2015-12-31'
order by CalendarSeq