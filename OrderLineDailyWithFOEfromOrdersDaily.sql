select o.foedate, d.itemNumber, d.itemQty, d.UnitPrice, d.Season, d.OrderStatus, d.CatalogCodePrefix
from orderlinedaily d left join ordersdaily o on
o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber 

Where d.catalogcodeprefix in ('RK', 'RW') and d.orderstatus = 'F'
order by itemnumber, d.catalogcodeprefix, foedate