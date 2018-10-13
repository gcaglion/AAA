select 
	ot1.accountnumber, decode(trim(ot1.tradeitem),'GOLD','XAUUSD',ot1.tradeitem) tradeitem,
	a.description, a.startdate, a.startbalance, a.accountbalance, a.accountprofit, latestupdate, a.accountequity, a.netbalance, a.marginp,
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)) "AccountProfit",
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)/a.StartBalance) "AccountProfit%",
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)/StartBalance*365/(sysdate-a.startdate)) "Annualized Net Profit%",
	a.AbsSize, 
	decode(a.StartBalance,0,0,(a.AbsSize/a.StartBalance)*100000) "Size-Rel",
	100*decode(MarginP,0,0,(AccountEquity/MarginP)) "Margin%", 
	sum(ot1.tradeprofit+ot1.tradeswap) "OpenPL",
	sum(th.tradeprofit-th.tradeswap) "ClosedProfit"
from
	OpenTrades ot1, accounts a, TradeHistory th,
	(
		select 
		accountnumber, tradeitem, max(snapshottime) LatestSnapshot
		from opentrades 
		group by accountnumber,tradeitem order by 1,2
	) ot2
where
	ot1.accountnumber=ot2.accountnumber and
	ot1.tradeitem=ot2.tradeitem and
	ot1.snapshottime=ot2.latestsnapshot and
	a.accountnumber=ot1.accountnumber and
	ot1.accountnumber=th.accountnumber and
	ot1.tradeitem=th.tradeitem and
	th.tradeitem is not null and
	a.IsDemo='N' and a.IsChannel='Y'
group by 
	ot1.accountnumber, ot1.tradeitem,
	a.description, a.startdate, a.startbalance, a.accountbalance, a.accountprofit, latestupdate, a.accountequity, a.netbalance, a.marginp,
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)),
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)/a.StartBalance),
	decode(a.StartBalance,0,0,(a.NetBalance-a.StartBalance)/StartBalance*365/(sysdate-a.startdate)),
	a.AbsSize, 
	decode(a.StartBalance,0,0,(a.AbsSize/a.StartBalance)*100000),
	100*decode(MarginP,0,0,(AccountEquity/MarginP))
order by 1,2
/
