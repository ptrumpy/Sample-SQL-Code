select distinct colorname, Case when isnumeric(left(colorname,1)) = 1 then colorname 
								when patindex('%[0-9]%',substring(colorname,charindex(' ',colorname),len(colorname)-charindex(' ',colorname)))>0 then left(colorname,nullif(charindex(' ',colorname),0)-1) 
								else colorname End as ShortName  from tbl_colorway order by colorname


