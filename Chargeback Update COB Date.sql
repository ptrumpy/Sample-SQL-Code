select [order no], [line no], [item no], ltrim(rtrim([order no] + Right([line no],2))) as orderline, [Ordered Item Qty], [Freight Received], [Shipped Item Qty], [HB L], [COB Date]
from cobdata

Update c
set c.cobdate = replace(cob.[cob date],'-','')
from difreightreceived c join cobdata cob on replace(c.polinerel,' ','') like '%' + ltrim(rtrim([order no] + Right([line no],2))) + '%' and c.scnum = cob.[Item No] and c.DateRecd = replace(cob.[Freight Received],'-','') 
	and c.QtyRecd = cob.[Shipped Item Qty] and c.BillOfLading = cob.[HB L]


select * from difreightreceived where replace(polinerel,' ','') like '%7YM31447307%' and scnum = 'AAYA7'

select * from difreightreceived where scnum = 'AB4J4'
