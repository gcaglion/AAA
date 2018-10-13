select 
ot1.accountnumber||' - '||ac.description 	Account, 
MyWeekNo(ot1.snapshottime) 			Week,
ot1.tradeitem 					TradeItem, 
0						ClosedProfit,
sum(ot1.tradeprofit+ot1.tradeswap) 		OpenPL
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
group by ot1.accountnumber||' - '||ac.description, MyWeekNo(ot1.snapshottime), ot1.tradeitem
order by 1,2
/
