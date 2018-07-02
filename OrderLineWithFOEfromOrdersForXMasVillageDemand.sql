select d.CatalogYear, d.CatalogCodePrefix, o.foedate, d.itemNumber, d.conversionItemNumber, d.itemQty, d.UnitPrice,  
	d.colorsizeflag,  d.addressSequence, d.backorderedflag
from orderline d left join orders o on
o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber 

Where d.orderstatus = 'F' and  CatalogYear = '2014' and d.itemnumber = '0007716'
order by d.catalogcodeprefix, foedate, conversionitemnumber, addresssequence, backorderedflag
