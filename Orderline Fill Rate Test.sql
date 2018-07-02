    -- Insert statements for procedure here
	If exists
(select * from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#pwtadcode'))
       drop table #pwtadcode

select Season, Catalog, CompanyCode, count(*) as count
into #pwtadcode
from mdw1.dbo.AdCode
where season > '2013' and companycode > ' '
group by Season,Catalog,CompanyCode

create clustered index ipx_id1 on #pwtadcode (season,catalog,companycode)

--Create allocated catalog code version.

If exists
(select * from tempdb..sysobjects where id = object_id(N'tempdb.dbo.#pwtfillrate1'))
       drop table #pwtfillrate1  

select t1.accountnumber,t1.ordernumber,t2.LineitemSequence
       ,case when t4.CompanyCode > ' ' then t4.companycode 
             when t1.companycode > ' ' then t1.companycode
             else 'x' end as companycode
       ,t2.AllocatedCatalog
       ,case when  t2.AllocatedSeason > '    ' then t2.AllocatedSeason 
                else  t1.advcodeyear end as AllocatedSeason
       ,t2.ItemNumber, t3.Description, t2.ConversionItemNumber,t1.foedate
       ,case when t2.unitprice > 0 then t2.unitprice else t3.retailprice1 end as retailprice1
       ,t2.ShippedFlag,t2.addresssequence,t2.backorderedflag,t2.itemqty,t2.ShipWhen
       ,t2.NotAvailableFlag
          ,isnull(count(case when t2.statuscode = 'd' then 1 end),0) as deleteDcnt
       ,isnull(count(case when t2.statuscode = 'c' then 1 end),0) as deleteCcnt
       ,isnull(count(case when t2.statuscode in ('p','s') then 1 end),0) as shipcnt
          ,datepart(ww, t1.foedate) as week, datepart(yy, t1.foedate) as year
		  ,datepart(mm, t1.foedate) as month
		  ,datepart(dd, t1.foedate) as day
          ,DATEADD(dd, -10, getDate()) AS cutoffdate--,
          --DATEADD(wk,DATEDIFF(wk,0, t1.foedate), 6) AS weekdate
		  ,t2.CatalogYear, t2.CatalogCodePrefix
       into #pwtfillrate1  
from (((mdw1.dbo.CurrentOrdersAll t1 left join mdw1.dbo.CurrentOrderlineAllocateAll t2
             on t1.accountnumber = t2.accountnumber and
                   t1.ordernumber = t2.ordernumber) 
        left join mdw1.dbo.Item t3
             on t2.itemnumber = t3.itemnumber and
                   t2.AllocatedCatalog = t3.PrimaryCatalogCode and
                   (case when t2.allocatedseason > '    ' then t2.allocatedseason else t2.Season end)  = t3.season)
         left join #pwtadcode t4
                           on (case when t2.CatalogYear > '    ' 
                        then t2.catalogyear else t1.advcodeyear end = t4.season and
                             t2.CatalogCodePrefix = t4.catalog))
       
where  t1.orderstatus = 'f'  and t1.foedate > convert(char(8),dateadd(year,-3,getdate()),112) and
       (case when  t2.AllocatedSeason > '    ' then t2.AllocatedSeason 
                else  t1.advcodeyear end) > substring(convert(char(8),dateadd(yy,-4,getdate()),112),1,4)
        and t2.AllocatedCatalog > '   '
        and t2.ZSubCode not in ('a','b') and t2.itemerrorflag = ' ' and t2.AvailabilityFlag in (' ','1')
              and t1.foedate <= DATEADD(dd, -10, getDate()) and t1.FoeDate > '20141231'
group by t1.accountnumber,t1.ordernumber,t2.LineitemSequence
       ,case when t4.CompanyCode > ' ' then t4.companycode 
             when t1.companycode > ' ' then t1.companycode
             else 'x' end  
       ,t2.AllocatedCatalog
       ,case when  t2.AllocatedSeason > '    ' then t2.AllocatedSeason 
                else  t1.advcodeyear end  
       ,t2.ItemNumber, t3.Description, t2.ConversionItemNumber,t1.foedate
       ,case when t2.unitprice > 0 then t2.unitprice else t3.retailprice1 end  
       ,t2.ShippedFlag,t2.addresssequence,t2.backorderedflag,t2.itemqty,t2.ShipWhen
       ,t2.NotAvailableFlag, t1.foedate, t2.CatalogYear,  t2.CatalogCodePrefix

create clustered index idx_fill1 on #pwtfillrate1
(accountnumber,ordernumber,LineitemSequence,addresssequence)




select fc.WeekEndDate, fc.CalendarSeq, t4.companygroupdesc,t4.companydescription
       ,case when left(t1.ItemNumber,2)='00' then '6'+right(t1.ItemNumber,5) else '6'+right(t1.ItemNumber,6) end as ItemNumber, t1.Description
       ,case when left(t1.ConversionItemNumber,2)='00' then '6'+right(t1.ConversionItemNumber,5) else '6'+right(t1.ConversionItemNumber,6) end as ConversionItemNumber
         ,r.Division, r.rdcategory, r.description as rddescription, right(s.sfccategory,2) as sfcategory, s.description as sfdescription
                        ,concat(i.rdcategory, i.sfcategory) as RdSfCategory,
						t2.merchandisercode,t2.buyercode,t2.CombinableCode,
						t1.AllocatedCatalog
       ,isnull(sum(case when (ShippedFlag = '1' or shipcnt > 0) and 
                              deleteDcnt = 0 and deleteCcnt = 0 and notavailableflag = '0' and 
                              addresssequence > '000' then itemqty end),0) as unitsshipped
       ,isnull(sum(case when shipwhen not in ('n',' ') and (shippedflag = '1' or shipcnt > 0) then itemqty
                    when shipwhen not in ('n',' ') and (deleteDcnt > 0 or deleteCcnt > 0) then itemqty
                    when shipwhen not in ('n',' ') and NotAvailableFlag = '1' then itemqty
                    when shipwhen not in ('n',' ') and backorderedflag = '1' then itemqty
            when shipwhen not in ('n',' ') and (shippedflag = '0' and shipcnt = 0) then 0 
            when shipwhen not in ('n',' ') and (deleteDcnt = 0 and deleteCcnt = 0) then 0
            when shipwhen not in ('n',' ') and NotAvailableFlag = '0' then 0
            when shipwhen not in ('n',' ') and backorderedflag = '0' then 0
            else itemqty end),0) as unitsdemanded, t1.retailprice1 as retail
       ,isnull(sum(case when BackorderedFlag = '1' and shippedflag = '0' and shipcnt = 0 and
                             notavailableflag = '0' and deleteDcnt = 0 and deleteCcnt = 0
                        then itemqty end),0) as unitsbackordercurrent
       ,isnull(sum(case when addresssequence = '000' then itemqty end),0) as unitslost
       ,isnull(sum(case when backorderedflag = '1' or deleteDcnt > 0 or deleteCcnt > 0 or notavailableflag = '1' or
                             (shippedflag = '0' and shipcnt = 0 and addresssequence > '000' and 
                              shipwhen in ('n',' ')) then itemqty end),0) as unitsnotship, t1.week, t1.year, t1.month, t1.day, t1.allocatedseason, t1.CatalogYear, t1.CatalogCodePrefix, e.season--, t1.weekdate
from #pwtfillrate1 t1 Join ODW1.dbo.FiscalCalendar fc on convert( date,t1.FoeDate) between fc.WeekBeginDate and fc.WeekEndDate
          left join tempwork.dbo.eabItem2 t2
                           on t1.itemnumber = t2.itemnumber
			left join mdw1.dbo.Item i ON i.ItemNumber = t1.itemNumber AND i.Season = t1.CatalogYear and i.PrimaryCatalogCode = t1.CatalogCodePrefix
			left join SupplyChain_Misc.dbo.RdCategory r ON r.RdCategory = i.RdCategory
			left join SupplyChain_Misc.dbo.SfcCategory s ON s.SfcCategory = concat(i.rdcategory, i.sfcategory)
             left join mdw1.dbo.company t4
                       on t1.companycode = t4.company
                     left join mdw1.dbo.CatalogCodes e on t1.allocatedCatalog = e.catalog and t1.allocatedSeason = e.mailYear
where i.rdcategory is not null and t4.companygroup = 'n'
group by fc.WeekEndDate, fc.CalendarSeq,t4.companygroupdesc,t4.companydescription
        ,case when left(t1.ItemNumber,2)='00' then '6'+right(t1.ItemNumber,5) else '6'+right(t1.ItemNumber,6) end, t1.Description  
        ,case when left(t1.ConversionItemNumber,2)='00' then '6'+right(t1.ConversionItemNumber,5) else '6'+right(t1.ConversionItemNumber,6) end  
             ,r.division, r.rdcategory,r.description,s.sfccategory,s.description
        ,concat(i.rdcategory, i.sfcategory),t2.merchandisercode,t2.buyercode,t2.CombinableCode,t1.AllocatedCatalog, t1.retailprice1, t1.week, t1.year, t1.month, t1.day, t1.allocatedseason, t1.CatalogYear, t1.CatalogCodePrefix, e.season--, t1.weekdate



	