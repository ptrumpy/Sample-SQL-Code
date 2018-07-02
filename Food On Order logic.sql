select p.PartNum, p.OrdNum, (p.ordQty-p.QtyRcvd) as OrdQty, p.shrtOrder, p.VendorNum, p.VendorName from [johnson\dept_app_prod].NFIM.dbo.PIC705 p join [johnson\dept_app_prod].NFIM.dbo.BuyerCodes b on p.BuyerCode = b.BuyerCode 
join bakery.dbo.vw_itemmaster i on p.PartNum = i.itemnumber
where b.Division = 'F' and p.VendorNum is not null and i.CompanyCode = '84' and p.VendorNum !=''