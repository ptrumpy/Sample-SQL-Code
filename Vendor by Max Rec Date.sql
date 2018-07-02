
Select a.vendornumber, a.vendorname
from merch2.dbo.vendormaster a join 
(select vendornumber, max(recorddate) as rdate 
from merch2.dbo.vendormaster
group by vendornumber) b on a.vendornumber = b.vendornumber and a.recorddate = b.rdate

