Drop table #ptFcst418
select OfferYEar, OfferID, OfferProductID, Sum(Units) as Units411
into #ptFcst411
from f21FcstWeekly 
where recorddate = '2016-04-11 00:00:00'
group by OfferYEar, OfferID, OfferProductID

select OfferYear, OfferID, OfferProductID, Sum(Units)  as Units421
into #ptFcst421
from f21FcstDaily 
where recorddate = '2016-04-21 00:00:00'
group by OfferYear, OfferID, OfferProductID

drop table #ptItem
select '6' + case when left(itemnumber,2) = '00' then Right(itemnumber,5) else right(ItemNumber,6) end as ItemNumber, i.Description, PrimaryCatalogCode, i.Season as MailYear, c.Season, c.MediaID, cc.TypeFlag, BuyerCode, MErchandiserCode, RDCategory, SFCategory, co.CompanyDescription
into #ptItem
from MDW1.dbo.Item i join Merch.dbo.eabmedia c on i.PrimaryCatalogCode = c.Catcd and i.Season = c.Year join MDW1.dbo.CatalogCodes cc on i.PrimaryCatalogCode = cc.Catalog and i.Season = cc.MailYear join MDW1.dbo.Company co on cc.CompanyCode = co.Company
where c.Season = 'F16'

Select d.OfferProductID, i.Description, d.OfferID, i.Season, i.MediaID, i.BuyerCode, i.MerchandiserCode,i.RdCategory, r.RDDescription as RDDesc, i.SfCategory, s.SFDescription as SFCDesc, i.CompanyDescription as Company, isnull(w.Units411,0) as Units411, isnull(d.Units421,0) as Units421
from #ptFcst421 d join #ptItem i on d.OfferYEar = i.MailYear and d.OfferID = i.PrimaryCatalogCode and d.OfferProductID = i.ItemNumber
	left Join #ptFcst411 w on w.OfferYEar = d.OfferYear and w.OfferID = d.OfferID and w.OfferProductID = d.OfferPRoductID left join MDW2.dbo.RDCategory r on i.RdCategory = r.RDCategory left join MDW2.dbo.SfCode s on i.RdCategory = s.RDMasterCode and i.SFCategory = s.SFMasterCode

	

