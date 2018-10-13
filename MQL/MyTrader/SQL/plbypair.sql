select
ot.accountnumber||' - '||ac.description,
ot.ticket,
ot.tradeitem,
0 "Closed",
0 "pScale",
--avg((currentask+currentbid)/2) "Current",
--sum(ot.tradeprofit+ot.tradeswap) PL,
((currentask+currentbid)/2) "Current",
(ot.tradeprofit+ot.tradeswap) PL,
100000 chMin,
0 chMax,
0 chW
from opentrades ot, accounts ac
where
ac.accountnumber=1501637 and
ac.accountnumber=ot.accountnumber and
ot.snapshottime between
			(select max(snapshottime)-10/1440 from griduser.opentrades where accountnumber=ot.accountnumber)
			and
			(select max(snapshottime) from griduser.opentrades where accountnumber=ot.accountnumber)
--group by ot.accountnumber||' - '||ac.description , ot.tradeitem
--having sum(ot.tradeprofit+ot.tradeswap)!=0
and (ot.tradeprofit+ot.tradeswap)!=0
order by 1,2
/
