select ot.accountnumber, ot.tradeitem, ot.openprice, ot.tradetype, ot.tradetp,
(ot.openprice-lag(ot.openprice,1,ot.openprice-p.step/10000*p.pscale) over (partition by ot.accountnumber, tradeitem order by ot.openprice))*10000/p.pscale "OP_Step"
from opentrades ot, VLatestOpenTrades vlot , pairs p
where
ot.snapshottime=vlot.t2 and
ot.tradeitem=p.symbol
order by 1,2,3;
