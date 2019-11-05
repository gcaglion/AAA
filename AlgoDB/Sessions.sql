col program format a25
col machine format a30
col username format a12
col sql_text format a100
select s.sid,s.serial#,s.username,s.program,s.process,s.machine,s.status,s.command,s.sql_id, s.prev_sql_id ,
q.sql_text
from v$session s, v$sql q
where 
s.sql_id=q.sql_id and
s.username is not null 
order by s.username,s.machine,s.program;
