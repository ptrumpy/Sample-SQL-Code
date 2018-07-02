SELECT distinct 'P' AS "P/S"
	,Replace(Replace(Replace(b.CatalogItem,char(13),''),char(10),''), char(9),'') AS ID
	,'STD' AS ImageType
	,'\\page\Data\Corporate\APPS\QASpec\PPQAD_QASpecUpdate\PhotosUpload\' + PhotoFile AS Location
	,'N' AS StoreToDB
	,Replace(Replace(Replace(Replace(s.Description, ',', '-'),char(10),' '),char(9),' '),char(13),' ') AS ImageDesription
FROM (
	SELECT CatalogItem
		,Max(SpecMainID) AS SpecMainID
	FROM [Kimball\ODS].PPQAD_QASpec.dbo.tbl_CatalogItem
	GROUP BY CatalogItem
	) b
LEFT JOIN [Kimball\ODS].PPQAD_QASpec.dbo.tbl_SpecMain s ON b.SpecMainID = s.SpecMainID
LEFT JOIN [Kimball\ODS].PPQAD_QASpec.dbo.tbl_SpecNonFood n ON s.SpecMainID = n.SpecMainID
Left Join F21ApparelINSN f on b.CatalogItem = f.Pack
WHERE '\\page\Data\Corporate\APPS\QASpec\PPQAD_QASpecUpdate\PhotosUpload\' + PhotoFile IS NOT NULL and s.AddDt > DateAdd(dd,-1,GetDate()) and f.Pack is not null--and b.CatalogItem in ('664402','664398','679622')
ORDER BY Replace(Replace(Replace(b.CatalogItem,char(13),''),char(10),''), char(9),'')