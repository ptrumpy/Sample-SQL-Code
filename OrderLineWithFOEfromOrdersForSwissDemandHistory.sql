select d.CatalogYear, d.CatalogCodePrefix, d.itemNumber, sum (d.itemQty) as Units, sum (d.itemQty * d.UnitPrice) as Dollars
from orderline d left join orders o on
o.accountnumber = d.accountnumber and o.ordernumber = d.ordernumber 

Where d.orderstatus = 'F' and  CatalogYear in ('2012', '2013') and catalogcodeprefix in ('AK', 'AW') and FOEdate < 20140905
group by d.catalogyear, d.catalogcodeprefix, d.itemnumber
order by d.catalogcodeprefix, itemnumber
