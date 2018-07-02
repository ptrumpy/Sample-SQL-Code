select o.foedate, d.itemNumber, d.itemQty, d.UnitPrice, d.Season, d.OrderStatus, d.CatalogCodePrefix, d.colorsizeflag, d.conversionItemNumber,
	d.addressSequence, d.backorderedflag
from orderlinedaily d left join ordersdaily o on
o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber 

Where d.orderstatus = 'F' and foedate > 20140905 and d.itemnumber = '0007716'
order by itemnumber, d.catalogcodeprefix, conversionitemnumber, addresssequence, backorderedflag, foedate
