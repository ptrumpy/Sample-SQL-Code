USE [SupplyChain_Misc]
GO
/****** Object:  StoredProcedure [dbo].[DensityCompanyPrefix]    Script Date: 7/3/2018 9:48:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Phil Trumpy>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[DensityCompanyPrefix] 
	-- Add the parameters for the stored procedure here
	 @ReportType varchar,
	 @Season char(3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

If @ReportType = '1'
Begin
select rtrim(PicsCompany) as Value,CompanyDescription as Description
from mdw1.dbo.Company
WHERE PIcsCompany NOT IN ('HC', 'DC', 'HO', 'SP', 'FB', 'GP', 'RC', 'DL', 'SF', 'RT', 'CK', 'HV', 'LB')
ORDER BY CompanyDescription
End
If @ReportType = '2'
Begin 
SELECT Catalog AS Value, Catalog + '-' + Description as Description
FROM MDW1.dbo.CatalogCodes
WHERE rtrim(Season) = @Season and Catalog > '12'
End
END

