explain plan for delete from MYLOG_MSE where processid in(select processid from(select processid, datasetid, count(threadid) from enginethreads having(count(threadid)<100) group by processid, datasetid));
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY(NULL));

-- this runs EXPLAIN PLAN for a running statement:
select plan_table_output from v$sql s, table(dbms_xplan.display_cursor(s.sql_id, s.child_number, 'basic')) t where s.sql_id='1bugu0axu7j32'
