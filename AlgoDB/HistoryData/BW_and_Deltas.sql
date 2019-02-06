select count(newdatetime), avg(high-low)*10000 bw, avg(abs(dh))*10000, avg(abs(dl))*10000 from(
select newdatetime, 
high, high-lag(high) over (order by newdatetime) dh,
low, low-lag(low)  over (order by newdatetime) dl
from eurusd_h1 where to_char(newdatetime,'YYYYMM')='201807'
);
