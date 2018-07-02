--For debugging (remove next 4 lines after pasting to dataset) –

DECLARE @DateFrom Date

DECLARE @DateTo Date

SET @DateFrom = '2016-01-01'

SET @DateTo = '2017-01-20'

-- End debugging script –

 

SELECT    
     Name, 
     Type

    , COUNT(Name) AS ExecutionCount

    , SUM(TimeDataRetrieval) AS TimeDataRetrievalSum

    , SUM(TimeProcessing) AS TimeProcessingSum

    , SUM(TimeRendering) AS TimeRenderingSum

    , SUM(ByteCount) AS ByteCountSum

    , SUM([RowCount]) AS RowCountSum

FROM

(

    SELECT TimeStart, Catalog.Type, Catalog.Name, TimeDataRetrieval,

  TimeProcessing, TimeRendering, ByteCount, [RowCount]

    FROM

    Catalog INNER JOIN ExecutionLog ON Catalog.ItemID =

       ExecutionLog.ReportID LEFT OUTER JOIN

    Users ON Catalog.CreatedByID = Users.UserID

    WHERE ExecutionLog.TimeStart BETWEEN @DateFrom AND @DateTo and path like '%Supply Chain/Production%')

 AS RE

GROUP BY
	Name, 
   Type

ORDER BY

      Type, Name