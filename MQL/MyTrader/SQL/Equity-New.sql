select tradeitem, sum(tradeprofit+tradeswap) OpenPL from opentrades where
accountnumber=918062 and
snapshottime=(select max(snapshottime) from opentrades where accountnumber=918062)
group by tradeitem
order by tradeitem
/
select tradeitem, sum(tradeprofit+tradeswap) ClosedPL from tradehistory where
accountnumber=918062 
and tradeitem is not null
group by tradeitem
order by tradeitem
/

select ot.accountnumber||' - '||ac.description Account, ot.tradeitem, ot.tradetype, sum(ot.tradeprofit+ot.tradeswap) 
from opentrades ot, accounts ac
where
ac.acountnumber=ot.accountnumber and
ot.snapshottime=(select max(snapshottime) from opentrades ot2 where ot2.accountnumber=ot.accountnumber)
group by ot.accountnumber,  ot.tradeitem, ot.tradetype
order by ot.accountnumber,  ot.tradeitem, ot.tradetype
/

-- Working Monitor PL by Pair --
select ot.accountnumber||' - '||ac.description Account, ot.tradeitem, ot.tradetype, sum(ot.tradeprofit+ot.tradeswap) OpenPL, 0 ClosedPL, 0 Cash
from opentrades ot, accounts ac
where
ac.accountnumber=ot.accountnumber and
ot.snapshottime=(select max(snapshottime) from opentrades ot2 where ot2.accountnumber=ot.accountnumber)
group by ot.accountnumber||' - '||ac.description ,ot.tradeitem, ot.tradetype
--order by 1,2,3
union all
-- History (no cash/bonus)
select th.accountnumber||' - '||ac.description Account, th.tradeitem, th.tradetype, 0 OpenPL, sum(th.tradeprofit+th.tradeswap) ClosedPL, 0 Cash
from TradeHistory th, accounts ac
where
ac.accountnumber=th.accountnumber
and th.tradeitem is not null and th.tradetype is not null
group by th.accountnumber||' - '||ac.description, th.tradeitem, th.tradetype
--order by 1,2,3
union all
-- Cash/Bonus
select th.accountnumber||' - '||ac.description Account, 'CASH', th.tradetype, 0 OpenPL, 0 ClosedPL, sum(th.tradeprofit+th.tradeswap) Cash
from TradeHistory th, accounts ac
where
ac.accountnumber=th.accountnumber
and th.tradetype ='CASH' and th.tradeitem is null
group by th.accountnumber||' - '||ac.description, th.tradeitem, th.tradetype
--order by 1,2,3
/



select * from opentrades where
accountnumber=918062 and
tradetp=0 and 
snapshottime=(select max(snapshottime) from opentrades where accountnumber=918062)
order by accountnumber
/
