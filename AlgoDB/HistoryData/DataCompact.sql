create or replace procedure DataCompact (OrigTname varchar2, DestTname varchar2, DestTF number) as
	--======== DestTF is the number of minutes in the timeframe ===

	TDiff number;
	pNewDateTime date; pOpen number; pHigh number; pLow number; pClose number; pVolume number;
	vNewDateTime date; vOpen number; vHigh number; vLow number; vClose number; vVolume number;
	oNewDateTime date; oOpen number; oHigh number; oLow number; oClose number; oVolume number;
	type rc is ref cursor;
	cOrig rc; 
	nrec_orig number :=0; nrec_dest number :=0;

	Function MyTrunc(iDate Date, mins number) return date as
	dm number; qm number;
	BEGIN
		dm:=1440*(iDate-trunc(iDate,'DD'));
		qm:=trunc(dm/mins);
		return trunc(iDate,'DD')+qm*mins/1440;
	END;

BEGIN
	open cOrig for
	'select NewDateTime, Open, High, Low, Close, Volume from '||OrigTname||' order by NewDateTime';

	loop
		pNewDateTime:=vNewDateTime; pOpen:=vOpen; pHigh:=vHigh; pLow:=vLow; pClose:=vClose; pVolume:=vVolume;
		fetch cOrig into vNewDateTime, vOpen, vHigh, vLow, vClose, vVolume;
		exit when cOrig%NOTFOUND;
		nrec_orig:=nrec_orig+1;
		--dbms_output.put_line('vNewDateTime='||vNewDateTime||' ; pNewDateTime='||pNewDateTime);

		if pNewDateTime is null then
			oNewDateTime:=MyTrunc(vNewDateTime,DestTF); oOpen:=vOpen; oHigh:=vHigh; oLow:=vLow; oClose:=vClose; oVolume:=vVolume;
		else
			if MyTrunc(vNewDateTime,DestTF)=MyTrunc(pNewDateTime,DestTF) then
				--dbms_output.put_line('--Same hour--');
				-- oNewDateTime and oOpen should not change, it's the same hour.
				if vHigh>oHigh then oHigh:=vHigh; end if;
				if vLow<oLow then oLow:=vLow; end if;
				oClose:=vClose; -- Metto sempre il piu' recente.
				oVolume:=oVolume+vVolume;
			else
				--dbms_output.put_line('--Hour changed--');
				
				-- Insert new record in Output table
				--dbms_output.put_line('Insert <New Hour>.');
				--dbms_output.put_line('vOpen='||vOpen||' - oOpen='||oOpen||' - pOpen='||pOpen||' - oHigh='||oHigh||' - pHigh='||pHigh||' - oLow='||oLow||' - pLow='||pLow);
				BEGIN
					execute immediate 'insert into '||DestTname||'(NewdateTime, Open, High, Low, Close, Volume) values (:NewDateTime,:Open,:High,:Low,:oClose,:Volume)'
					using oNewDateTime, oOpen, oHigh, oLow, oClose, oVolume;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN 
					nrec_dest := nrec_dest-1;
					CONTINUE;
				END;
				nrec_dest := nrec_dest+1;
				oNewDateTime:=MyTrunc(vNewDateTime,DestTF); oOpen:=vOpen; oHigh:=vHigh; oLow:=vLow; oClose:=vClose;
			end if;
		end if;
	end loop;
	commit;
	dbms_output.put_line(nrec_orig||' records from '||OrigTname||' summarized into '||nrec_dest||' records in '||DestTname);
END;
/
show errors
