col object_name format A25
col program format A15
col wait_class format A15
select sid, serial#, command, sql_id, program, wait_class, row_wait_obj#, object_name, row_wait_block#, wait_time from v$session,dba_objects where v$session.row_wait_obj#=dba_objects.object_id and username='LOGUSER'
/
col sql_address format a20
col message format a90
col target format a40
set linesize 2000
col sid format 999
col username format A10
col opname format A30
col target_desc format A20
select * from v$session_longops where sid in (select sid from v$session where username='LOGUSER') order by elapsed_seconds;