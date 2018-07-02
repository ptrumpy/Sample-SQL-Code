SELECT Recordtype + 
              RIght('00000' + Rtrim(cast(Sequence AS CHAR(6))), 6) +
              CompanyID + 
              DivisionID + 
              OfferID + 
              cast(OfferYear AS CHAR(4)) + 
              ProductID + 
              Descriptor1 + 
              Descriptor2 + 
              Descriptor3 + 
              SKU + 
              Right('000000000' + rtrim(Cast(cast(Revenue*100  as INT) as char(10))) , 10) + 
              Right('0000000' + rtrim(cast(Units AS CHAR(8))), 8)
FROM FCSTInterface


select count(distinct productID) from FCSTInterface where offeryear = 2012 and offerid='WNF'