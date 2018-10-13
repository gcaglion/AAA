-- Latest Updates
select ot.AccountNumber, max(ot.SnapshotTime-ac.TimeDiff/24)
from OpenTrades ot, Accounts ac where
ot.accountnumber=ac.accountnumber
group by ot.AccountNumber
order by 2 desc;

-- Channel Width
select ac.description, ot1.tradeitem, (ot1.currentAsk+ot1.CurrentBid/2), p.pScale, min(ot1.openprice) "chMin" , max(ot1.openprice) "chMax", 10000/p.pScale*(max(ot1.openprice)-min(ot1.openprice)) "chWidth" ,count(ot1.ticket) 
from opentrades ot1, pairs p, accounts ac
where 
p.symbol=ot1.tradeitem and
ac.accountnumber=ot1.accountnumber and
ot1.snapshottime between (
				select max(snapshottime-ac.TimeDiff/24)-1/96 from opentrades
			 ) and (
				select max(snapshottime-ac.TimeDiff/24) from opentrades
			 ) 
group by ac.description, ot1.tradeitem, (ot1.currentAsk+ot1.CurrentBid/2), p.pScale order by 1,2
/

-- Balancing
select ac.description, ot1.tradeitem, ot1.CurrentAsk, ot1.CurrentBid, p.pScale, 
min(ot1.openprice)  , max(ot1.openprice) , 10000/p.pScale*(max(ot1.openprice)-min(ot1.openprice)) "chWidth" ,count(ot1.ticket) "CountOpenPos",
2*min(ot1.CurrentAsk
from opentrades ot1, pairs p, accounts ac
where 
p.symbol=ot1.tradeitem and
ac.accountnumber=ot1.accountnumber and
ot1.snapshottime between (
				select max(snapshottime-ac.TimeDiff/24)-1/96 from opentrades
			 ) and (
				select max(snapshottime-ac.TimeDiff/24) from opentrades
			 ) 
group by ac.description, ot1.tradeitem, ot1.CurrentAsk, ot1.CurrentBid, p.pScale order by 1,2

-- Channel Width History
select distinct ot.accountnumber||' - '||ac.description, snapshottime, tradeitem,
  min(openprice) over (partition by ot.accountnumber, tradeitem
    order by snapshottime, openprice
    rows between unbounded preceding and current row) as min_openprice,
  max(openprice) over (partition by ot.accountnumber, tradeitem
    order by snapshottime, openprice desc
    rows between unbounded preceding and current row) as max_openprice,
  max(currentask) over (partition by ot.accountnumber, tradeitem
    order by snapshottime, openprice desc
    rows between unbounded preceding and current row) as max_CurrentAsk
from opentrades ot, accounts ac 
where ac.accountnumber=ot.accountnumber
order by 1,2,3
/


select ot1.accountnumber, ot1.snapshottime, ot1.tradeitem, min(ot1.openprice), max(ot1.openprice)
from OpenTrades ot1
where ot1.snapshottime<=(select max(ot2.snapshottime) from opentrades ot2 where ot2.accountnumber=ot1.accountnumber and ot2.tradeitem=ot1.tradeitem)
group by ot1.accountnumber, ot1.snapshottime, ot1.tradeitem
order by ot1.accountnumber, ot1.snapshottime, ot1.tradeitem;





-- Missing Steps
select ot.accountnumber, ot.tradetype, ot.tradeitem, ot.openprice, ot.openprice-lag(ot.openprice) over (order by ot.openprice) "Step" 
from opentrades ot, VLatestOpenTrades vot where 
ot.accountnumber=vot.accountnumber and
ot.snapshottime between vot.t1 and vot.t2
order by ot.accountnumber, ot.openprice;
