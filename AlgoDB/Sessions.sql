col program format a25
col machine format a30
col username format a12
select sid,serial#,username,program,machine,command,sql_id, prev_sql_id from v$session where username is not null order by username,machine,program;
