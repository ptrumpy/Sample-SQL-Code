Select o.receiveddate, o.foeDate, d.OrderNumber, d.LineSequence, d.ItemNumber, d.ItemQty, d.Season, d.CatalogCodePrefix, d.CatalogYear, d.AllocatedCatalog, d.AllocatedSeason, d.RuleUsed
from orderlineallallocate d left join ordersall o  on
o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber 

Where d.AllocatedCatalog = 'ND' and d.catalogyear = '2011' and d.ItemNumber = '0039848' and d.OrderStatus = 'F'
order by ruleused, FOEDate
