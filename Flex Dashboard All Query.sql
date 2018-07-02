--drop table ##ptsample
select sourceid, requestname, samplecategory, RequestRequestDate, eta, Received, status as SampleStatus, comments as FlexSampleComments, VendorSampleComments, ReqSequence
into ##ptSample
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_Sample where status in('Req-no email','Requested','Received','Approved') and seasonsample = 'Fall 2018' and sourceid is not null


select productid, season,carryover, status, seasonalsellingqtr, lagocomments, allbrands
into ##ptseasonproduct
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_SeasonProduct 
where season = 'Fall 2018'

select packnumber, id, productname, sfc, primarybrand, color, sourcing, MerchantCodeId, Buyer
into ##ptproduct
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_Product

--drop table ##ptsource
select id, productid, productadopted, name, gsotrackingnum, vendoritemnum, packagingstatus, directimport, commoditymgr, pdrturnover, tdhandoff, readyfordesignreview, PackageSentToVendor, SentToChina, CounterReviewMtgDt, PlacementNotice, PlacementNoticeDate, LabDipApproved, GSOPDRComments, killdate
into ##ptsource
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_source

select id, sourceid
into ##ptCostSheet
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_CostSheet

--drop table ##ptcostsheetrequest
select costsheetid, costsheetname, costsheettype, elc, costsheetstatus, datequoterequested, DateQuoteReceived, QuoteExpiration, MerchApprovedDate, FOB, MinOrderQty
into ##ptcostsheetrequest
from [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_CostSheetRequest 
where CurrentCostSheet = 1 and SeasonID = 'Fall 2018'

--drop table ##ptminreqdate
select costsheetid, min(requestdate) as MinReqDate
into ##ptMinReqDate
from  [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_CostSheetRequest 
where currentcostsheet = 1 and seasonid = 'Fall 2018'
group by costsheetid


select distinct s.productid, cs.sourceid,case sp.carryover when 'C' then 'Carryover' When 'N' then 'New' End as carryover, sp.status, sp.SeasonalSellingQtr, sp.allbrands, sp.LagoComments,p.PackNumber, p.id, 
p.ProductName, p.SFC + ' - ' + sfc.description as SFC, p.PrimaryBrand, p.Color, p.sourcing, p.buyer + ' - ' + bc.buyername as ProductionMgr,rtrim(mc.merchcode) + ' - ' + m.Merch as Merchandiser, 
s.ProductAdopted, s.killdate, s.name, s.GSOTrackingNum, s.VendorItemNum, s.packagingstatus, s.directimport, s.commoditymgr, s.PDRTurnover, s.TDHandoff, s.ReadyforDesignReview, s.PackageSentToVendor,
s.SentToChina, s.CounterReviewMtgDt, s.PlacementNotice, s.PlacementNoticeDate, s.LabDipApproved, s.GSOPDRComments, sm.RequestName, sm.reqsequence, sm.SampleCategory, sm.RequestRequestDate, 
sm.eta, sm.Received, sm.FlexSampleComments, sm.VendorSampleComments, sm.SampleStatus, csr.costsheetname, csr.costsheettype,csr.elc, mr.MinReqDate as CostSheetCreated, 
csr.costsheetstatus, 
csr.datequoterequested, csr.datequotereceived, csr.quoteexpiration, csr.MerchApprovedDate, csr.fob, csr.MinOrderQty
from
##ptseasonproduct sp left join
##ptproduct p on sp.productid = p.id left join 
##ptsource s on p.id = s.productid
left join ##ptCostSheet cs on cast(s.id as varchar) = cs.SourceId
join ##ptcostsheetrequest csr on cs.id = csr.CostSheetId
left join ##ptMinReqDate mr on cs.id = mr.costsheetid 
left join ##ptsample sm on s.id = sm.sourceid
join SupplyChain_Misc.dbo.SFCCategory sfc on p.sfc = sfc.sfccategory 
left join [clu1prd2014\charlie,14503].ppmrk_flex.dbo.tbl_merchantcode mc on p.merchantcodeid = mc.id
left join supplychain_misc.dbo.MerchantCodes m on m.MerchCode = mc.merchcode	
left join supplychain_misc.dbo.BuyerCodes b on p.buyer = b.buyercode
left join supplychain_misc.dbo.BuyerContacts bc on b.buyercontactid = bc.buyercontactid
order by packnumber

select * from ##ptsource where productid = '234819'


select s.*, sm.* from 
(select id, productid, productadopted, name, gsotrackingnum, vendoritemnum, packagingstatus, directimport, commoditymgr, pdrturnover, tdhandoff, readyfordesignreview, PackageSentToVendor, SentToChina, CounterReviewMtgDt, PlacementNotice, PlacementNoticeDate, LabDipApproved, GSOPDRComments
from tbl_source) s left join ##ptsample sm on s.id = sm.sourceid 
order by id



left join ##ptSample sm on s.id = sm.sourceid
where s.id = 315051


select * from ##ptcostsheet  where cast(308685 as varchar) = sourceid (80044,82197)

select * from ##ptcostsheetrequest where costsheetid = '80044'
select * from ##ptsample where sourceid is null

SELECT        Season, COUNT(1) AS Count
FROM            [CLU1PRD2014\CHARLIE,14503].ppmrk_flex.dbo.tbl_SeasonProduct AS tbl_SeasonProduct_1
GROUP BY Season
ORDER BY RIGHT(Season, 4) DESC, LEFT(Season, CHARINDEX(season,' ') - 1)

select season, charindex(' ',season)
from  [CLU1PRD2014\CHARLIE,14503].ppmrk_flex.dbo.tbl_SeasonProduct