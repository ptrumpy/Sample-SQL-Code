Select distinct a.calendarSeq, b.item, b.RdCategory, b.Division, b.RdDescription, b.SfCategory, b.SfCDescription, b.Description
into #ptAllPacks
From 
(select distinct calendarSeq, '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as Item from merch2.dbo.Fillrate where season = 'F16') a 
--order by calendarseq  
,
(select distinct '6' + case when left(f.itemnumber,2) = '00' then Right(f.itemnumber,5) else right(f.ItemNumber,6) end as Item, i.Description, f.RdCategory, rd.Division, rd.Description as RDDescription, i.SfCategory, sf.Description as SfCDescription 
from merch2.dbo.Fillrate f join MDW1.dbo.Item i on f.Year = i.Season and f.catalogcodeprefix = i.PrimaryCatalogCode and f.ItemNumber = i.ItemNumber 
left join SupplyChain_Misc.dbo.RdCategory rd on f.Rdcategory = rd.Rdcategory 
left Join SupplyChain_Misc.dbo.SfCCategory sf on (i.Rdcategory + i.SfCategory) = sf.SfCCategory where calendarSeq = (Select Max(CalendarSeq) from Merch2.dbo.Fillrate) and f.Season = 'F16') b 
order by a.CalendarSeq


select Coalesce(f.CalendarSeq, b.CalendarSeq) as CalendarSeq, Coalesce(r.Division, b.Division) as Division,Coalesce(f.ItemNumber, b.Item) as ItemNumber, Coalesce(f.Description, b.Description) as Description, Coalesce(f.RdDescription, b.rddescription) as RDDescription, coalesce(f.RDCategory, b.rdcategory) as rdcategory, Coalesce(f.SfCategory, b.SFCategory) as SFCategory, Coalesce(f.SfDescription, b.SFCDescription) as SFDescription

select f.WeekEndDate, f.CalendarSeq, r.Division, f.ItemNumber, f.Description, f.CalendarSeq, f.RDDescription, f.RDCategory, f.SfCategory, f.sfDescription,  SUM(UnitsDemanded * Retail) AS DollarsDemanded, SUM(UnitsDemanded) AS UnitsDemanded,
SUM(UnitsNotShip) AS UnitsNotShipped, Sum(UnitsLost) AS UnitsLost
from tempwork.dbo.inventoryreportfillrateb f join SupplyChain_Misc.dbo.RdCategory r on f.rdcategory = r.RdCategory
join Mdw1.dbo.Item i on (case when left(f.season,1) = 'S' then f.Year-1 else f.Year End) = i.Season and f.AllocatedCatalog = i.PrimaryCatalogCode and f.ItemNumber = ('6' + case when left(i.itemnumber,2) = '00' then Right(i.itemnumber,5) else right(i.ItemNumber,6) end)
left join SupplyChain_Global_Inventory.trumpy.inv_breakapart g on f.ItemNumber = g.Article and f.Allocatedcatalog = g.Media and f.year =  (Case when substring(g.season,6,1)='F' then Left(g.Season,4) else Left(g.Season,4)-1 End) 
WHERE Season in(@Season) and r.Division in (@Division) and  f.Allocatedcatalog not like '%$' and (@IncludeRedlines = 1 or (@IncludeRedlines = 2 and i.DiscountReasonCode not in ('RL','TL')) or(@IncludeRedlines = 3 and i.DiscountReasonCode in('RL','TL')) ) 
AND
(@IncludeExcessNoReorder = 1 or(@IncludeExcessNoReorder = 2 and g.ExcessNoReorderFlag in('','N')) or (@IncludeExcessNoReorder = 3 and g.ExcessNoReorderFlag = 'Y'))
GROUP BY f.weekenddate,f.CalendarSeq, r.Division, f.ItemNumber, f.Description, f.CalendarSeq, f.RDDescription, f.RDCategory, f.SfCategory, f.sfDescription


Coalesce(f.CalendarSeq, b.CalendarSeq), Coalesce(r.Division, b.Division),Coalesce(f.ItemNumber, b.Item), Coalesce(f.Description, b.Description), 
Coalesce(f.RdDescription, b.rddescription), coalesce(f.RDCategory, b.rdcategory), Coalesce(f.SfCategory, b.SFCategory), Coalesce(f.SfDescription, b.SFCDescription)
 --order by CalendarSeq


 select * from #ptAllPacks where item = '607790'
 order by calendarSeq


 select * from tempwork.dbo.inventoryreportfillrateb where itemnumber = '6719036'