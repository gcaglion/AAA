create or replace view EURUSD_M1_holes as 
select newdatetime, (NEWDATETIME-LAG(NEWDATETIME) OVER(ORDER BY NEWDATETIME))*24*60 width
from EURUSD_m1 order by 1
/
select newdatetime, width from EURUSD_m1_holes where width>1
and newdatetime not in (
			select newdatetime from EURUSD_m1_holes 
			where width>1 
			and (1+trunc(newdatetime)-trunc(newdatetime,'IW'))=7
			and to_char(newdatetime,'HH24')='17'
			)
/

create or replace view EURUSD_H1_holes as 
select newdatetime, (NEWDATETIME-LAG(NEWDATETIME) OVER(ORDER BY NEWDATETIME))*24 width
from EURUSD_h1 order by 1
/
select newdatetime, width from EURUSD_h1_holes where width>1
and newdatetime not in (
			select newdatetime from EURUSD_h1_holes 
			where width>1 
			and (1+trunc(newdatetime)-trunc(newdatetime,'IW'))=7
			and to_char(newdatetime,'HH24')='17'
			)
/
