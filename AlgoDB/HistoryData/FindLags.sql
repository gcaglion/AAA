create or replace procedure FindLags(pSymbol varchar2, pTimeFrame varchar2, pThreshold number) as
	type rc is ref cursor;
	c1 rc; 
	tname varchar2(30);
	TFMins number;
	vMissing number;
	pNewDateTime date; pOpen number; pHigh number; pLow number; pClose number; pVolume number;
	vNewDateTime date; vOpen number; vHigh number; vLow number; vClose number; vVolume number;
	oNewDateTime date; oOpen number; oHigh number; oLow number; oClose number; oVolume number;

function IsMarketOpen(pSymbol varchar2, pNewDateTime date) return boolean is
	dow number;	-- Day of Week
	hod number;	-- Hour of the day
BEGIN

	select to_number(to_char(pNewDateTime,'D'),'9') into dow from dual;
	select to_number(to_char(pNewDateTime,'HH24'),'99') into hod from dual;
	if dow=1 then	-- Rough cut: if it's Sunday, everything's fine ...
		return false;
	else
		return true;
	end if;
/*
	if 	  (dow=6) then	--Friday. Closed after 17:00
		if (hod>=17) then
			return false;
		else
			return true;
		end if;
	elsif (dow=7) then	--Saturday. Closed any time
		return false;
	elsif (dow=1) then	--Sunday. Closed until 17:00
		if (hod>=17) then
			return true;
		else
			return false;
		end if;
	else
		return true;
	end if;
*/

END IsMarketOpen;

BEGIN
	tname:=pSymbol||'_'||pTimeFrame;
	if 		pTimeFrame='M1' then TFMins:=1;
	elsif	pTimeFrame='M5' then TFMins:=5;
	elsif	pTimeFrame='M15' then TFMins:=15;
	elsif	pTimeFrame='H1' then TFMins:=60;
	elsif	pTimeFrame='H4' then TFMins:=240;
	elsif	pTimeFrame='D1' then TFMins:=1440;
	else
		return;
	end if;
	
	open c1 for
	'select NewDateTime, Open, High, Low, Close, Volume from '||tname||' order by NewDateTime';
	loop
		pNewDateTime:=vNewDateTime; pOpen:=vOpen; pHigh:=vHigh; pLow:=vLow; pClose:=vClose; pVolume:=vVolume;
		fetch c1 into vNewDateTime, vOpen, vHigh, vLow, vClose, vVolume;
		exit when c1%NOTFOUND;
		if ( (pNewDateTime is not NULL) and IsMarketOpen(pSymbol, vNewDateTime) and ((vNewdateTime-pNewDateTime)>(TFmins/1440)) ) then
			vMissing:=trunc( (vNewdateTime-pNewDateTime)*1440/TFMins ) -1;
			if vMissing>pThreshold then 
				dbms_output.put_line('Gap between '||pNewDateTime||' and '||vNewDateTime||' . '||vMissing||' bars missing.');
			end if;
		end if;
	end loop;
END;
/
show errors
