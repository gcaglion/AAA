-- Latest Updates
connect GridUser/GridPwd
select ot.AccountNumber, max(ot.SnapshotTime-ac.TimeDiff/24)
from OpenTrades ot, Accounts ac where
ot.accountnumber=ac.accountnumber
group by ot.AccountNumber
order by 2 desc;
