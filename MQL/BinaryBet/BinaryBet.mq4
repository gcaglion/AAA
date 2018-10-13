//+------------------------------------------------------------------+
//|                                                     Monetina.mq4 |
//|                                                         gcaglion |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      ""

#define defTP     10
#define defSL     10
#define defSize   2  // Percent
//#define defSizeAbs   160  // Fixed Size ($)
//#define TradeFreq 6  // Hours
#define defTradeLev 25
double pScale;
double BetSize;

//double defVol=0.04;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   MathSrand(TimeLocal());   
   if (StringSubstr(Symbol(),3,3)=="JPY"){pScale=100;} else {pScale=10000;}
   Print("Account Leverage=",AccountLeverage());
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
      static int SizeMultiplier;
      double SetPoint; double vTP; double vSL;
      int ticket;
      if(SizeMultiplier==0){SizeMultiplier=1;}
      if(FindOpenOrder(Symbol())==0){
         Print("LastClosedProfit()=",LastClosedProfit());
         if(LastClosedProfit()>0){
            SizeMultiplier=1;
         }
         else {
            SizeMultiplier=SizeMultiplier*2;
         }
         BetSize=SizeMultiplier*AccountBalance()*defSize/1000000;
         Print("AccountBalance=",AccountBalance()," ; SizeMultiplier=",SizeMultiplier," ; BetSize=",BetSize);
         //BetSize=200*SizeMultiplier/100000;
         //Print("random value ", MathRand());   
         //Print("pScale=",pScale,"; defTP=",defTP," ; defSL=",defSL," ; defSL/pScale=",defSL/pScale);
         if(MathRand()>(32768/2)){
            vSL=Bid+defSL/pScale; vTP=Bid-defTP/pScale;
            //Print("Bid=",Bid," ; vSL=",vSL," ; vTP=",vTP);
            Print("Calling OrderSend(",Symbol()," , OP_SELL , ",BetSize," , ",Bid," , 3 , ",vSL," , ",vTP,")");
            ticket=OrderSend(Symbol(),OP_SELL,BetSize,Bid,3,0,0,"Monetina",16384,0,Red);
         } else {
            vSL=Ask-defSL/pScale; vTP=Ask+defTP/pScale;
            //Print("Ask=",Ask," ; vSL=",vSL," ; vTP=",vTP);
            Print("Calling OrderSend(",Symbol()," , OP_BUY , ",BetSize," , ",Ask," , 3 , ",vSL," , ",vTP,")");
            ticket=OrderSend(Symbol(),OP_BUY ,BetSize,Ask,3,0,0,"Monetina",16384,0,Green);
         }
         if(ticket<0){
            Print("OrderSend failed with error #",GetLastError());
            return(0);
         } else{
            int ret=OrderModify(ticket,OrderOpenPrice(),vSL,vTP,0);
            //Print("OrderModify(",ticket,")=",ret);         
         }
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+


int FindOpenOrder(string oSymbol)
{
   int    os;
   int i; int total;
//--- number of current pending orders
   total=OrdersTotal();
   //Print("FindOrder:OrdersTotal()="+total);
   //Print("FindOrder: Look for ",oSymbol,"-",oSetPoint,"-",oTypei,"-",oVolume);
//--- go through orders in a loop
   for(i=0;i<total;i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         //OrderPrint();
         //Print("FindOrder(",i,"): ",OrderPrint());
         //if(!(OrderType()==OP_BUY || OrderType()==OP_SELL)) {
         //Print("FindOrder:oSetPoint="+oSetPoint+", OrderOpenPrice()="+OrderOpenPrice()+", oTypei="+oTypei+", OrderType()="+OrderType()+", oVolume="+oVolume+", OrderLots()="+OrderLots());
         if (OrderSymbol()==oSymbol){
            //Print("FindOpenOrder: returning OrderTicket="+OrderTicket());
            return (OrderTicket());
         }
      }
      else { Print( "FindOrder: Error when order select ", GetLastError()); break; }
      //}
   }
   //Print("FindOpenOrder: returning 0");
   return (0);
}

// return last closed ticket (returns -1 if not found)
int LastClosedTicket()
{
   datetime last_closed = 0;           // close time of last closed order
   int last_ticket = -1;               // ticket number of last closed order  
   
   // loop on all orders in history pool and filter
   for (int i=0; i<OrdersHistoryTotal(); i++) {  
      if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      //if (OrderMagicNumber() != MAGIC) continue;
      
      if (OrderType()<=1) {
         if (OrderCloseTime() > last_closed) {        // here we filter the last closed order
            last_closed = OrderCloseTime();           // save close time and ticket for next iteration
            last_ticket = OrderTicket();
         }
      }
   }
   
   return(last_ticket);
}

// return last closed profit (returns 0 if not found)
double LastClosedProfit()
{
   int last_ticket = LastClosedTicket();
   
   if (last_ticket > 0) {
      if (OrderSelect(last_ticket,SELECT_BY_TICKET,MODE_HISTORY))
         return(OrderProfit());
   }
   
   return(0.0);
}

