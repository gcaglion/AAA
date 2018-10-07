drop type RecordCount_tab;
drop type RecordCount_obj;
create type RecordCount_obj is object(TableName varchar2(64), Symbol varchar2(12), TimeFrame varchar2(3), Filled varchar2(6), TotalCount number, minDate date, maxDate date);
/
show errors;
create type RecordCount_tab is table of RecordCount_obj;
/
show errors;


create or replace function RecordCount return RecordCount_tab is
	l_RecordCount_tab RecordCount_tab := RecordCount_tab();
	tName varchar2(128); vMinDate date; vMaxDate date; vCount number; vFilled boolean;
	n integer :=0;
BEGIN
	for r in (select table_name,
				substr(table_name,1,instr(table_name,'_')-1) BaseTable,
				decode(substr(table_name,length(table_name)-5,6),'FILLED','FILLED','BASE') TableType,
				decode(substr(table_name,length(table_name)-5,6),'FILLED',
				decode(substr(table_name,length(table_name)-5,6),'FILLED',
					substr(table_name, instr(table_name,'_')+1, instr(table_name,'_',-1)-instr(table_name,'_')-1)),
					substr(table_name,instr(table_name,'_',-1)+1,length(table_name)-instr(table_name,'_',-1))
					) TimeFrame
				from user_tables order by 1
			) loop
		dbms_output.put_line('select count(*), min(NewDateTime), max(NewDateTime) from '||r.table_name);
		execute immediate 'select count(*), min(NewDateTime), max(NewDateTime) from '||r.table_name into vCount, vMinDate, vMaxDate;
		l_RecordCount_tab.extend;
		n:=n+1;
		dbms_output.put_line('r.BaseTable=***'||r.BaseTable||'***');
		dbms_output.put_line('r.TimeFrame=***'||r.TimeFrame||'***');
		l_RecordCount_tab(n) := RecordCount_obj(r.table_name, r.BaseTable, r.TimeFrame, r.TableType, vCount, vMinDate, vMaxDate);
		dbms_output.put_line('select count(*), min(NewDateTime), max(NewDateTime) from '||r.table_name);
/*
		execute immediate 'select count(*), min(NewDateTime), max(NewDateTime) from '||r.table_name||'_FILLED' into vCount, vMinDate, vMaxDate;
		l_RecordCount_tab.extend;
		n:=n+1;
		l_RecordCount_tab(n) := RecordCount_obj(r.BaseTable, r.TimeFrame, 'FILLED', vCount, vMinDate, vMaxDate);
*/
	end loop;
	
	return l_RecordCount_tab;
END;
/
show errors;
