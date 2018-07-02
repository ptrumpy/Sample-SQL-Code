Update c
set c.cobdate = CONVERT (varchar(8) , cast([COB Date] as date) , 112),
	c.actualbilloflading = cob.[b l]
from difreightreceived c join cobdata cob on replace(c.polinerel,' ','') like '%' + ltrim(rtrim([order no] + Right('0' + [line no],2))) + '%' and c.scnum = cob.[Item No] and c.DateRecd = replace(cast(convert(date,cast([freight received] as date),112) as varchar),'-','')
	and c.BillOfLading = cob.[hb L];

Update c
set c.cobdate = CONVERT (varchar(8) , cast([COB Date] as date) , 112),
	c.actualbilloflading = cob.[b l],
	c.billoflading = cob.[hb l]
from difreightreceived c join cobdata cob on replace(c.polinerel,' ','') like '%' + ltrim(rtrim([order no] + Right('0' + [line no],2))) + '%' and c.scnum = cob.[Item No] and c.DateRecd = replace(cast(convert(date,cast([freight received] as date),112) as varchar),'-','')
	and c.BillOfLading = cob.[b L];

	Update c
set c.cobdate = CONVERT (varchar(8) , cast([COB Date] as date) , 112),
	c.actualbilloflading = cob.[b l]
from chargeback c join cobdata cob on replace(c.polinerel,' ','') like '%' + ltrim(rtrim([order no] + Right('0' + [line no],2))) + '%' and c.scnum = cob.[Item No] and c.DateRecd = replace(cast(convert(date,cast([freight received] as date),112) as varchar),'-','')
	and c.BillOfLading = cob.[hb L];

Update c
set c.cobdate = CONVERT (varchar(8) , cast([COB Date] as date) , 112),
	c.actualbilloflading = cob.[b l],
	c.billoflading = cob.[hb l]
from chargeback c join cobdata cob on replace(c.polinerel,' ','') like '%' + ltrim(rtrim([order no] + Right('0' + [line no],2))) + '%' and c.scnum = cob.[Item No] and c.DateRecd = replace(cast(convert(date,cast([freight received] as date),112) as varchar),'-','')
	and c.BillOfLading = cob.[b L];

Alter Table difreightReceived
add COBDate varchar(8),
    ActualBillOfLading varchar(20);

Alter Table chargeback
add COBDate varchar(8),
    ActualBillOfLading varchar(20);



	select c.polinerel, c.scnum, c.billoflading, c2.billoflading, c2.actualbilloflading, c2.cobdate
	from [awsea-sql01,14501].supplychain_chargeback.dbo.chargeback c left join chargeback c2 on c.POLineRel = c2.POLineRel and c.scnum = c2.scnum