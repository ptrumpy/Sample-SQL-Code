/****** Script for SelectTopNRows command from SSMS  ******/
select offer_product_ID, Page_no, Revenue, RANK() OVER 
    ( ORDER BY Revenue DESC) AS Rank
	into ##ptRankDemand
	from DT_CM_RESULTS
	where season_ID = 'F14' and offer_ID = 'NN' and version_No = '-1'
	order by Rank

	select offer_product_ID, Page_no, Units, RANK() OVER 
    ( ORDER BY Units DESC) AS Rank
	into ##ptRankUnits
	from DT_CM_RESULTS
	where season_ID = 'F14' and offer_ID = 'NN' and version_No = '-1'
	order by Rank


SELECT Cat_Desc as RDRdescription, SCAT_DESC as SFCDescription, dcr.PAGE_NO as PP, dcr.OFFER_PRODUCT_ID as Pack, NUM_SKUS as SKUs, KILL_WAIT_OK as KWO, AVG_RETAIL, PAGE_PERCENT as Space, dcr.Units, UPP, dcr.Revenue as DemandDollars,
SPP, dcr.Revenue*(GP_PERCENT/100) as GPDollars, GP_PERCENT, PHY_RETURN_PERCENT * dcr.Revenue as PRRDollars, PHY_RETURN_PERCENT as PRR, RETURNS_PROCESSING_COST, RETURN_PERCENT, INITIAL_FILL_PCT as INITFill, FINAL_FILL_PCT as
FinalFill, VENDOR_NAME, rd.Rank as RankDemand, ru.Rank as RankUnits 
From DT_CM_RESULTS dcr Join ##ptRankDemand rd
	 on dcr.OFFER_PRODUCT_ID = rd.OFFER_PRODUCT_ID
	Join ##ptRankUnits ru
	 on dcr.OFFER_PRODUCT_ID = ru.OFFER_PRODUCT_ID
where season_ID = 'F14' and offer_ID = 'NN' and version_No = '-1'
order by dcr.Page_no, CAT_DESC, dcr.Offer_Product_ID


