define date0=201609010000
define hlen=2000
define flen=2
select * from (select newdatetime,high from history.eurusd_d1 where newdatetime<=to_date('&&date0','YYYYMMDDHH24MI') order by 1 desc) where rownum<=&&hlen
union
select * from (select newdatetime,high from history.eurusd_d1 where newdatetime>to_date('&&date0','YYYYMMDDHH24MI') order by 1) where rownum<=&&flen order by 1 desc
/
