col file_name format a50
col tablespace_name format a30
select tablespace_name, file_name, bytes/1024/1024 mb from dba_data_files order by 1,2;
