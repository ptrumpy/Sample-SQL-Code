SELECT itemnumber, companycode, Sum(ActQty) as ActQty, Sum(ActSales) as ActSales--, , a.vendor_name, a.contact, a.address1, a.city, a.address2, a.address3, a.state, a.postal_code, a.country, a.telephone, a.fax, a.created_datetime, a.extension, a.last_updated_datetime, a.terms_code, a.last_updated_by, a.terms, a.vendor_email, a.vendor_password, a.fob, a.ship_via_code, a.order_process_lead_time, a.transit_lead_time, a.receiving_lead_time, a.total_lead_time, a.po_cost_fixed, a.po_cost_line_item, a.freight_cost_per_item_pct, a.freight_cost_per_item_ea, a.freight_pay_method, a.order_review_cycle, a.separate_product_po_flag, a.needs_spo_recalc, a.purchase_discount, a.ad_allowance
   FROM ( SELECT itemnumber, companycode, primarycatalogcode, season, ActQty, ActSales, row_number()
          OVER( 
          PARTITION BY itemnumber, primaryCatalogCode, season
          ORDER BY i.recorddate DESC) AS r
           FROM mdw1.dbo.ItemDaily i join Merch2.dbo.F21OfferDaily f on i.PrimaryCatalogcode = f.offer_Id and i.season = f.offer_Year
	  where cast(left(i.recorddate,11) as datetime) <= '2016-09-20' and f.Season_id = (Case When Month('2016-09-20') between 7 and 12 then 'F' Else 'S' End + Right(Year('2016-09-20'),2)) 
	   and f.Media_ID = 'UPS' and i.UpsellType in ('A','E','P') and (CompanyCode in('S','T','F') or RdCategory < 50)
	  ) a
  WHERE a.r =2
  group by itemnumber, companycode