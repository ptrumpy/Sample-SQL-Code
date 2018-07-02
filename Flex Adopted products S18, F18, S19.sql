select productid, season,carryover, status, seasonalsellingqtr, lagocomments, allbrands
into ##ptseasonproduct
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_SeasonProduct 
where season in ('Fall 2018','Spring 2018', 'Spring 2019')

select packnumber, id, productname, sfc, primarybrand, color, sourcing, MerchantCodeId, Buyer
into ##ptproduct
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_Product

--drop table ##ptsource
select id, productid, vendorid, productadopted, name, gsotrackingnum, vendoritemnum, packagingstatus, directimport, commoditymgr, pdrturnover, tdhandoff, readyfordesignreview, PackageSentToVendor, SentToChina, CounterReviewMtgDt, PlacementNotice, PlacementNoticeDate, LabDipApproved, GSOPDRComments, killdate
into ##ptsource
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_source

select p.packnumber, s.vendoritemnum, s.vendorid, mv.vendor, mv.name
from
##ptseasonproduct sp left join
##ptproduct p on sp.productid = p.id left join 
##ptsource s on p.id = s.productid left join
[clu1prd2014\charlie,14503].vendisc.dbo.MasterVendor_PLM MV on S.VendorID = MV.VendorPLMNumber
where sp.status = 'adopted'
