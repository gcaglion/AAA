select
k.newdatetime,
nvl(a.open,-1), nvl(af.open,-1), af.isfilled,
nvl(b.open,-1), nvl(bf.open,-1), bf.isfilled,
nvl(c.open,-1), nvl(cf.open,-1), cf.isfilled
from kaz_h1 k,
eurusd_h1 a, eurusd_h1_filled af, 
spx_h1 b, spx_h1_filled bf, 
etxeur_h1 c, etxeur_h1_filled cf
where
k.newdatetime=a.newdatetime(+) and
k.newdatetime=b.newdatetime(+) and
k.newdatetime=c.newdatetime(+) and
k.newdatetime=af.newdatetime(+) and
k.newdatetime=bf.newdatetime(+) and
k.newdatetime=cf.newdatetime(+) and
k.newdatetime between to_date('201808010000','YYYYMMDDHH24MI') and to_date('201809010000','YYYYMMDDHH24MI')
order by 1;
