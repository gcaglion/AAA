create or replace function MyWeekNo(pDate date) return number deterministic is
	dCorr number;
BEGIN
	if pDate>=to_date('291220130000','DDMMYYYYHH24MI') and pDate<=to_date('311220132359','DDMMYYYYHH24MI') then
		return 13.53;
	elsif pDate>=to_date('010120140000','DDMMYYYYHH24MI') and pDate<=to_date('040120142359','DDMMYYYYHH24MI') then
		return 14.01;
	else
		--if
		--dCorr:=
		return to_number(to_char(pDate+1,'YY')||'.'||to_char(pDate+1,'IW'),'99.90');
		--return to_char(pDate,'YY')||'.'||to_char((1+trunc(pDate)-trunc(pDate,'IW'),'99.90')/100);
		--return (1+trunc(pDate)-trunc(pDate,'IW'));
	end if;
END;
/
show errors;
