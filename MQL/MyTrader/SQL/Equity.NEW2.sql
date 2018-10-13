-- Closed
select 
th.accountnumber||' - '||ac.description Account, 
MyWeekNo(th.closetime) 					Week,
th.tradeitem 							TradeItem, 
sum( th.tradeprofit+th.tradeswap ) 		ClosedProfit,
0										OpenPL,
0										Cash
from 
tradehistory th, accounts ac
where 
ac.accountnumber=th.accountnumber and
th.tradeitem is not null
group by 
th.accountnumber||' - '||ac.description, 
MyWeekNo(th.closetime),
th.tradeitem
union all
--Open
select 
ot1.accountnumber||' - '||ac.description Account, 
MyWeekNo(ot1.snapshottime)				 Week,
ot1.tradeitem							 TradeItem, 
0										 ClosedProfit,
sum(ot1.tradeprofit+ot1.tradeswap) 		 OpenPL,
0										 Cash
from 
opentrades ot1, 
(
	select accountnumber, MyWeekNo(snapshottime) Week, max(snapshottime) latestsnapshot from opentrades group by accountnumber, MyWeekNo(snapshottime)
) ot2,
accounts ac
where ot1.accountnumber=ot2.accountnumber and 
MyWeekNo(ot1.snapshottime)=ot2.Week and
ot1.snapshottime=ot2.latestsnapshot and
ac.accountnumber=ot1.accountnumber
group by 
ot1.accountnumber||' - '||ac.description, 
MyWeekNo(ot1.snapshottime),
ot1.tradeitem
union all
--- Cash
select 
th.accountnumber||' - '||ac.description Account, 
MyWeekNo(th.closetime) 					Week,
th.tradeitem 							TradeItem, 
0								 		ClosedProfit,
0										OpenPL,
sum( th.tradeprofit+th.tradeswap ) 		Cash
from 
tradehistory th, accounts ac
where 
ac.accountnumber=th.accountnumber and
th.tradetype='CASH'
group by 
th.accountnumber||' - '||ac.description, 
MyWeekNo(th.closetime),
th.tradeitem
/
