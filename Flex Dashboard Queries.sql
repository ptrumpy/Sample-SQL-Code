--startingpoint 271,517 recs
select productid, season,carryover, status, seasonalsellingqtr, lagocomments, allbrands
from tbl_SeasonProduct 
where season = 'Fall 2018' 

--product 230,603 rows
select packnumber, id, productname, sfc, primarybrand, color, sourcing
from tbl_Product

--source 233,038 rows
select id, productid, productadopted, name, gsotrackingnum, vendoritemnum, packagingstatus, directimport, commoditymgr, pdrturnover, tdhandoff, readyfordesignreview, PackageSentToVendor, SentToChina, CounterReviewMtgDt, PlacementNotice, PlacementNoticeDate, LabDipApproved, GSOPDRComments
from tbl_source


--cost sheet just need keys for lookup to CostSheetRequest and join to source 78,812 rows
select id, sourceid
from tbl_CostSheet

--cost sheet request 78,812 rows
select costsheetid, costsheettype, elc, costsheetstatus, datequoterequested, DateQuoteReceived, QuoteExpiration, MerchApprovedDate, FOB, MinOrderQty
from tbl_CostSheetRequest 
where CurrentCostSheet = 1  

--costsheetrequest min(requestdate) 78,812 rows
select costsheetid, min(RequestDate) as FirstRequestDate
from tbl_CostSheetRequest 
group by CostSheetId

--sample 314,682 rows
select sourceid, requestname, samplecategory, RequestRequestDate, eta, Received, status as SampleStatus, comments as FlexSampleComments, VendorSampleComments
from tbl_Sample

