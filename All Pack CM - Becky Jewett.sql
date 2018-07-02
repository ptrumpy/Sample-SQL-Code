
SELECT        Max(CalendarSeq) AS CalendarSeq
INTO              #ptMaxCalendarSeq
FROM           Merch2.dbo.Fillrate_Merge
WHERE        season = 'F16' 
                             Drop table #ptFillrate
							 SELECT        f.CalendarSeq, f.Year, f.season,  f.catalogcodeprefix, 
                                                       CASE WHEN f.itemnumber < 100000 THEN f.ItemNumber + 600000 ELSE f.ItemNumber + 6000000 END AS ItemNumber, f.rdcategory, f.merchname, 
                                                       f.merchandisercode, f.NAME, f.vendorcode, f.unitsshipped, f.unitsdemanded, f.dollarsdemanded, f.unitsbackordercurrent, f.unitsbackordercummulative, 
                                                       f.unitslost, f.dollarslost, f.unitsshipdelete, f.dollarsshipdelete, f.unitsnotship, f.unitsdeleted, f.unitsshippingdelete, f.unitsnla, 
                                                       r.RDDescription, e.mediagrp, i.VendorName, i.Description, Case when f.UnitsDemanded = 0 then 0 else Round(((cast(f.UnitsDemanded AS decimal(9, 2)) - cast((f.unitsnotship + f.unitslost) 
                                                       AS decimal(9, 2))) / cast(f.UnitsDemanded AS decimal(9, 2))) * 100, 2) End AS InitialFillRate, Case when f.UnitsDemanded = 0 then 0 else Round((cast((f.unitsShipped + f.unitsbackordercurrent) 
                                                       AS decimal(9, 2)) / cast(f.UnitsDemanded AS decimal(9, 2))) * 100, 2) End AS FinalFillRate
                              Into #ptFillrate
							  FROM            Merch2.dbo.FillRate_Merge f JOIN
                                                      MDW2.dbo.RDCategory r ON r.RDCategory = f.rdcategory LEFT JOIN
                                                       Merch.dbo.eabmedia e ON f.catalogcodeprefix = e.catcd AND f.Year = e.Year LEFT JOIN
                                                       MDW1.dbo.Item i ON f.year = i.Season AND f.catalogcodeprefix = i.PrimaryCatalogCode AND f.itemnumber = i.itemnumber JOIN
                                                       ODW1.dbo.FiscalCalendar q ON f.CalendarSeq = q.CalendarSeq JOIN
                                                       #ptMaxCalendarSeq m ON f.CalendarSeq = m.CalendarSeq
                              WHERE        f.Season =  'F16' AND f.RDCategory != '77'

--Get END Version or last published version (-1) if no END version
Drop table #ptVersion
select distinct offer_id, offer_year, version_no, version_type 
into #ptVersion
from DT_CM_RESULTS
where Version_type = 'END' and version_no !='-1' and season_id = 'F16' and len(offer_id)=2
union 
select distinct offer_id, offer_year, version_no, version_type  
from DT_CM_RESULTS
where Version_type != 'END' and version_no ='-1' and season_id = 'F16' and len(offer_id)=2
 and offer_ID+cast(Offer_Year as varchar(4)) not in(select distinct offer_id+ cast(offer_year as varchar(4))
from DT_CM_RESULTS
where Version_type = 'END' and version_no !='-1' and season_id = 'F16')
order by Offer_year, Offer_ID, Version_No

SELECT distinct SEASON_ID, c.OFFER_YEAR
	,Brand
	,c.OFFER_ID
	,CATEGORY_ID
	,CAT_DESC
	,SUB_CATEGORY_ID
	,SCAT_DESC
	,PAGE_NO
	,OFFER_PRODUCT_ID
	,OFFER_PRODUCT_DESC
	,NUM_SKUS
	,KILL_WAIT_OK
	,CAT_ORD_POLICY
	,EXCLUSIVE_CODE
	,IMPORT_CODE
	,VENDOR_NAME
	,AVG_RETAIL
	,PAGE_PERCENT
	,Units
	,UPP
	,REVENUE
	,SPP
	,Revenue *(GP_PERCENT/100) as GPDollars
	,GP_PERCENT
	,PHY_RETURN_PERCENT
	,Case When PHY_RETURN_PERCENT is null then 0 else (PHY_RETURN_PERCENT/100) * Revenue End as PRRDollars
	,RETURNS_PROCESSING_COST
	,RETURN_PERCENT
	,CM_DOLLARS
	,CM_DOLLAR_IDX
	,CM_PERCENT
	,CM_PERCENT_IDX
	,f.InitialFillRate
	,f.FinalFillRate
	,CASE 
		WHEN IMPORT_CODE = 'GS'
			THEN 'GSO'
		ELSE 'Non-GSO'
		END AS Channel
	,Product_Engineer as MerchCode
	,m.Merch
	, Case When Avg_Retail between 1 and 50 then '1-50'
			When Avg_Retail between 51 and 100 then '51-100'
			WHen Avg_Retail between 101 and 150 then '101-150'
			When Avg_Retail between 151 and 200 then '151-200'
			When Avg_Retail between 201 and 250 then '201-300'
			Else '> 300'
			End as PriceRange
FROM DT_CM_RESULTS c Left Join #ptFillrate f on c.OFFER_ID = f.catalogcodeprefix and c.offer_year = f.Year and c.OFFER_PRODUCT_ID = f.ItemNumber
join #ptVersion v on c.Offer_year = v.Offer_Year and c.Offer_ID = v.Offer_ID and c.Version_No = v.Version_no and c.Version_type = v.Version_Type
join SupplyChain_Misc.dbo.MerchantCodes m on c.Product_engineer = m.MerchCode
WHERE SEASON_ID = 'F16'  and len(c.offer_id) = 2 and Brand not in('Swiss Colony', 'Wisconsin Cheeseman','Tender Filet')
