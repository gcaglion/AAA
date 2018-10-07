col tablespace_name format a30
col file_name format a50
select df.tablespace_name, df.file_name, df.bytes/1024/1024 tot_mb, max(fs.bytes/1024/1024) max_free_mb
from dba_data_files df, dba_free_space fs where df.file_id=df.file_id
and df.tablespace_name like 'LOG%'
group by df.tablespace_name, df.file_name, df.bytes/1024/1024
order by 1,2;
