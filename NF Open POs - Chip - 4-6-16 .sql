drop table #ptMaxRecDate
select compItem,  Max(RecordDate) as RecordDate
into #ptMaxRecDate
from Merch2.dbo.pxfbillxref
group by compItem, ShipItemPLN

select distinct x.CompItem, x.ShipItemPLN
into #ptXref
from Merch2.dbo.pxfbillxref x join #ptMaxRecDate m on x.CompItem = m.CompItem and x.RecordDate = m.RecordDate

select OrdNum, OrdQty, BuyerCode, PartNum, x.ShipItemPln, pl.Building
into #ptPOList
from pic705 p join  #ptXref x on p.PartNum = x.CompItem left join paclab pl on x.ShipItemPln = pl.ShipPackNum
where OrdStatus in('3','4') and isnumeric(partnum) = 0

drop table #ptFcst
select c.CompanyDescription, Sku, 
Case When c.CompanyDescription = 'Ginny''s' then Sum(Units) End as GinnysUnits,
Case When c.CompanyDescription = 'Seventh Avenue' then Sum(Units) End as SeventhUnits,
Case When c.CompanyDescription = 'Montgomery Ward' then Sum(Units) End as WardsUnits,
Case When c.CompanyDescription = 'Midnight Velvet' then Sum(Units) End as MVUnits,
Case When c.CompanyDescription = 'Ashro' then Sum(Units) End as AShroUnits,
Case When c.CompanyDescription = 'Country Door' then Sum(Units) End as CountryUnits,
Case When c.CompanyDescription = 'Monroe & Main' then Sum(Units) End as MMUnits
into #ptFcst
from Merch2.dbo.F21FcstDaily f join Merch2.dbo.F21OfferDaily cc on f.OfferID = cc.Offer_ID and f.OfferYear = cc.Offer_Year join MDW1.dbo.Company c on cc.Division_ID = c.PicsCompany
 where f.RecordDate = (Select Max(RecordDate) from Merch2.dbo.F21FcstDaily) and cc.Season_ID = 'F16'
 group by c.CompanyDescription, Sku

 Select Sku, 
 Sum(IsNull(GinnysUnits,0)) as GinnysUnits,
 Sum(IsNull(SeventhUnits,0)) as SeventhUnits,
 Sum(IsNull(WardsUnits,0)) as WardsUnits,
 Sum(IsNull(MVUnits,0)) as MVUnits,
 Sum(IsNull(AshroUnits,0)) as AshroUnits,
 Sum(IsNull(CountryUnits,0)) as CountryUnits,
 Sum(IsNull(MMUnits,0)) as MMUnits
 into #ptFcstSum
 from #ptFcst
 group by  Sku
 order by Sku


 Select p.*, i.Category_ID as RD, Right(i.Sub_Category_Id, 2) as SFC, f.GinnysUnits, f.SeventhUnits, f.WardsUnits, f.MVUnits, f.AshroUnits, f.CountryUnits, f.MMUnits
 from #ptPOList p left join #ptFcstSum f on p.ShipItemPln = f.Sku left join F21ItemMaster i on p.ShipItemPln = i.Sku
 --where i.Category_ID is null 


