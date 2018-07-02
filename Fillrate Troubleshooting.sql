select * from inventoryReportFillrateb where season ='S17' and itemnumber = '6732480' order by weekenddate

select * from merch2.dbo.fillrate_merge where calendarSeq = 929 and itemnumber = '0732480'

select * from merch2.dbo.fillrateallocate where calendarSeq = 887 and season = 'S17'


select FoeDate, o.AccountNumber, o.OrderNumber, CatalogYear, CatalogCodePrefix, o.Orderstatus, ItemNumber from mdw1.dbo.orderline o join mdw1.dbo.orders d on o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber where catalogcodeprefix = 'EI' and catalogyear = 2016 and itemnumber = '0037609' order by foedate

select * from mdw1.dbo.catalogcodes where mailyear = 2016 and catalog = 'EI'


select * from SupplyChain_Misc.dbo.Rdcategory

select * from mdw1.dbo.item where itemnumber = '0732480' and primarycatalogcode = 'IZ' and season = 2016

select * from SupplyChain_Misc.dbo.SfCCategory