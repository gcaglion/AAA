create or replace function SecondsToDateTime(x number) return char is
ret char(12);
begin
SELECT 
    TO_CHAR(TRUNC(x/3600),'FM9900') || ':' ||
    TO_CHAR(TRUNC(MOD(x,3600)/60),'FM00') || ':' ||
    TO_CHAR(MOD(x,60),'FM00')
into ret FROM DUAL ;
return ret;
end;
/
show errors;
