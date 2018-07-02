select left (p.rcptDate, 6) as MonthYear, POLnRel, DockDate as InHouseDate, RcptDate, p.BuyerCode,sum (p.QtyRcvd) as UnitsRcvd, sum (p.UnitCost * p.QtyRcvd) as DollarsRcvd
From pic430 p 
      left join BuyerCodes b on p.buyercode = b.buyercode
Where p.Year in ('2016') and b.Division = 'N' and left(p.rcptDate,6) = '201602'
group by left (p.rcptDate, 6), POLnRel, DockDate, RcptDate, p.BuyerCode
order by left (p.rcptDate, 6)



