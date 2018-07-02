SELECT DISTINCT 
                         m.PONumber, m.Vendor, r.DetItemNumber, m.DMRNum, m.QtyOnHold, m.Category, m.Exclude, f.BuyerCode, LEFT(f.VendorNum, 5) AS vendorNum
FROM            [Kimball\ODS2].PPQAD_QASpecFood.dbo.tbl_DMRMain AS m LEFT OUTER JOIN
                        [Kimball\ODS2].PPQAD_QASpecFood.dbo.tbl_DMRDetail AS r ON m.id = r.DetDMRMainId LEFT OUTER JOIN
                         [Kimball\ODS2].PPQAD_QASpecFood.dbo.tbl_BOSDMR AS b ON m.id = b.DMRMainID LEFT OUTER JOIN
                         [Kimball\ODS2].PPQAD_QASpecFood.dbo.tbl_BOSProcessCategory AS p ON b.BOSProcCategID = p.id LEFT JOIN
                         PIC430 AS f ON m.PONumber = RTRIM(LTRIM(LEFT(f.POLnRel, CHARINDEX(' ', f.POLnRel)))) and r.DetItemNumber = f.Sku LEFT OUTER JOIN
                         BuyerCodes AS bc ON f.BuyerCode = bc.BuyerCode LEFT OUTER JOIN
                         BuyerContacts AS c ON bc.BuyerContactID = c.BuyerContactID
WHERE        --(LEFT(f.VendorNum, 5) = '58920') AND 
(YEAR(m.DMRInitDT) = 2014) AND (m.Exclude IS NULL) AND 
                         (p.ProcessCategory LIKE 'MSP-09%') AND (f.Year = 2014)