select Season_ID, Offer_ID, Category_ID as RD, Cat_Desc as RDDescription, Sub_Category_ID as SFC, SCat_Desc as SFCDescription,  Offer_PRoduct_ID as Pack, Offer_Product_desc as Description, Product_Engineer as MerchCode, Units, Revenue
from DT_CM_RESULTS 
where VENDOR_NAME like '%CLARKS%' and Offer_Year in(2011,2012, 2013, 2014) and version_no = '-1' and Season_id !='F11' and len(offer_ID) = 2
order by Right(Season_ID,2), Left(Season_ID,1) desc


