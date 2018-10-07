create user &&1 identified by LogPwd default tablespace LogData;
grant AlgoDBA to &&1;
alter user &&1 quota unlimited on LogData;
alter user &&1 quota unlimited on LogIdx;

select * from dba_role_privs where granted_role in ('DBA','ALGODBA') order by granted_role, grantee;