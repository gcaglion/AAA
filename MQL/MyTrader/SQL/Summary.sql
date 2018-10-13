-- Closed Profits
select CumProfit, PosType, Week, Account, TradeItem from VHistoryClosed
union all
-- Cash I/O
select CumProfit, PosType, Week, Account, TradeItem from VHistoryCash
union all
-- Open Trades
select 
sum(ot.tradeprofit+ot.tradeswap) 			"NetProfit",
'Open' 										"PosType", 
vot.weekno									"Week", 
vot.accountnumber||' - '||ac.description 	"Account", 
vot.tradeitem								"TradeItem"
from opentrades ot, vopentrades vot, accounts ac
where 
ac.accountnumber=ot.accountnumber and
ot.snapshottime=vot.weeklastsnapshot and
vot.weekno=myweekno(ot.snapshottime) and
vot.accountnumber=ot.accountnumber and
vot.tradeitem=ot.tradeitem
group by 'Open', vot.weekno, vot.accountnumber||' - '||ac.description , vot.tradeitem
;
