
------------------------------------------------------------------------
-- New OpenTrades, seems to work!
-- Uses 5 minutes as max delay between pairs snapshot
-- Uses 1 day as max delay to consider the latest snapshot still current
------------------------------------------------------------------------
select ot.accountnumber||' - '||ac.description Account, ot.tradeitem, sum(ot.tradeprofit+ot.tradeswap) OpenPL,
0 ClosedPL
from opentrades ot, accounts ac,
(
	select accountnumber, tradeitem, max(snapshottime) latestsnapshot from opentrades group by accountnumber, tradeitem
	having ( sysdate - max(snapshottime) ) <1
) lot
where 
ac.accountnumber=ot.accountnumber and
ot.accountnumber=lot.accountnumber and ot.tradeitem=lot.tradeitem and ot.snapshottime between lot.latestsnapshot-5/1440 and lot.latestsnapshot
group by ot.accountnumber||' - '||ac.description, ot.tradeitem
--order by 1,2
--/
union all
select th.accountnumber||' - '||ac.description Account, th.tradeitem, 
--sum(th.tradeprofit), sum(th.tradeswap), 
0 OpenPL, sum(th.tradeprofit+th.tradeswap) ClosedPL
from tradehistory th, accounts ac
where 
ac.accountnumber=th.accountnumber and
tradeitem is not null
group by th.accountnumber||' - '||ac.description, th.tradeitem
--order by 1,2
/

