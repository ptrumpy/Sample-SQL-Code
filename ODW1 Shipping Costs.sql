Drop table ##ptQUERY_FOR_LABELHEADER
   SELECT /* PkgID */
            ('00'+t1.UniqueNo) AS PkgID, t1.orderNumber, ItemNo,
          t1.ShipDate, 
          /* ITEM_Quantity */
            (SUM(t2.Quantity))  AS ITEM_Quantity
			into ##ptQUERY_FOR_LABELHEADER
      FROM ODW1.dbo.LabelHeader t1 INNER JOIN ODW1.dbo.LabelDetail t2 ON (t1.UniqueNo = t2.UniqueNo)
      WHERE t1.ShipDate BETWEEN '20130101' AND '20131231'
      GROUP BY ('00'+t1.UniqueNo), t1.orderNumber, ItemNo,t1.ShipDate;

	  drop table ##ptShippingCosts
   SELECT t1.PkgID, t1.OrderNumber, ItemNo,
          t1.ShipDate, 
          t1.ITEM_Quantity, 
          t2.BilledWeight, 
          t2.TotalCharge
		  into ##ptShippingCosts
      FROM ##ptQUERY_FOR_LABELHEADER t1 INNER JOIN ODW1.dbo.FlagShipShipments t2 ON (t1.PkgID = t2.PackageID);

	  select * from ##ptShippingCosts
	  order by Ordernumber
