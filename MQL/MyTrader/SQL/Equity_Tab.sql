drop type Equity_tab;
drop type Equity_obj;
create type Equity_obj is object(AccountNumber number, Account varchar2(50),	Week number, PosType varchar2(6), TradeItem	varchar2(6), ClosedProfit number, OpenPL number, Equity number);
/
show errors;
create type Equity_tab is table of Equity_obj;
/
show errors;


create or replace function EquityTable return Equity_tab is
	l_Equity_tab Equity_tab := Equity_tab();
	n integer := 0;
	vAccountCredit number;
BEGIN
/*
	execute immediate 'select accountCredit from Accounts where AccountNumber='||l_Equity_tab(r).AccountNumber
	into vAccountCredit;
*/
	for r in (select AccountNumber, Account, Week, PosType, TradeItem, CumProfit, 0 "OpenPL", 0 "NetProfit" from VHistoryClosed) loop
		l_Equity_tab.extend;
		n:=n+1;
		l_Equity_tab(n) := Equity_obj(r.AccountNumber, r.Account, r.Week, r.PosType, r.TradeItem, r.CumProfit, 0, 0);
	end loop;
	for r in (select AccountNumber, Account, Week, PosType, TradeItem, CumProfit, 0 "OpenPL", 0 "NetProfit" from VHistoryCash) loop
		l_Equity_tab.extend;
		n:=n+1;
		l_Equity_tab(n) := Equity_obj(r.AccountNumber, r.Account, r.Week, r.PosType, r.TradeItem, r.CumProfit, 0, 0);
	end loop;
	for r in (select AccountNumber, Account, Week, PosType, TradeItem, 0 "ClosedProfit", NetProfit, 0 "NetProfit" from VVOpenTrades) loop
		l_Equity_tab.extend;
		n:=n+1;
		l_Equity_tab(n) := Equity_obj(r.AccountNumber, r.Account, r.Week, r.PosType, r.TradeItem, 0, r.NetProfit, 0);
	end loop;
	
	for r in l_Equity_tab.first..l_Equity_tab.last loop
		l_Equity_tab(r).Equity := l_Equity_tab(r).ClosedProfit + l_Equity_tab(r).OpenPL ;
	end loop;
	
	
	return l_Equity_tab;
END;
/
show errors;
