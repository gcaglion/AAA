//+------------------------------------------------------------------+
//|                                                       MyORCL.mq4 |
//|                                                         gcaglion |
//|                                        http://www.algoinvest.org |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      "http://www.algoinvest.org"
#property version   "1.10"
#property strict
/*
   Revision History
   1.10	Added CASH, BONUS as possible TradeType / TradeDesc
*/

#import "MyOrcl.dll"
   int OraConnect       (int pDebug, uchar &user_name[], uchar &user_pwd[], uchar &db_service[]);
   int InsertHistory    (int pDebug, double pAcctNumber, double pTicket, uchar &pOpenTime[], uchar &pTradeType[], double pTradeSize, uchar &pTradeItem[], double pOpenPrice, double pTradeSL, double pTradeTP, uchar &pCloseTime[], double pCloseTimeN, double pClosePrice, double pTradeSwap, double pTradeProfit);
   int InsertOpenTrades (int pDebug, double pAcctNumber, uchar &pSnapshotTime[], double pTicket, uchar &pOpenTime[], uchar &pTradeType[], double pTradeSize, uchar &pTradeItem[], double pOpenPrice, double pTradeSL, double pTradeTP, double pTradeSwap, double pTradeProfit, double pCurrentAsk, double pCurrentBid);
   int UpdateAccounts   (int pDebug, double pAcctNumber, double pAccountBalance, double pAccountProfit, double pAccountEquity, double pNetBalance, double pMarginP);
#import

int ret, i;

extern string  OracleUserName="GridUser";
extern string  OraclePassword="GridPwd";
extern string  OracleConnString="MyNN";
extern int     RefreshInterval=15;  // Refresh Interval, Minutes
extern int     EnableDebug=0;    // Enable Debug? 0/1    

#define OP_CASH  6
#define OP_BONUS 7
//--------------------------------------------------------------------------------------------------------------
// Oracle - related Functions (OracleConnect, OracleInsertHistory, OracleInsertOpenTrades, OracleUpdateAccounts)
//--------------------------------------------------------------------------------------------------------------
int OracleConnect (string DBUserName, string DBPassword, string DBConnString){
   uchar user_name[], user_pwd[], db_service[];
   StringToCharArray(DBUserName,   user_name);
   StringToCharArray(DBPassword,   user_pwd);
   StringToCharArray(DBConnString, db_service);
   
   return ( OraConnect(EnableDebug, user_name, user_pwd, db_service) );
}

int OracleInsertHistory(double AcctNumber, double Ticket, string OpenTime, int TradeType, double TradeSize, string TradeItem, double OpenPrice, double TradeSL, double TradeTP, string CloseTime, double CloseTimeN, double ClosePrice, double TradeSwap, double TradeProfit, string vComment){
   uchar pOpenTime[], pTradeType[], pTradeItem[], pCloseTime[];
   string TradeDesc; string lDesc=StringSubstr(vComment,0,8);
   
   if       (TradeType==OP_BUY)                                         TradeDesc="BUY";
   else if  (TradeType==OP_SELL)                                        TradeDesc="SELL";
   else if  (TradeType==OP_BONUS)                                       TradeDesc="BONUS";
   else if  (TradeType==OP_CASH && lDesc=="Rollover")                   TradeDesc="SWAP";
   else if  (TradeType==OP_CASH)                                        TradeDesc="CASH";
   else                                                                 TradeDesc="";
   
   StringToCharArray(OpenTime, pOpenTime);
   StringToCharArray(TradeDesc, pTradeType);
   StringToCharArray(TradeItem, pTradeItem);
   StringToCharArray(CloseTime, pCloseTime);
   
   return ( InsertHistory(EnableDebug, AcctNumber, Ticket, pOpenTime, pTradeType, TradeSize, pTradeItem, OpenPrice, TradeSL, TradeTP, pCloseTime, CloseTimeN, ClosePrice, TradeSwap, TradeProfit) );  
}

int OracleInsertOpenTrades(double AcctNumber, string SnapshotTime, double Ticket, string OpenTime, int TradeType, double TradeSize, string TradeItem, double OpenPrice, double TradeSL, double TradeTP, double TradeSwap, double TradeProfit, double CurrentAsk, double CurrentBid){
   uchar pSnapshotTime[], pOpenTime[], pTradeType[], pTradeItem[];
   string TradeDesc;
   if (TradeType==OP_BUY){
      TradeDesc="BUY";
   } else{
      TradeDesc="SELL";
   }
   StringToCharArray(SnapshotTime, pSnapshotTime);
   StringToCharArray(OpenTime, pOpenTime);
   StringToCharArray(TradeDesc, pTradeType);
   StringToCharArray(TradeItem, pTradeItem);
   //printf("OracleInsertOpenTrades() calling InsertOpenTrades with CurrentAsk=",CurrentAsk," , CurrentBid=",CurrentBid);
   return ( InsertOpenTrades(EnableDebug, AcctNumber, pSnapshotTime, Ticket, pOpenTime, pTradeType, TradeSize, pTradeItem, OpenPrice, TradeSL, TradeTP, TradeSwap, TradeProfit, CurrentAsk, CurrentBid) );   
}

