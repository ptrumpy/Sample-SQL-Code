/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Catalog], Sum ([ActualQty]) as ActQty, sum ([EstQty]) as EstQty
      
  FROM [MDW1].[dbo].[AdCode]
  where season = 2014 and companycode in ('S', 'F')
  group by catalog
  order by catalog