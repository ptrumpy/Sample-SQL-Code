--drop table #ptMaxRD
--get max rd from item table
select distinct season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, Max(RdCategory) as RD
into #ptMaxRD
from MDW1.dbo.Item
where season > 2012
group by season, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end

--drop table #ptRDSFC
-- get sfc and other data that match up with max rd
select distinct r.Season, r.ITemNumber, Max(r.RD) as RD, i.SFCategory as SFC, i.PrimaryShippingLocation, Min(Case WHen i.ImportCode = 'GS' then 'GSO' else 'Non_GSO' end) as GSO
into #ptRDSFC
from #ptMaxRD r join MDW1.dbo.item i on r.Season = i.season and r.ItemNumber = ('6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end) and r.RD = i.RdCategory
group by r.Season, r.ITemNumber, i.SFCategory, i.PrimaryShippingLocation

combine dmr data with rd info
Select distinct Year(dmrinitdt) as Year, r.RD, rd.Description as RDDesc, DetItemNumber, DetSku, DMRNum, QtyOnHold,DetRecvQty, Category, Exclude, m.Vendor 
into #ptDMR
from [clu1prd2014\charlie,14503].PPQAD_QASpec.dbo.tbl_DMRMain m 
Left Join [clu1prd2014\charlie,14503].PPQAD_QASpec.dbo.tbl_DMRDetail d on m.id = d.DetDMRMainId
left join #ptRDSFC r on d.detitemnumber = r.itemNumber and year(m.dmrinitdt) = r.season
join SupplyChain_Misc.dbo.rdcategory rd on r.rd = rd.RdCategory 
where (Year(DMRInitDT) in ('2014','2015','2016') and Exclude in(null,'0')) or
(Year(detRecvDate) in ('2014','2015','2016') and Exclude in(null,'0'))

--do a distinct count of DMRs by Year by RD
select Year, RD, RDDesc, Count(distinct DMRNum) as DMRCOunt
from #ptDMR 
group by Year, RD, RDDesc