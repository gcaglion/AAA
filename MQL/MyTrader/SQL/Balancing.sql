select ac.accountnumber||' - '||ac.description "Account",
ot.tradeitem, ot.currentask, p.pScale,
min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem) "MinPrice",
max(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem) "MaxPrice",
10000/p.pScale*(max(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem)-min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem)) "chWidth",
2*least((ot.currentask-min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem))/(max(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem)-min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem)),
1-(ot.currentask-min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem))/(max(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem)-min(ot.openprice) over (partition by ac.AccountNumber, ot.tradeitem))) "Position"
from opentrades ot, vopentrades vot, pairs p, accounts ac
where
p.symbol=ot.tradeitem and
ac.accountnumber=ot.accountnumber and
ot.snapshottime=vot.weeklastsnapshot and
vot.weekno=myweekno(ot.snapshottime) and
vot.accountnumber=ot.accountnumber and
vot.tradeitem=ot.tradeitem
and ac.isdemo='N'
order by 1,2
/
