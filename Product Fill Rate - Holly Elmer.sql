SELECT CASE 
		WHEN f.itemnumber < 100000
			THEN f.itemnumber + 600000
		ELSE f.itemnumber + 6000000
		END AS Pack
	,i.Description
	,f.RDCategory AS RD
	,merchname
	,f.merchandisercode AS MC
	,NAME
	,f.vendorcode AS VendNum
	,i.VendorName
	,Sum(unitsshipped) AS UnitsShipped
	,Sum(UnitsDemanded) AS UnitsDemanded
	,Sum(DollarsDemanded) AS DollarsDemanded
	,Sum(UnitsBackOrderCurrent) as UnitsBOCurrent
	,Sum(UnitsBackORderCummulative) as UnitsBOCumulative
	,Sum(UnitsLost) as UnitsLost
	,Sum(DollarsLost) as DollarsLost
	,Sum(UnitsShipDelete) as UnitsShipDelete
	,Sum(DollarsShipDelete) as DollarsShipDelete
	,SUm(UnitsNotShip) as UnitsNotShip
	,Sum(UnitsDeleted) as UnitsDeleted
	,Sum(UnitsShippingDelete) as UnitsShippingDelete
	,Sum(UnitsNLA) as UnitsNLA
	,Case WHen Sum(UnitsDemanded) = 0 then 0 else (Sum(UnitsDemanded) - Sum(unitsnotship + unitslost))/Sum(cast(UnitsDemanded as decimal(9,2))) End as InitFill
	,Case When Sum(UnitsDemanded) = 0 then 0 else (Sum(UnitsShipped)+Sum(UnitsBackordercurrent))/Sum(cast(UnitsDemanded as decimal(9,2))) End as FinalFill
FROM fillrate_merge f left join Kimball.MDW1.dbo.item i on f.catalogcodeprefix = i.PrimaryCatalogCode and f.Year = i.Season and f.ItemNumber = i.ItemNumber
Left Join Merch.dbo.eabmedia e On f.catalogcodeprefix = e.catcd and f.Year = e.Year
where f.CompanyCode = 'Q' and CalendarSeq = '831' and e.mediagrp = 'MAJOR' and f.RdCategory !='77' and f.Season = 'S15'
group by  CASE 
		WHEN f.itemnumber < 100000
			THEN f.itemnumber + 600000
		ELSE f.itemnumber + 6000000
		END
	,i.Description
	,f.RDCategory 
	,merchname
	,f.merchandisercode
	,NAME
	,f.vendorcode
	,i.VendorName