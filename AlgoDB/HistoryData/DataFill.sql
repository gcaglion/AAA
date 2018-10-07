create or replace procedure DataFill (OrigTName varchar2, OrigTF varchar2) as
	i number;
	TFm number;
	vGap number;
	vNewDateTime date; vOpen number; vHigh number; vLow number; vClose number; vVolume number;
	pNewDateTime date; pOpen number; pHigh number; pLow number; pClose number; pVolume number;
	oNewDateTime date; oOpen number; oHigh number; oLow number; oClose number; oVolume number; oisFilled number;
	vEarliestBar date; vLatestBar date;
	type rc is ref cursor;
	cOrig rc; cDest rc;
	FUNCTION IsMarketOpen(pTime date) return boolean as
	BEGIN
		if 		to_char(pTime,'D')=1 then	-- Sunday
			return ((trunc(pTime,'HH24')-trunc(pTime,'DD'))>=17/24);
		elsif to_char(pTime,'D')=6 then	-- Friday
			return ((trunc(pTime,'HH24')-trunc(pTime,'DD'))<17/24);
		elsif to_char(pTime,'D')=7 then	-- Saturday
			return false;
		else							-- Tuesday to Thursday
			return true;
		end if;
	END IsMarketOpen;

BEGIN
	case OrigTF
		when 'M1' then TFm:= 1440;
		when 'M5' then TFm:=  288;
		when 'M15' then TFm:=  96;
		when 'M30' then TFm:=  48;
		when 'H1' then TFm:=   24;
		when 'H4' then TFm:=    6;
		when 'D' then TFm:=     1;
		when 'W' then TFm:=     1/7;
	end case;

	open cOrig for
	'select NewDateTime, Open, High, Low, Close, Volume from '||OrigTname||'_'||OrigTF||' order by NewDateTime';
	
	--Find the latest record in FILLED table
	execute immediate 'select min(NewDateTime), max(NewDateTime) from '||OrigTname||'_'||OrigTF||'_FILLED' into vEarliestBar, vLatestBar;
	if vLatestBar is NULL then vLatestBar:=to_date('01/01/1900','DD/MM/YYYY'); end if;
	dbms_output.put_line('vEarliestBar='||vEarliestBar||' ; VLatestBar='||vLatestBar);
	
	loop
		pNewDateTime:=vNewDateTime; pOpen:=vOpen; pHigh:=vHigh; pLow:=vLow; pClose:=vClose; pVolume:=vVolume;
		fetch cOrig into vNewDateTime, vOpen, vHigh, vLow, vClose, vVolume;
		exit when cOrig%NOTFOUND;
		if pNewDateTime<vEarliestBar or pNewDateTime>vLatestBar then
			--dbms_output.put_line('vNewDateTime='||vNewDateTime||' ; pNewDateTime='||pNewDateTime||' ; oNewDateTime='||oNewDateTime);

			if pNewDateTime is null then	-- First Record it will be NULL
				oNewDateTime:=vNewDateTime; oOpen:=vOpen; oHigh:=vHigh; oLow:=vLow; oClose:=vClose; oVolume:=vVolume;
			else
				vGap:=(vNewDateTime-pNewDateTime)*TFm;
				for i in 0..vGap-1 loop
					oNewDateTime:=pNewDateTime+(i)/TFm;
	--Forex market opens on Sunday 5 pm EST (10:00 pm GMT), closes on Friday 5 pm EST (10:00 pm GMT)
	--Source data time is EST
	-- So, we only fill missing data if timestamp is between Sunday 1700 and Friday 1700
					if IsMarketOpen(oNewDateTime) then
						--dbms_output.put_line('Inserting record #'||i);
						--dbms_output.put_line('Inserting pNewDateTime='||to_char(pNewDateTime,'DD/MM/YYYY HH24:MI:SS')||' ; pOpen='||pOpen||' ; oOpen='||oOpen);
						oOpen:=pOpen+i*(vOpen-pOpen)/vGap;
						oHigh:=pHigh+i*(vHigh-pHigh)/vGap;
						oLow:=pLow+i*(vLow-pLow)/vGap;
						oClose:=pClose+i*(vClose-pClose)/vGap;
						oVolume:=pVolume+i*(vVolume-pVolume)/vGap;
						if i>0 then oisFilled:=1; else 	oisFilled:=0; end if;
						execute immediate 'insert into '||OrigTname||'_'||OrigTF||'_FILLED (NewdateTime, Open, High, Low, Close, Volume, isFilled) values (:NewDateTime,:oOpen,:oHigh,:oLow,:oClose,:oVolume,:oisFilled)'
						using oNewDateTime, oOpen, oHigh, oLow, oClose, oVolume, oisFilled;
					end if;
				end loop;
			end if;
		end if;
	end loop;	
END;
/
show errors
