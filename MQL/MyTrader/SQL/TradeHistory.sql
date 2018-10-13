SELECT h.ACCOUNTNUMBER||' - '||a.description "Account", 
MyWeekNo(h.closetime) "Week",
h.TICKET, h.OPENTIME, h.TRADETYPE, h.TRADESIZE, h.TRADEITEM, h.OPENPRICE, h.TRADESL, h.TRADETP, h.CLOSETIME, h.CLOSETIMEN, h.CLOSEPRICE, h.TRADESWAP, h.TRADEPROFIT
FROM TradeHistory h , Accounts a where 
a.accountnumber=h.accountnumber and h.tradeitem is not null
/