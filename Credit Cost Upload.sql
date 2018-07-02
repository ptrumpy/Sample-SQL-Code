Select year, '6' + case when left(itm,2) = '00' then Right(itm,5) else right(Itm,6) end as itm, cat, Case when arcc < 0 or arcc > 100 then .1 else arcc End as arcc  
from MDW1.dbo.ItemCreditCost i join merch2.dbo.f21OfferDaily o on i.cat = o.Offer_id and i.year = o.offer_year
where o.season_id in(Case when month(GetDate()) between 1 and 6 then 'F' + right(cast(year(getDate()) -1 as varchar(4)),2) Else 'F' + right(cast(year(getdate()) as varchar(4)),2) End, 'S' + right(cast(year(getDate()) as varchar(4)),2))

