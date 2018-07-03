USE [Merch2]
GO
/****** Object:  StoredProcedure [SWISS_COLONY\Trumpy].[pt_ReturnsAllMajorCompanies]    Script Date: 7/3/2018 9:51:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Phil trumpy
-- Create date: 8/31/2010
-- Description:	
-- =============================================
ALTER PROCEDURE [SWISS_COLONY\Trumpy].[pt_ReturnsAllMajorCompanies] 
	-- Add the parameters for the stored procedure here
	@StartDate smalldatetime, 
	@EndDate smalldatetime,
	--@Company varchar(25),
	@BeginDate varchar(8)='0',
	@EndingDate varchar(8)='0'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Set @BeginDate = (Cast(DatePart(yyyy,@StartDate) as varchar(4)) + (Case When DatePart(mm,@StartDate) < 10 Then '0' + Cast(DatePart(mm,@StartDate) as VarChar(2)) Else Cast(DatePart(mm,@StartDate) as Varchar(2)) End)+ (Case When DatePart(dd,@StartDate) < 10 Then '0' + Cast(DatePart(dd,@StartDate) as varchar(2)) Else Cast(DatePart(dd,@StartDate) as Varchar(2)) End))
Set @EndingDate = (Cast(DatePart(yyyy,@EndDate) as varchar(4)) + (Case When DatePart(mm,@EndDate) < 10 Then '0' + Cast(DatePart(mm,@EndDate) as VarChar(2)) Else Cast(DatePart(mm,@EndDate) as Varchar(2)) End)+ (Case When DatePart(dd,@EndDate) < 10 Then '0' + Cast(DatePart(dd,@EndDate) as varchar(2)) Else Cast(DatePart(dd,@EndDate) as Varchar(2)) End))
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptShp'))
		DROP TABLE #ptShp
	
	SELECT AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, Shippeditem, 
       CatalogYear, ItemPrefix, ShipDelDate, ShippedQty, UnitPrice, StatusCode, c.CompanyCode
       into #ptShp
       from MDW1.dbo.ShipItem s join MDW1.dbo.CatalogCodes c on s.ItemPrefix = c.Catalog
       where ShipDelDate between @BeginDate and @EndingDate--	and c.CompanyCode = @Company
       
   Insert into #ptShp (AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, Shippeditem, 
       CatalogYear, ItemPrefix, ShipDelDate, ShippedQty, UnitPrice, StatusCode, CompanyCode)
       
       SELECT AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, Shippeditem, 
       CatalogYear, ItemPrefix, ShipDelDate, ShippedQty, UnitPrice, StatusCode, c.CompanyCode
       from MDW1.dbo.ShipItemHistory s join MDW1.dbo.CatalogCodes c on s.ItemPrefix = c.Catalog
       where ShipDelDate between @BeginDate and @EndingDate --and	c.CompanyCode = @Company
    
	--Removed below to help speed up report 4/13/16   
  --     Create Clustered Index IDX_Ship on #ptShp(AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence)
           
       
       IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptAdj'))
 DROP TABLE #ptAdj

SELECT a.AccountNumber, a.OrderNumber, ItemNo, s.ShippedItem, a.OriginalAddressSequence, a.OriginalLineitemSequence, a.OriginalShipItemSequence, 
       Sum(Qty) AS Qty, CASE a.Type WHEN 'RR' THEN Sum(a.UnitPrice * Qty) ELSE Sum(a.RefundAmount + a.Postage + a.ItemPostage) 
       END AS RetDollars
INTO #ptAdj
FROM MDW1.dbo.AdjustmentItem a JOIN #ptShp s 
	ON a.AccountNumber = s.AccountNumber AND a.OrderNumber = s.OrderNumber AND 
       a.OriginalAddressSequence = s.AddressSequence AND a.OriginalLineitemSequence = s.LineitemSequence AND 
       a.OriginalShipItemSequence = s.ShipItemSequence
WHERE     ShipDelDate between @BeginDate and @EndingDate 
GROUP BY a.AccountNumber, a.OrderNumber, a.ItemNo, a.OriginalAddressSequence, a.OriginalLineitemSequence, a.OriginalShipItemSequence, 
         s.ShippedItem, a.Type 
        
Create Clustered Index IDX_Adj on #ptAdj(AccountNumber, OrderNumber, OriginalAddressSequence, OriginalLineItemSequence, OriginalShipItemSequence)

IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptShpSummary'))
DROP TABLE #ptShpSummary

SELECT CompanyCode, AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, Shippeditem, 
       CatalogYear, ItemPrefix, ShipDelDate, Sum(ShippedQty) AS ShipQty, Sum(ShippedQty * UnitPrice) AS ShipDollars
INTO #ptShpSummary
FROM #ptShp
WHERE StatusCode = 'S' AND ShipDelDate between @BeginDate and @EndingDate
GROUP BY CompanyCode, AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence, OrderedItem, ShippedItem, CatalogYear, ItemPrefix, ShipDelDate

--Removed below to help speed up report 4/13/16
--Create Clustered Index IDX_ShipSum on #ptShpSummary(AccountNumber, OrderNumber, AddressSequence, ShipItemSequence, LineItemSequence)

IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptCombined'))
DROP TABLE #ptCombined

SELECT s.CompanyCode, s.AccountNumber, s.OrderNumber, s.AddressSequence, s.ShipItemSequence, LineItemSequence, s.OrderedItem, 
       s.CatalogYear, ItemPrefix, ShipDelDate, Sum(Qty) AS RetQty, Sum(ShipQty) AS ShipQty, Sum(RetDollars) 
       AS RetDollars, Sum(ShipDollars) AS ShipDollars
INTO #ptCombined
FROM #ptShpSummary s LEFT JOIN #ptAdj a 
	ON a.AccountNumber = s.AccountNumber AND a.OrderNumber = s.OrderNumber AND 
   a.OriginalAddressSequence = s.AddressSequence AND a.OriginalLineitemSequence = s.LineitemSequence AND 
   a.OriginalShipItemSequence = s.ShipItemSequence
GROUP BY s.CompanyCode, s.AccountNumber, s.OrderNumber, s.AddressSequence, s.ShipItemSequence, LineItemSequence, s.OrderedItem, 
          s.CatalogYear, ItemPrefix, ShipDelDate

IF EXISTS (SELECT * FROM tempdb..sysobjects
WHERE id = object_id(N'tempdb.dbo.#ptItem'))
DROP TABLE #ptItem

Select ItemNumber, PrimaryCatalogCode, Season, Description, i.SfCategory, c.SfDescription, i.RDCategory, r.RdDescription
into #ptItem
from MDW1.dbo.Item i
Left Join MDW2.dbo.RdCategory r On i.RDCategory = r.RdCategory 
Left Join MDW2.dbo.SfCode c 
	ON i.RdCategory = c.RDMasterCode and i.SfCategory = c.SFMasterCode
Where Season >= Left(@BeginDate,4) -2 

Create Clustered Index IDC_Item on #ptItem (Season, PrimaryCatalogCode, ItemNumber) 

IF EXISTS (SELECT * FROM tempdb..sysobjects
WHERE id = object_id(N'tempdb.dbo.#ptReturns'))
DROP TABLE #ptReturns

SELECT s.CompanyCode, s.AccountNumber, s.OrderNumber, s.AddressSequence, s.ShipItemSequence, LineItemSequence, 
       s.OrderedItem, Description, i.RDCategory, RdDescription, SFCAtegory, SfDescription, s.CatalogYear, s.ItemPrefix, 
        ShipDelDate, IsNull(RetQty, 0) AS RetQty, ShipQty, IsNull(RetDollars, 0) AS RetDollars, ShipDollars
INTO #ptReturns
FROM #ptCombined s LEFT JOIN #ptItem i 
	ON s.CatalogYear = i.Season AND s.ItemPrefix = i.PrimaryCatalogCode AND 
       s.OrderedItem = i.ItemNumber 
	
	--Removed below to help speed up report 4/13/16
	--Create Clustered Index IDX_Ret on #ptReturns (AccountNumber, OrderNumber)
	
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id = object_id(N'tempdb.dbo.#ptBySeason')) 
DROP TABLE #ptBySeason

SELECT a.CompanyCode, c.CompanyDescription as Company, 
       	    Cast(DatePart(yyyy,ShipDelDate) as varchar(4)) AS Season, OrderedItem, Description, RDCategory AS RD, RdDescription, SFCategory AS SFC,
		    SfDescription, RetQty, ShipQty, RetDollars, ShipDollars
INTO #ptBySeason
FROM #ptReturns a join MDW1.dbo.Company c on a.CompanyCode = c.Company
WHERE a.CompanyCode  IN ('7', 'W', 'C', 'M', 'G', 'L', 'Q')

--Removed below to help speed up report 4/13/16
--Create Clustered Index IDX_All on #ptBySeason(OrderedItem, Company, Season)

SELECT OrderedItem, Description, CompanyCode, Company, Season, RD, RdDescription, SFC,		
	   SfDescription, Sum(RetQty) AS RetQty, Sum(ShipQty) AS ShipQty, 
       Sum(RetDollars) AS RetDollars, Sum(ShipDollars) AS ShipDollars
FROM #ptBySeason
GROUP BY OrderedItem, Description, CompanyCode, Company, Season, RD, RdDescription, SFC, SfDescription


END
