select * from supplychain_global_inventory.trumpy.F21WORK where 
    media_id in ('CAT','WEB','MWEB') and offer_year >=2016
	--(2960425 row(s) affected)
--drop table #ptRank
select fop.article as offer_product_id, case when fop.DiscountReasonCode in('TL','RL') then fop.season_id + ' Sale' else fop.season_id end as season_id, fop.DiscountReasonCode, season.row Rank 
into #ptRank 
from	(select o.season_id, i.article, item.DiscountReasonCode  from supplychain_global_inventory.trumpy.inv_breakapart i join merch2.dbo.f21offerdaily o on left(i.season,4) = o.offer_year and i.media = o.offer_id 
	join mdw1.dbo.item on left(i.season,4) = item.season and i.media = item.primarycatalogcode and i.article = ('6' + case when left(item.itemnumber,2) = '00' then Right(item.itemnumber,5) else right(item.ItemNumber,6) end)
	where o.media_id in('CAT','WEB','MWEB')) fop join
	(select *, row_number () Over (order by substring(season_id,2,2), left(season_id,1) desc, season_id) as Row from (select distinct season_id from supplychain_global_inventory.trumpy.F21WORK where offer_year >= (year(getdate())-1) and season_id <>''
union 
select distinct season_id + ' Sale' from supplychain_global_inventory.trumpy.F21WORK where offer_year >= (year(getdate())-1) and season_id <>'') b) season on fop.season_id = season.season_id;

select distinct a.packnum, a.shippacknum, a.compnum, a.newproposedDisp as GIDNewProposedDisp, qahold, case when b.rank > a.row then b.season_id else a.newproposedDisp end as MyNewProposedDisp
into #ptSeasonDisp
from 
(select packnum, shippacknum, compnum, newproposeddisp, qahold, season.row from SupplyChain_Global_Inventory.dbo.GlobalInvwith90DaysSales g  left join 
  (select *, row_number () Over (order by substring(season_id,2,2), left(season_id,1) desc, season_id) as Row from (select distinct season_id from supplychain_global_inventory.trumpy.F21WORK where offer_year >= (year(getdate())-1) and season_id <>''
union 
select distinct season_id + ' Sale' from supplychain_global_inventory.trumpy.F21WORK where offer_year >= (year(getdate())-1) and season_id <>'')a)  season on (case when g.newproposedDisp like '%Hold%' or g.newproposeddisp like '%Sale' then left(g.newproposeddisp,3) else g.newproposeddisp end) = season.season_id) a left join 

(select distinct a.offer_product_id, a.season_id, a.rank from #ptRank a join 
(select offer_product_id, max(rank) as rank  from #ptRank group by offer_product_id) b on a.offer_product_id = b.offer_product_id and a.rank = b.rank
) b on a.packnum = b.offer_product_id  --where a.newproposeddisp <> (case when b.rank > a.row then b.season_id --else a.newproposedDisp 
--end) 
where qahold <>'Y';

Update c
set c.newproposeddisp = g.MyNewProposedDisp
from supplychain_global_inventory.trumpy.ExcessCommentsTest c join #ptSeasonDisp g
on c.compnum = g.compnum and c.shippacknum = g.shippacknum;


--Update Season Liq to Liquidation
select old.*, case when offercount=percentcompleteoffercount and percentcompleteoffercount > 0 then 'Liquidate' else old.newproposeddisp end as MyNewProposedDisp
into #ptLiquidate
from
(select globalinv.*,left(globalinv.newproposeddisp,3) as Season,  count(distinct complete.offer) as OfferCount, Sum(case when complete.percent_complete >= .8 then 1 else 0 end) as PercentCompleteOfferCount
from
(select compnum, shippacknum, packnum, description, marketingdesc, newproposeddisp
from globalinvwith90dayssales
where newproposeddisp like '%Liq') GlobalInv
left join
(select a.*, b.percent_complete from seasonofferpack a join merch2.dbo.f21offerdaily b on a.season = b.season_id and a.offer = b.offer_id --where a.season = 's17'
) complete
on globalinv.packnum = complete.pack and left(globalinv.newproposeddisp,3) = complete.season
group by globalinv.compnum, globalinv.shippacknum, globalinv.packnum, globalinv.description, globalinv.marketingdesc, globalinv.newproposeddisp, left(globalinv.newproposeddisp,3)) old;

Update c
set c.newproposeddisp = g.MyNewProposedDisp
from trumpy.ExcessCommentsTest c join #ptLiquidate g
on c.compnum = g.compnum and c.shippacknum = g.shippacknum;

--Update ExcessStatus
Update c
set excessstatus = (case when a.excessnoreorderflag = 'Y' then 'Bad'
 when a.newproposeddisp like '%Hold%' or a.newproposeddisp like '%RTV%' or a.newproposeddisp ='liquidate' or a.newproposeddisp like '%Liq' then 'Bad'
 when a.newproposeddisp like '%Sale%' and excessnoreorderflag = 'Y' then 'Bad'
when a.newproposeddisp in (select distinct season_id from merch2.dbo.f21offerdaily) and excessnoreorderflag is null then 'Good' End)
 from trumpy.ExcessCommentsTest c join SupplyChain_Global_Inventory.dbo.GlobalInvWith90DaysSales a  on a.shippacknum = c.shippacknum and a.compnum = c.CompNum;
						  						  


