select detitemnumber, 
	   'DMR  ' + DMRNUM + ' ' + cast(Disposition as varchar(max)) + ' ' + Format(DispDate,'d','en-US')  as DMR,
		cast(Year(DispDate) as varchar(4)) + Right('0' + cast(Month(DispDate) as varchar(2)),2) + Right('0' + Cast(Day(DispDate) as varchar(2)),2) as DispDate 
from vw_RPOffload  
where detitemnumber = '04518'