int OracleUpdateAccounts(double AcctNumber, double AcctBalance, double AcctProfit, double AcctEquity, double NetBalance, double MarginP){
   return ( UpdateAccounts(EnableDebug, AcctNumber, AcctBalance, AcctProfit, AcctEquity, NetBalance, MarginP) );
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//--- create timer
   EventSetTimer(RefreshInterval*60);
  
   // Run these the first time
   if( OracleConnect(OracleUserName, OraclePassword, OracleConnString) !=0){
      Print("Cannot connect to DB. Error: ",ret," .Exiting...");
      return -1;
   } else {
      ret=Sub_InsertHistory(); Print("Sub_InsertHistory() inserted ",ret," records.");
      ret=Sub_InsertOpenTrades(); Print("Sub_InsertOpenTrades() inserted ",ret," records.");
      ret=Sub_UpdateAccounts(); Print("Sub_UpdateAccounts() returned ", ret);
      return(INIT_SUCCEEDED);
   }
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
   if( OracleConnect(OracleUserName, OraclePassword, OracleConnString) !=0){
      Print("Cannot connect to DB. Error: ",ret," .Exiting...");
   } else {
      ret=Sub_InsertHistory(); Print("Sub_InsertHistory() inserted ",ret," records.");
      ret=Sub_InsertOpenTrades(); Print("Sub_InsertOpenTrades() inserted ",ret," records.");
      ret=Sub_UpdateAccounts(); Print("Sub_UpdateAccounts() returned ", ret);
   }
}
//----------------------------------------------------------
//    Insert History
//----------------------------------------------------------
int Sub_InsertHistory(){
// retrieving info from trade history
   int hstTotal=OrdersHistoryTotal();
   int IHCount=0;
   for(i=0; i<hstTotal; i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) {
         Print("Access to history failed with error (",GetLastError(),")");
         break;
       }
       IHCount++;
       ret=OracleInsertHistory (
                              AccountNumber(),
                              OrderTicket(),
                              TimeToStr(OrderOpenTime(), TIME_DATE) + " " + TimeToStr(OrderOpenTime(),TIME_SECONDS),
                              OrderType(),
                              OrderLots(),
                              OrderSymbol(),
                              OrderOpenPrice(),
                              OrderStopLoss(),
                              OrderTakeProfit(),
                              TimeToStr(OrderCloseTime(), TIME_DATE) + " " + TimeToStr(OrderCloseTime(),TIME_SECONDS),
                              OrderCloseTime(),
                              OrderClosePrice(),
                              OrderSwap(),
                              OrderProfit(),
                              OrderComment()
                              );
      if(ret!=0){
         Alert("OracleInsertHistory Failed. Error=",ret);
      }                      
   }
   return IHCount;
}
//----------------------------------------------------------
//    Insert Open Trades   
//----------------------------------------------------------
int Sub_InsertOpenTrades(){
   int total=OrdersTotal(); //Print("OrdersTotal()=",total);
   int IOTCount=0;
   for (i=total; i>0; i--){    
      if(OrderSelect(i-1,SELECT_BY_POS)==true){
         if(OrderType()==OP_BUY  || OrderType()==OP_SELL){
            IOTCount++;
            ret=OracleInsertOpenTrades(
                                    AccountNumber(),
                                    TimeToStr(TimeCurrent(), TIME_DATE) + " " + TimeToStr(TimeCurrent(),TIME_SECONDS),
                                    OrderTicket(),
                                    TimeToStr(OrderOpenTime(), TIME_DATE) + " " + TimeToStr(OrderOpenTime(),TIME_SECONDS),
                                    OrderType(),
                                    OrderLots(),
                                    OrderSymbol(),
                                    OrderOpenPrice(),
                                    OrderStopLoss(),
                                    OrderTakeProfit(),
                                    OrderSwap(),
                                    OrderProfit(),
                                    MarketInfo(OrderSymbol(),MODE_ASK),
                                    MarketInfo(OrderSymbol(),MODE_BID)
                                  );
            if(ret!=0){
               Alert("OracleInsertOpenTrades Failed. Error=",ret);
            }                      
         }
      }
   }   
   return IOTCount;
}
//----------------------------------------------------------
//    Update Accounts Table
//----------------------------------------------------------
int Sub_UpdateAccounts(){
   ret=OracleUpdateAccounts(
                           AccountNumber(),
                           AccountBalance(),
                           AccountProfit(),
                           AccountEquity(),
                           AccountBalance()+AccountProfit(),
                           AccountMargin()
                           );
   return ret;
}
