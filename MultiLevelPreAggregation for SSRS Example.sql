With RDSFCGSO as (select a.gso, a.category_id as RD, a.cat_desc as RDDescr, a.sub_category_id as SFC, a.sub_cat_desc as SFCDesc, a.revenue as DemandDollars, a.po_cost,
 a.expected_cost as Cost, a.com_percent, a.gp_percent, a.RETURN_PERCENT, a.units, a.num_skus, a.AVG_RETAIL, a.Avg_Units_Sold, a.INITIAL_FILL_PCT, a.Excl_Count,
 a.Excl_Pct, a.New_Count, a.New_Pct, a.Item_Count, b.revenue as RDGSORevenue, b.po_cost as RDGSOPOCost, b.expected_Cost as RDGSOExpCost, b.com_percent as RDGSOComPct, 
 b.gp_percent as RDGSOGPPct, b.return_percent as RDGSORetPct, b.units as RDGSOUnits, b.num_skus as RDGSONumSkus, b.avg_retail as RDGSOAvgRetail, 
 b.Avg_Units_Sold as RDGSOAvgUnitsSold, b.Initial_Fill_Pct as RDGSOInitFill, b.excl_Count as RDGSOExclCount, b.Excl_Pct as RDGSOExclPct, b.New_Count as RDGSONewCount, 
 b.New_pct as RDGSONewPct, b.Item_Count as RDGSOItemCount, row_number() OVER(PARTITION BY b.Category_id, b.GSO ORDER BY b.Category_id, a.sub_category_id) AS [RowNumber]
from SupplyChain_CM_Results.dbo.DT_RD_SFC_GSO_CM_RESULTS a join SupplyChain_CM_Results.dbo.DT_RD_GSO_CM_RESULTS b on a.Category_id = b.Category_id and a.gso = b.Gso and a.season_id = b.season_id
where a.season_id = 'F16' and a.category_id >='50')
Select gso, rd, RDDescr, SFC, SFCDesc, DemandDollars, po_cost, cost, com_percent, gp_percent, return_percent, units, num_skus, avg_retail, avg_units_sold, initial_fill_pct, excl_count,
	excl_pct, new_count, new_pct, item_count, 
	Case When Rownumber = 1 then RDGSORevenue else 0 End as RDGSORevenue, 
	Case When Rownumber = 1 then RDGSOPOCost else 0 End as RDGSOPOCost,
	Case When Rownumber = 1 then RDGSOExpCost else 0 End as RDGSOExpCost,
	Case When Rownumber = 1 then RDGSOComPct else 0 End as RDGSOComPct,
	Case When Rownumber = 1 then RDGSOGPPct else 0 End as RDGSOGPPct,
	Case When Rownumber = 1 then RDGSORetPct else 0 End as RDGSORetPct,
	Case When Rownumber = 1 then RDGSOUnits else 0 End as RDGSOUnits,
	Case When Rownumber = 1 then RDGSONumSkus else 0 End as RDGSONumSkus,
	Case When Rownumber = 1 then RDGSOAvgRetail else 0 End as RDGSOAvgRetail,
	Case When Rownumber = 1 then RDGSOAvgUnitsSold else 0 End as RDGSOAvgUnitsSold,
	Case When Rownumber = 1 then RDGSOInitFill else 0 End as RDGSOInitFill,
	Case When Rownumber = 1 then RDGSOExclCount else 0 End as RDGSOExclCount,
	Case When Rownumber = 1 then RDGSOExclPct else 0 End as RDGSOExclPct,
	Case When Rownumber = 1 then RDGSONewCount else 0 End as RDGSONewCount,
	Case When Rownumber = 1 then RDGSONewPct else 0 End as RDGSONewPct,
	Case When Rownumber = 1 then RDGSOItemCount else 0 End as RDGSOItemCount
	into #ptRDSFCGSO
	from RDSFCGSO
	order by rd, sfc, gso
	

	With SeasonRDSFCGSO as (Select a.*, b.revenue as SeasonGSORev, b.po_cost as SeasonGSOPOCost, b.expected_cost as SeasonGSOExpCost, b.com_percent as SeasonGSOcomPct, 
	b.gp_percent as SeasonGSOGPPct, b.return_percent as SeasonGSORetPct, b.Units as SeasonGSOUnits, b.num_skus as SeasonGSONumSkus, b.avg_retail as SeasonGSOAvgRetail,
	b.avg_units_sold as SeasonGSOAvgUnitsSold, b.initial_fill_pct as SeasonGSOInitFill, b.Excl_Count as SeasonGSOExclCount, b.Excl_Pct as SeasonGSOExclPct,
	b.New_Count as SeasonGSONewCount, b.New_Pct as SeasonGSONewPct, b.Item_Count as SeasonGSOItemCount, ROW_NUMBER() over(partition by b.gso order by a.RD, a.SFC) as RowNumber
	from #ptRDSFCGSO a join SupplyChain_CM_Results.dbo.DT_SEASON_GSO_CM_RESULTS b on a.gso = b.gso
	where b.Season_id = 'F16')
	Select gso, rd, rddescr, sfc, sfcdesc, demanddollars, po_cost, com_percent, gp_percent, return_percent, units, num_skus, avg_retail, avg_units_sold, 
	Initial_fill_pct,  Excl_count, excl_pct, new_count, new_pct, Item_count, RDGSORevenue, RDGSOpocost, rdgsocompct,rdgsogppct, rdgsoretpct, rdgsounits, rdgsonumskus,
	rdgsoavgretail, rdgsoavgunitssold, rdgsoInitfill,  rdgsoExclcount, rdgsoexclpct, rdgsonewcount, rdgsonewpct, rdgsoItemcount,
	Case When Rownumber = 1 then SeasonGSORev else 0 End as SeasonGSORev, 
	Case When Rownumber = 1 then SeasonGSOPOCost else 0 End as SeasonGSOPOCost,
	Case When Rownumber = 1 then SeasonGSOExpCost else 0 End as SeasonGSOExpCost,
	Case When Rownumber = 1 then SeasonGSOComPct else 0 End as SeasonGSOComPct,
	Case When Rownumber = 1 then SeasonGSOGPPct else 0 End as SeasonGSOGPPct,
	Case When Rownumber = 1 then SeasonGSORetPct else 0 End as SeasonGSORetPct,
	Case When Rownumber = 1 then SeasonGSOUnits else 0 End as SeasonGSOUnits,
	Case When Rownumber = 1 then SeasonGSONumSkus else 0 End as SeasonGSONumSkus,
	Case When Rownumber = 1 then SeasonGSOAvgRetail else 0 End as SeasonGSOAvgRetail,
	Case When Rownumber = 1 then SeasonGSOAvgUnitsSold else 0 End as SeasonGSOAvgUnitsSold,
	Case When Rownumber = 1 then SeasonGSOInitFill else 0 End as SeasonGSOInitFill,
	Case When Rownumber = 1 then SeasonGSOExclCount else 0 End as SeasonGSOExclCount,
	Case When Rownumber = 1 then SeasonGSOExclPct else 0 End as SeasonGSOExclPct,
	Case When Rownumber = 1 then SeasonGSONewCount else 0 End as SeasonGSONewCount,
	Case When Rownumber = 1 then SeasonGSONewPct else 0 End as SeasonGSONewPct,
	Case When Rownumber = 1 then SeasonGSOItemCount else 0 End as SeasonGSOItemCount
	from SeasonRDSFCGSO
	order by rd, sfc, gso