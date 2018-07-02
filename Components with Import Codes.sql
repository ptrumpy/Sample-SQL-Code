select  a.CompItem, b.ItemDescription, b.Buyer, a.CountryName, a.CompImportClass  
from Merch2.[dbo].[PxfBillXRefVw] a 
join bakery.[dbo].[vw_ItemMaster] b on a.compitem = b.ItemNumber
where a.RecordType <>'D' and a.activecatflag = 'A' 


