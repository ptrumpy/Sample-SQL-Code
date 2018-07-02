Select Catalog, cast(ReleaseDate as Datetime) as ReleaseDate, Sum(ActualQty) as Circ,  SUM((BudSpu * ActualQty) * (SalesPercent / 100)) AS Budget
from mdw1.dbo.adcode where season = 2016 and catalog = 'DD'
group by Catalog, ReleaseDate

