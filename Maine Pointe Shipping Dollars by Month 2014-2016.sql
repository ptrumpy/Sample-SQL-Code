select Left(ShipDelDate,4) as Year, substring(ShipDelDate,5,2) as Month, HomeBuilding, i.RdCategory, r.RDDescription, i.SfCategory, sf.SfDescription,Sum(ShippedQty) as ShipUnits, Sum(ShippedQty*UnitPRice) as ShiDollars
from ShipItemAll s left join ITem i on s.OrderedITem = i.ItemNumber and s.ItemPrefix = i.PrimaryCatalogCode and s.Season = i.Season left join MDW2.dbo.FulfillmentCode2 f on s.FulfillmentCode = f.FulfillmentCode
left join MDW2.dbo.RdCategory r on i.RdCategory = r.RdCategory 
left join MDW2.dbo.SfCode sf on i.RdCategory = sf.RDMasterCode and i.SfCategory = sf.SFMasterCode
where Left(ShipDelDate,4) > 2013 and StatusCode in ('S','P') and ShipDelDate > 0
group by Left(ShipDelDate,4), substring(ShipDelDate,5,2), HomeBuilding, i.RdCategory, r.RDDescription, i.SfCategory, sf.SfDescription