select 
th.accountnumber||' - '||ac.description Account, 
MyWeekNo(th.closetime) Week,
decode( th.tradeitem,null, th.tradetype,th.tradeitem) Item, 
sum( decode( th.tradetype,'CASH', 0, th.tradeprofit+th.tradeswap ) ) TradeProfit,
sum( decode( th.tradetype,'CASH', th.tradeprofit+th.tradeswap, 0 ) ) CashFlow
from 
tradehistory th, accounts ac
where 
ac.accountnumber=th.accountnumber and
th.tradetype<>'BONUS' 
group by 
th.accountnumber||' - '||ac.description, 
MyWeekNo(th.closetime) ,
decode( th.tradeitem,null, th.tradetype,th.tradeitem)
order by 1,2
/
