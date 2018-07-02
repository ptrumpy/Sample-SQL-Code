Ensemble
SELECT DISTINCT ITEM_NUMBER AS Ensemble, MIN(NAME) AS Description
FROM [InternetProductData].[dbo].[products]
GROUP BY ITEM_NUMBER

Family
SELECT DISTINCT ITEM_NUMBER AS Family, MIN(NAME) AS Description
FROM [InternetProductData].[dbo].[products]
GROUP BY ITEM_NUMBER


Family/Ensemble
SELECT '6' + case when left(orderable_item_number,1) = '0' then Right(orderable_item_number,5) else orderable_Item_Number end AS ItemNumber, Family, Ensemble
FROM TempWork.dbo.InventoryBackOrderFamilyEnsemble