SELECT Chargeback.Buyer, supplychain_Misc.dbo.BuyerContacts.ChargebackName as BuyerName, Chargeback.Comp, Chargeback.VendorName, Chargeback.VendorNum, Chargeback.SCNum, 
Chargeback.Description, Chargeback.Cost, Chargeback.QtyRecd, Chargeback.DaysLate, Chargeback.DefaultPctCharged, 
Chargeback.DefaultAmtCharged, Chargeback.ActualAmtCharged, Chargeback.ChargeFlag, Chargeback.DateExpected, Chargeback.DateRecd, ReasonCode, Comments
FROM (Chargeback INNER JOIN supplychain_Misc.dbo.BuyerCodes ON Chargeback.Buyer = supplychain_Misc.dbo.BuyerCodes.BuyerCode) INNER JOIN supplychain_Misc.dbo.BuyerContacts ON supplychain_Misc.dbo.BuyerCodes.BuyerContactID = supplychain_Misc.dbo.BuyerContacts.BuyerContactID
where chargeback.buyer in('FN','FI') AND left(chargeback.daterecd,4) = '2017'
order by daterecd
