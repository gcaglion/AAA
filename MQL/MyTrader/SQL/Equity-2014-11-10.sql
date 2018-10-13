-------------------------------------------------------------------
create or replace view VCash as
select 
accountnumber, Week,
sum(Cash) over (partition by AccountNumber order by Week rows between unbounded preceding and current row) 	Amount
from
(
select AccountNumber, MyWeekNo(CloseTime) Week, sum(decode(TradeType, 'CASH', tradeprofit+tradeswap, 0)) Cash from tradehistory group by accountnumber, myweekno(closetime)
);

create or replace view VOpenTrades as
select 	
ot.accountnumber,
MyWeekNo(ot.snapshottime)													Week,
sum(ot.tradeprofit+ot.tradeswap)											OpenPL
from opentrades ot,
(
	select Myweekno(snapshottime) WeekNo, accountnumber,
	max(snapshottime) Latest 
	from opentrades 
	group by Myweekno(snapshottime), accountnumber
) wot
where
ot.accountnumber=wot.accountnumber and
ot.snapshottime=wot.Latest and
ot.accountnumber=wot.accountnumber
group by ot.accountnumber, MyWeekNo(ot.snapshottime)
order by 1,2
;

create or replace view VHistory as
select accountnumber, week, sum(ClosedPL) over(partition by accountnumber order by week) ClosedPlProg
from 	(
	select 
	accountnumber, myweekno(closetime) Week,
	sum(tradeprofit+tradeswap) closedpl
	from tradehistory
	where tradeitem is not null --and tradetype is not null
	group by accountnumber, myweekno(closetime)
	order by 1,2
	)
--------------------------------------------
select vc.accountnumber||' - '||ac.description Account, vc.week, vh.closedplprog, vot.openpl, vc.amount Cash, (vh.closedplprog+vot.openpl+vc.amount) Equity
from vcash vc, vopentrades vot, vhistory vh, accounts ac where
vh.accountnumber=vc.accountnumber and vh.week=vc.week and vot.accountnumber=vc.accountnumber and vot.week=vc.week and ac.accountnumber=vh.accountnumber
order by 1,2
/