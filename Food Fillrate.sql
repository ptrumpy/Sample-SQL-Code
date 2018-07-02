  select ItemNumber, Max(RecordDate) as RecordDate 
into #ptMaxItemMaster
from [kimball\ODS].bakery.dbo.ItemMaster
--where itemnumber in('600220','600867')
group by ItemNumber

select im.* 
into #ptItemMaster
from [kimball\ODS].bakery.dbo.ItemMaster im join #ptMaxItemMaster m on im.itemnumber = m.itemnumber and im.Recorddate = m.recorddate

select * from #ptItemMaster where left(commoditycode,1) !='9' and commoditycode !='' and left(itemNumber,1) = '6'

select im.SchedCatCode, im.Planner, 
fm.* from fillrate_merge fm
left join #ptItemMaster im on im.ITemNumber = ('6' + case when left(fm.itemnumber,2) = '00' then Right(fm.itemnumber,5) else right(fm.ItemNumber,6) end) 
where fm.companycode in ('F','T','S') and calendarseq = (Select Max(CalendarSeq) from fillrate) and schedcatcode is null

select * from fillrate_merge fm
where fm.companycode in ('F','T','S') and calendarseq = (Select Max(CalendarSeq) from fillrate) and catalogcodeprefix = 'BA'

Select f.CalendarSeq, f.Year, f.season, f.companycode, f.catalogcodeprefix, f.itemnumber, f.rdcategory, f.merchname, f.merchandisercode, f.name, f.vendorcode, f.unitsshipped, f.unitsdemanded, f.dollarsdemanded, f.unitsbackordercurrent, f.unitsbackordercummulative, f.unitslost, f.dollarslost, f.unitsshipdelete, f.dollarsshipdelete, f.unitsnotship, f.unitsdeleted, f.unitsshippingdelete, f.unitsnla, c.CompanyDescription, r.RDDescription, e.mediagrp from Merch2.dbo.FillRate_Merge f Join MDW2.dbo.Company c On 
c.Company = f.companycode
Left Join MDW2.dbo.RDCategory r on r.RDCategory = f.rdcategory
Left Join Merch.dbo.eabmedia e On f.catalogcodeprefix = e.catcd and f.Year = e.Year
Join ODW1.dbo.FiscalCalendar q on f.CalendarSeq = q.CalendarSeq
where f.CalendarSeq = @CalendarSeq and companycode in (@Company) and f.Season in (@Season) and f.RDCategory < '50' and f.RdCategory !='23' and f.catalogcodeprefix not like '%$'


