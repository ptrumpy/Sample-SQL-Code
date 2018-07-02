SELECT CalendarSeq, Sum(Unitsbackordercummulative * (
			CASE 
				WHEN unitsdemanded = 0
					THEN 0
				ELSE dollarsdemanded / unitsdemanded
				END
			)) as BODollars
	,Sum(unitsbackordercummulative) as BOUNits
	,Sum(unitsdemanded - (unitsnotship + unitslost)) / Sum(cast(Unitsdemanded AS DECIMAL)) as InitFill
	,Sum(unitsshipped+unitsbackordercurrent) / Sum(cast(unitsdemanded AS DECIMAL)) as FinalFill
	,Sum(isnull(DollarsLost,0) + dollarsshipdelete) as LostSalesDollars
	,Sum(unitsLost + unitsshipdelete ) as LostSalesUnits
	,Sum(Dollarsdemanded) as DemandDollars
	,Sum(unitsdemanded) as DemandUnits
	,Sum(unitsdeleted * (
			CASE 
				WHEN unitsdemanded = 0
					THEN 0
				ELSE dollarsdemanded / unitsdemanded
				END
			)) as DollarsDeleted
FROM fillrate
WHERE   calendarseq in('758','705','810') and RDCategory <>'77' and ((companycode IN ('7', 'L', 'J', 'M', 'C', 'G', 'W', 'Q', 'O') and catalogcodeprefix NOT LIKE '%$')
or
(RDCategory <>'77' AND companycode NOT IN ('P', 'B') AND (catalogcodeprefix LIKE 'R%')))
group by CalendarSeq



select CalendarSeq
	,Sum(TotOnHand*CompCost) as OH
	,Sum(OnOrder*CompCost) as OO
	,Sum(TotOHExcessDollars) as TotExcessOH
	,Sum(TotOnOrdExcessDollars) as TotExcessOO
 from GlobalInventory where calendarSeq in('758','810')
 group by CalendarSeq