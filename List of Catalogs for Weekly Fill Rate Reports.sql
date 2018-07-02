select * --distinct catalog 
from catalogcodes where Season = 'S16' and datediff(d,activedate,getdate())>14 and companycode in('7', 'C', 'G', 'L', 'M', 'Q', 'W', 'S', 'T', 'F', 'J' , 'O') and (typeflag ='C' or typeflag = 'I'
and description LIKE '%INTERNET' or description like '%INTERNET WEB SITE')
