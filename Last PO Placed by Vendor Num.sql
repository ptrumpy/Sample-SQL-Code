select v.VendorNumber as SourceVendorNum, p.VendorNumber, Case when isnumeric(p.vendornumber)=1 and left(p.vendornumber,2)='00' then  stuff(p.VendorNumber, 1, 2, '')
	when isnumeric(p.vendornumber)=1 and left(p.vendornumber,1)='0' then  stuff(p.VendorNumber,1,1,'') else p.VendorNumber End as ExcelVendorNum, v.VendorName, max(p.PlaceDate) as LastPOPlaced
	--into #ptPOList
	from merch2.[dbo].[vw_PODetail_MAXRecordDate] p right join (Select distinct VendorNumber, VendorName from SupplyChain_Misc.trumpy.VendorList)  v on (Case when isnumeric(p.vendorNumber) =1 and left(p.vendornumber,2)='00' then  stuff(p.VendorNumber, 1, 2, '')
	when isnumeric(p.vendornumber) = 1 and left(p.vendornumber,1)='0' then  stuff(p.VendorNumber,1,1,'') else p.VendorNumber End) = v.VendorNumber
 --where --p.vendornumber = '001522'
 --p.vendornumber is null
 group by  v.VendorNumber, p.VendorNumber, Case when left(p.vendornumber,2)='00' then  stuff(p.VendorNumber, 1, 2, '')
	when left(p.vendornumber,1)='0' then  stuff(p.VendorNumber,1,1,'') else p.VendorNumber End , v.VendorName
	order by v.VendorNumber


select v.SourceVendorNum, Coalesce(v.VendorNumber, b.VendorNum) as VendorNumber, v.VendorName, coalesce(v.LastPOPlaced, b.LastPOPlaced) as LastPOPlaced
from #ptPOList v left join (Select vendornum, max(OrdPlaceDate) as LastPOPlaced from SupplyChain_Misc.dbo.Pic430All group by vendornum) b on v.sourcevendornum = b.vendornum

