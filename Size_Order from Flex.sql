SELECT [PackNumber]
      ,B.ColorwayName
      ,[SizeDesc]
      ,[PLN]
      ,[PLNLongDesc]
      ,[SC]
      ,[SCDesc]
         --,A.[ID]
      ,C.SortOrder
FROM PPMRK_Flex.dbo.tbl_product Prod 
                    inner Join (PPMRK_Flex.dbo.[tbl_PLNSCMap] A 
                                               inner join PPMRK_Flex.dbo.tbl_colorway B on a.productid=b.productid and a.colorwayID = b.id
                                               inner join PPMRK_Flex.dbo.tbl_SizeFamily C on A.SizeTemplate = C.SizeFamily and A.SizeDesc=C.Size)
                    on Prod.id=A.ProductId
Where PackNumber!=0
Order by a.ID
