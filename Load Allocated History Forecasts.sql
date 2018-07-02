--Get Demand by AllocatedSeason, AllocatedCatalog
drop table ##ptAllocatedDemand
Select LTrim(RTrim(Case when ItemNumber < 100000 then ITemNumber + 600000 else ItemNumber + 6000000 end)) as ItemNumber, Cast(case when [ConversionItemNumber] < 100000 then ConversionItemNumber + 600000 else ConversionITemNumber + 6000000 end as varchar(7)) as ConverstionITemNumber, sum(ItemQty) as Qty, sum((ItemQty * UnitPrice)) as Revenue, 
allocatedCatalog, AllocatedSeason
into ##ptAllocatedDemand 
From[dbo].[OrderLineAllAllocate]
Where allocatedCatalog in ('MR') and AllocatedSeason = '2014' 
and RuleUsed in ('01', '02', '03') and OrderStatus = 'F' and ZSubCode not in ('a','b') 
and itemerrorflag = ' ' and AvailabilityFlag in (' ','1')
Group By LTrim(RTrim(Case when ItemNumber < 100000 then ITemNumber + 600000 else ItemNumber + 6000000 end)), ConversionItemNumber, AllocatedCatalog, AllocatedSeason
--Order by ItemNumber, ConversionItemNumber

--Following not working.  Presume because of linked server
--Insert into [johnson\dept_app_prod].NFIM.dbo.FCSTInterface (RecordType, CompanyID, DivisionID, OfferID, OfferYear, ProductID, Descriptor1, Descriptor2, Descriptor3, Sku, Revenue, Units)

--Check for duplicate SKU records
Select  Sku, Offer_ID, Count(*) from (Select 'FCST' as recordtype, 'NF' as Company_ID, 'NF' as Division_ID, RTrim(AllocatedCatalog) +'F' as Offer_ID, AllocatedSeason, a.ItemNumber, i.NewDescriptor1, i.NewDescriptor2, i.NewDescriptor3, i.Sku, Min(0) as Revenue, Sum(a.Qty) as Qty from ##ptAllocatedDemand a left join ##ptCorrectSKUs i on a.ItemNumber = i.Pack and a.ConverstionItemNumber = i.Ship
where i.Pack is not null
group by  RTrim(AllocatedCatalog) +'F' , AllocatedSeason, a.ItemNumber, i.NewDescriptor1, i.NewDescriptor2, i.NewDescriptor3, i.Sku) b
group by  Sku, Offer_ID
Having Count(*) > 1

--Get data to load to [johnson\dept_app_prod].NFIM.dbo.FCSTInterface
Select 'FCST' as recordtype, 'NF' as Company_ID, 'NF' as Division_ID, RTrim(AllocatedCatalog) +'F' as Offer_ID, AllocatedSeason, a.ItemNumber, i.NewDescriptor1, i.NewDescriptor2, i.NewDescriptor3, i.Sku, Min(0) as Revenue, Sum(a.Qty) as Qty from ##ptAllocatedDemand a left join ##ptCorrectSKUs i on a.ItemNumber = i.Pack and a.ConverstionItemNumber = i.Ship
where i.Pack is not null
group by  RTrim(AllocatedCatalog) +'F' , AllocatedSeason, a.ItemNumber, i.NewDescriptor1, i.NewDescriptor2, i.NewDescriptor3, i.Sku



