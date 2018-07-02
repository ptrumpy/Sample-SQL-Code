select Season, ItemNumber, PrimaryCatalogcode, SFCategory, RDCategory, Description, DiscountReasonCode
from ItemAll
Where Season in ('2010', '2011', '2012', '2013') and PrimaryCatalogcode in ('ND', 'NA', 'NK') and itemnumber = '0043493'

Order by season, primarycatalogcode, itemnumber