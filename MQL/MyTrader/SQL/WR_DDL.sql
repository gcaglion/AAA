connect GridUser/GridPwd;

drop table Accounts cascade constraints;
create table Accounts(
	Broker			varchar2(10),
	AccountNumber	number,
	VPSEnv			varchar2(10),
	TimeDiff		number,
	Description 	varchar2(40),
	Owner			varchar2(40),
	IsDemo			char(1),
	StartDate		date,
	StartBalance	number,
	AccountBalance	number,
	AccountProfit	number,
	AccountEquity	number,
	NetBalance		number,
	AccountCredit	number,
	MarginP			number,
	AbsSize			number,
	LatestUpdate	date,
	CloseDate		date
);
alter table Accounts drop constraints Accounts_PK;
alter table Accounts add constraints Accounts_PK Primary Key (AccountNumber) using index tablespace GridIdx;
insert into Accounts values('Alpari',776849,'260-288',1,'A-Alpari','A','N',to_date('03032014','DDMMYYYY'),100000,124759.41,-20133.07,104626.34,104626.34,0,263.27539217,0.7,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',2131916,'G-XM',1,'G-XM','G','N',to_date('14042014','DDMMYYYY'),20000,21760.74,0,21760.74,21760.74,0,0,0,to_date('060620140800','DDMMYYYYHH24MI'), null);
insert into Accounts values('FXCM',87012568,'G-XM',-2,'T-FXCM','T','N',to_date('12022014','DDMMYYYY'),25000,31069.27,-4926.25,26143.02,26143.02,0,348.43281906,0.16,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('XM',2148515,'G-XM',1,'L-XM','L','N',to_date('16102013','DDMMYYYY'),15000,25366.64,-9250.94,20873.3,16115.7,4757.60,219.83052196,0.12,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',917261,'260-294',1,'S-Alpari','S','N',to_date('09032014','DDMMYYYY'),7500,9850.87,-1624.83,8226.04,8226.04,0,257.83077176,0.06,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('XM',775191,'260-288',1,'I-Alpari','I','N',to_date('28052014','DDMMYYYY'),50000,51076.45,-762.59,50313.86,50313.86,0,954.55829702,0.3,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('XM',774022,'260-288',1,'G-Alpari','G','N',to_date('28052014','DDMMYYYY'),20000,20789.83,-489.29,20300.54,20300.54,0,547.95028012,0.2,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',918583,'260-294',1,'LE-XM','LE','N',to_date('22052014','DDMMYYYY'),10000,10411.83,-333.82,10078.01,10078.01,0,11145.00713505,0.08,to_date('060620140815','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',918062,'260-288',1,'IN-Alpari','IN','N',to_date('29042014','DDMMYYYY'),20000,22044.88,-2150.61,19894.27,19894.27,0,291.39903085,0.16,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',774678,'260-288',1,'M-Alpari','M','N',to_date('24022014','DDMMYYYY'),80000,101331.7,-21365.61,79966.09,79966.09,0,249.99910245,0.6,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',776982,'260-294',1,'V-Alpari','V','N',to_date('25042014','DDMMYYYY'),100000,110417.89,-10943.09,99474.8,99474.8,0,305.80718526,0.8,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',776980,'260-294',1,'R-Alpari','R','N',to_date('06032014','DDMMYYYY'),50000,57910.24,-8726.36,49183.88,49183.88,0,315.7718395,0.3,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('XM',2171896,'G-XM',1,'I-XM','I','N',to_date('06032014','DDMMYYYY'),50000,78904.26,-39478.16,53844.1,39426.1,0,149.88325823,0.4,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts values('Alpari',777094,'260-294',1,'G-Alpari2','G','N',to_date('06032014','DDMMYYYY'),120000,167011.5,-72512.37,94499.13,94499.13,0,116.54113551,0.8,to_date('060620140830','DDMMYYYYHH24MI'), null);
insert into Accounts (Broker,	 AccountNumber, VPSEnv,	 TimeDiff, Description, Owner, StartDate,						StartBalance, AbsSize, IsDemo)
values				 ('Alpari',		1501637,	'260-288',1,		'MZ-Alpari','MZ',	to_date('29062014','DDMMYYYY'),		0,			0.16,	'N');

drop table TradeHistory;
create table TradeHistory (
	AccountNumber	number,
	Ticket			number,
	OpenTime		date,
	TradeType		varchar2(5),
	TradeSize		number,
	TradeItem		char(6),
	OpenPrice		number,
	TradeSL			number,
	TradeTP			number,
	CloseTime		date,
	CloseTimeN		number,
	ClosePrice		number,
	TradeSwap		number,
	TradeProfit		number
);
alter table TradeHistory add constraint TradeHistory_PK Primary Key (AccountNumber, Ticket) using index tablespace GridIdx;

drop table OpenTrades;
create table OpenTrades(
	AccountNumber	number,
	SnapshotTime	date,
	Ticket			number,
	OpenTime		date,
	TradeType		varchar2(4),
	TradeSize		number,
	TradeItem		char(6),
	OpenPrice		number,
	CurrentAsk		number,
	CurrentBid		number,
	TradeSL			number,
	TradeTP			number,
	TradeSwap		number,
	TradeProfit		number	
);
alter table OpenTrades add constraint OpenTrades_PK Primary Key (AccountNumber, SnapshotTime, Ticket) using index tablespace GridIdx;

create index OpenTrades_SnapshotTime_Idx on OpenTrades(SnapshotTime) tablespace GridIdx;
create index OpenTrades_Ticket_Idx on OpenTrades(Ticket) tablespace GridIdx;
@MyWeekNo;
create index OpenTrades_MyWeekNo_Idx on OpenTrades(MyWeekNo(SnapshotTime)) tablespace GridIdx;

drop table Pairs cascade constraints;
create table Pairs(
	Symbol		varchar2(6),
	Step		number,
	ChannelMin	number,
	ChannelMax	number,
	pScale		number
);
alter table Pairs add constraint Pairs_PK primary key (Symbol);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values('EURUSD',30,1.1900,1.5000,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'NZDUSD',20,0.6615,0.88,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'USDCAD',20,0.94,1.07,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'USDJPY',20,85,115,100);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values('EURJPY',20,92,140,100);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'GBPNZD',40,1.77,2.22,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'NZDCHF',20,0.639,0.815,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'EURGBP',20,0.778,0.94,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'EURNOK',100,7.25,8.25,10);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'GBPUSD',30,1.48,1.66,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values( 'USDCHF',20,0.855,1,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'AUDJPY',20,74,105,100);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'GBPCHF',20,1.38,1.55,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'CADJPY',20,87,101,100);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'NZDSGD',20,0.929,1.07,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'EURPLN',100,4.02,4.42,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'AUDUSD',20,0.8235,1.0825,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'USDZAR',30,6.6,11.9,1000);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'EURAUD',20,1.16,1.6,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(   'GOLD',50,1150,1950,1000);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values(  'XAUUSD',      50    ,    1150 ,    1950 ,     1000   );
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values('GBPAUD',40,1.54,1.9,1);
insert into Pairs(Symbol, Step, ChannelMin, ChannelMax, pScale) values('AUDCAD', 20, 0.92, 1.08, 1);

drop table AccountPairs cascade constraints;
create table AccountPairs(
	AccountNumber	number,
	Symbol			varchar2(6),
	TradeSize		number
);
alter table AccountPairs add constraint AccountPairs_PK primary key(AccountNumber, Symbol) using index tablespace GridIdx;
alter table AccountPairs add constraint AccountPairs_FK_Accounts foreign key (AccountNumber) references Accounts(AccountNumber);
alter table AccountPairs add constraint AccountPairs_FK_Pairs foreign key (Symbol) references Pairs(Symbol);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774022,'GBPAUD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774022,'GBPNZD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774022,'NZDUSD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774022,'USDCHF',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774678,'AUDJPY',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774678,'EURUSD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(774678,'NZDUSD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(775191,'CADJPY',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(775191,'EURUSD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(775191,'GBPNZD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776849,'AUDUSD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776849,'EURGBP',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776849,'GBPNZD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776849,'USDJPY',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776980,'AUDUSD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776980,'CADJPY',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776980,'EURGBP',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776982,'CADJPY',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776982,'EURUSD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776982,'GBPNZD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(776982,'USDCHF',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(777094,'AUDUSD',0.3);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(777094,'EURAUD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(777094,'GBPNZD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(777094,'USDJPY',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(777094,'XAUUSD',0.2);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(917261,'AUDJPY',0.02);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(917261,'GBPNZD',0.02);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(917261,'USDCHF',0.02);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918062,'AUDJPY',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918062,'EURUSD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918062,'GBPNZD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918062,'USDJPY',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918583,'GBPNZD',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(918583,'USDCHF',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'AUDNZD',0.5);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'AUDUSD',0.5);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'EURCAD',1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'EURCHF',0.5);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'EURJPY',1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'EURUSD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'GBPAUD',0.5);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'GBPCHF',1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'GBPUSD',0.8);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'NZDUSD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'USDCAD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'USDCHF',1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2131916,'USDJPY',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2148515,'EURGBP',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2148515,'GBPNZD',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2148515,'NZDCHF',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2148515,'USDJPY',0.06);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2171896,'EURAUD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2171896,'GBPNZD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2171896,'GOLD',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(2171896,'USDJPY',0.1);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(87012568,'AUDJPY',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(87012568,'EURGBP',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(87012568,'NZDUSD',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(87012568,'USDCHF',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(1501637, 'AUDCAD',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(1501637, 'GBPNZD',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(1501637, 'EURUSD',0.04);
insert into AccountPairs(AccountNumber, Symbol, TradeSize) values(1501637, 'USDJPY',0.04);


create or replace view VLatestOpenTrades as select accountnumber, max(snapshottime)-10/1440 as "T1", max(snapshottime) as "T2" from opentrades group by accountnumber;
create or replace view VOpenTrades as select myweekno(snapshottime) WeekNo, accountnumber, TradeItem, max(snapshottime) WeekLastSnapshot from opentrades group by myweekno(snapshottime), accountnumber, TradeItem order by 1,2,3;
create or replace view VCumCash as 	select MyWeekNo(th1.closetime) Week, th1.accountnumber, decode(th1.tradeitem,null,tradeprofit,0) CashProfit from tradehistory th1, accounts ac where ac.accountnumber=th1.accountnumber order by 1,2;
create or replace view VHistoryClosed as
select distinct CumProfit, PosType, Week, AccountNumber, Account, TradeItem from
	(
	select 
	'Closed'											PosType,
	MyWeekNo(th.closetime)								Week,
	th.AccountNumber									AccountNumber,
	th.AccountNumber||' - '||ac.description				Account,
	th.TradeItem										TradeItem,
	sum(th.tradeprofit+th.tradeswap) over(partition by th.AccountNumber, th.TradeItem order by MyWeekNo(th.closetime)) CumProfit
	from tradehistory th, accounts ac where
	ac.accountnumber=th.accountnumber and
	th.tradeitem is not null
	)
;
create or replace view VHistoryCash as
select Week, PosType, Account, AccountNumber, TradeItem, CumProfit from 
	(
	select 
	distinct vc.Week											Week,
	'Cash'														PosType,
	vc.AccountNumber											AccountNumber,
	vc.AccountNumber||' - '||ac.description						Account,
	'Cash'														TradeItem,
	sum(vc.cashprofit) over(partition by vc.accountnumber order by vc.week)	CumProfit
	from vcumcash vc, accounts ac
	where 
	vc.accountnumber=ac.accountnumber
	)
;
create or replace view VVOpenTrades as
select 
sum(ot.tradeprofit+ot.tradeswap) 			NetProfit,
'Open' 										PosType, 
vot.weekno									Week, 
vot.AccountNumber							AccountNumber,
vot.accountnumber||' - '||ac.description 	Account, 
vot.tradeitem								TradeItem
from opentrades ot, vopentrades vot, accounts ac
where 
ac.accountnumber=vot.accountnumber and
ot.snapshottime=vot.weeklastsnapshot and
vot.weekno=myweekno(ot.snapshottime) and
vot.accountnumber=ot.accountnumber and
vot.tradeitem=ot.tradeitem
group by 'Open', vot.weekno, vot.AccountNumber, vot.accountnumber||' - '||ac.description , vot.tradeitem
;

@Equity
