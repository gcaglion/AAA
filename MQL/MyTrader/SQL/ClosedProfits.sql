select 
th.accountnumber||' - '||ac.description 	Account, 
MyWeekNo(th.closetime) 				Week,
th.tradeitem 					TradeItem, 
sum( th.tradeprofit+th.tradeswap ) 		ClosedProfit,
0						OpenPL
from 
tradehistory th, accounts ac
where 
ac.accountnumber=th.accountnumber and
th.tradeitem is not null
group by 
th.accountnumber||' - '||ac.description, 
MyWeekNo(th.closetime),
th.tradeitem
order by 1,2
/
