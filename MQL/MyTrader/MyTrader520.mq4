//+------------------------------------------------------------------+
//|                                                    MyTrader2.mq4 |
//|                                                         gcaglion |
//|                                                                  |
//+------------------------------------------------------------------+
/*
   Revision History
   5        SL Adjustment
   5.01     BugFix, SL Adjustment, incorrect ch value                      25/04/2013
   5.02     BugFix, pscale changes for all *JPY pairs, not only USDJPY     26/04/2013
   5.03     Moved Eps to global variable, to allow slippage tuning
   5.04     uses apScale[] as unique pScale for each pair
   5.10     Primers are now called Anchors; Anchors never Take Profit; StopLoss always 0; StopLoss are never changed
   5.11     New Pairs
   5.12     Pairs array Rationalization
   5.13     Fixed bugs on OrderModify(); added Alerts
   5.14     TradeSize is now expressed in lots; Added configurable UseAnchors; added CADJPY
   5.15     DefTradeSize is the same for all pairs, and it's externalized. Added NZDSGD
   5.16     Added USDZAR, EURAUD, GOLD
   5.20     Anchored Size; Added EURCHF
*/

#property copyright "gcaglion"
#property link      ""
#property show_inputs
double Expert_MagicNumber=150870;

//#define SLAdjLimit   3  // Move SL When trade is at (SLAdjLimit*PIPsPerStep) Pips from SL (3)
//#define SLAdjFactor  2  // Move SL by (SLAdjFactor*PIPsPerStep) Pips (2)
//int SLADjSize=50;       // PIPs

   int LevelRange=4;    // How many levels above and below current price should I keep open 
   //extern bool UseAnchors=true;
   extern double DefTradeSize=0.1;
   extern int MaxSizeMultiplier = 16;
   
#define NumChannels  22
string vSymbol[NumChannels]      = {"EURUSD", "NZDUSD", "USDCAD", "USDJPY","EURJPY", "GBPNZD", "NZDCHF", "EURGBP", "EURNOK", "GBPUSD", "USDCHF",   "EURCHF",   "AUDJPY",   "GBPCHF",   "CADJPY",   "NZDSGD",   "EURPLN",   "AUDUSD",   "USDZAR",   "EURAUD",   "GOLD",  "XAUUSD"};
double PIPSPerStep[NumChannels]  = {30,        20,       20,      20,      20,         40,      20,      20,       100,      30,		     20,          10,        20,       20,         20,         20,         100,         20,        30,          20,          30,      30    };
double CMin[NumChannels]         = {1.1900,    0.6615,   0.9400,  85.00,   92.00,      1.7700,  0.6390,  0.7780,   7.2500,   1.4800,		0.8550,     1.2100,    74.00,    1.3800,     87.00,      0.9290,     4.0200,     0.8235,     6.6000,     1.1600,     1150,    1150 };
double CMax[NumChannels]         = {1.5000,    0.8800,   1.0700,  115.00,  140.00,     2.2200,  0.8150,  0.9400,   8.2500,   1.6600,		1.0000,     1.2600,    105.00,   1.5500,     101.00,     1.0700,     4.4200,     1.0825,     11.900,     1.6000,     1950,    1950 };
int    apScale[NumChannels]      = {1,          1,       1,       100,     100,         1,      1,       1,        10,        1,		      1,           1,        100,     1,          100,        1,          1,            1,        1000,        1,           10,     10   };
//double DefTradeSize[NumChannels] = {0.1,       0.1,      0.1,     0.1,     0.1,        0.1,     0.1,     0.1,      0.1,      0.1,         0.1,       0.1,      0.1,      0.1,        0.1,        0.1,        0.1    };
   
//double AnchorAreaLimit[3]        = {20, 10, 0};
//int AnchorSizeMultiplier[3]      = {8,  16,  24};

   
int DefTradeLev=25;
int ret;
int pScale;
double gEpsilon=0.0003; // Price tolerance when checking Existing Orders

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  Print("Init(): Symbol()=",Symbol());
   Print("InitOrders(",Symbol(),") returns ",InitOrders(Symbol()));
   //Print("Lot Step=",MarketInfo(Symbol(),MODE_LOTSTEP));
   //Print("Min Lot=",MarketInfo(Symbol(),MODE_MINLOT));
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
int start(){
//----
   static int LastClosed;
   int ch;

   //Print("Tick:",Time[0]," - ",Symbol()," - Bid=",Bid," - Ask=",Ask," - Vol=",Volume);
   if (LastClosed==0) {LastClosed=FindLastClosed(Symbol());}
   //Print("LastClosed="+LastClosed+"; FindLastClosed("+Symbol()+")="+FindLastClosed(Symbol()));
   
   if (LastClosed != FindLastClosed(Symbol())){
      Print("Start: LastClosed=",LastClosed,";FindLastClosed(",Symbol(),")=",FindLastClosed(Symbol()),"; Calling Init() for ",Symbol());
      InitOrders(Symbol());   
      LastClosed=FindLastClosed(Symbol());
   }
  
   // Need to add an Anchor?
/*   if (UseAnchors) {
      for (ch=0; ch<NumChannels;ch++){
         for (int p=0;p<3;p++){
            //if(Symbol()=="USDJPY" && ch==3){Print(Symbol(),": ",Bid," - ",(CMax[ch]-Bid)/(CMax[ch]-CMin[ch]),",",AnchorAreaLimit[p]/100);}
            //Print("AnchorTradeId[",10*(ch+1)+p,"]=",AnchorTradeID[10*(ch+1)+p]);
            //Print(Symbol(),": ",Bid," - ",(CMax[ch]-Bid)/(CMax[ch]-CMin[ch]),",",AnchorAreaLimit[p]/100);
            if(Symbol()==vSymbol[ch] && !FindOpenAnchor(ch,p) && ((CMax[ch]-Bid)/(CMax[ch]-CMin[ch])) < (AnchorAreaLimit[p]/100)){
               Print("Calling NewOrder() from 1 with ",Symbol(),": ",Bid," - CMax[",ch,"]=",CMax[ch],"; CMax[ch]-CMin[ch]=",CMax[ch]-CMin[ch],"; AnchorAreaLimit[",p,"]/100=",AnchorAreaLimit[p]/100);
               //if (NewOrder(Symbol(), "SELL", Bid, 10000/DefTradeLev, PIPSPerStep[ch], DefTradeSize*AnchorSizeMultiplier[p], DefTradeLev,("Anchor "+(10*(ch+1)+p)))==-1){
               if (NewOrder(Symbol(), "SELL", Bid, 10000/DefTradeLev, 0, DefTradeSize*AnchorSizeMultiplier[p], DefTradeLev,("Anchor "+(10*(ch+1)+p)))==-1){
                  Print("Failed to place Anchor "+(10*(ch+1)+p));
               }
            }
            if(Symbol()==vSymbol[ch] && !FindOpenAnchor(ch,p+3) && ((Ask-CMin[ch])/(CMax[ch]-CMin[ch])) < (AnchorAreaLimit[p]/100)){
               Print("Calling NewOrder() from 2 with ",Symbol(),": ",Ask," - CMax[",ch,"]=",CMax[ch],"; CMax[ch]-CMin[ch]=",CMax[ch]-CMin[ch],"; AnchorAreaLimit[",p,"]/100=",AnchorAreaLimit[p]/100);
               //if(NewOrder(Symbol(), "BUY", Ask, 10000/DefTradeLev, PIPSPerStep[ch], DefTradeSize*AnchorSizeMultiplier[p], DefTradeLev,("Anchor "+(10*(ch+1)+p+3)))==-1){
               if(NewOrder(Symbol(), "BUY", Ask, 10000/DefTradeLev, 0, DefTradeSize*AnchorSizeMultiplier[p], DefTradeLev,("Anchor "+(10*(ch+1)+p+3)))==-1){
                  Print("Failed to place Anchor "+(10*(ch+1)+p+3));
               }
            }
         }
      }
   }  
 */
  /*
   // Need to Adjust SL?
   int total=OrdersTotal();
   //Print("OrdersTotal()=",OrdersTotal());
   int i; int j;
   for (i=total; i>0; i--){    
      if(OrderSelect(i-1,SELECT_BY_POS)==true){
         if(OrderSymbol()==Symbol()){
            //Print("AdjustSL: Symbol()=",Symbol()," ; OrderSymbol()=",OrderSymbol());
            //OrderPrint();
            //if(StringSubstr(OrderSymbol(),4,3)=="JPY" ){pScale=100;} else {pScale=1;}
            for(j=0; j<NumChannels; j++){
               if(OrderSymbol()==vSymbol[j]) ch=j;
            }
            pScale=apScale[ch];
            if(OrderType()==OP_BUY){
               //Print("BUY Order", OrderSymbol());
               //if(OrderSymbol()==Symbol()){Print("Bid=",Bid,"; SL=",OrderStopLoss(),"Bid-OrderStopLoss()=",Bid-OrderStopLoss()," - ", SLAdjLimit*PIPSPerStep[ch]/10000*pScale);}
               if(OrderStopLoss()!=0 && (Bid-OrderStopLoss())<(SLAdjLimit*PIPSPerStep[ch]/10000*pScale) ){
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-SLAdjFactor*PIPSPerStep[ch]/10000*pScale,OrderTakeProfit(),0)){
                     Print("Adjusted SL for BUY Trade ",OrderTicket());
                  }
                  else{
                     Print("Error ",GetLastError()," adjusting SL for BUY Trade ",OrderTicket(),")=",OrderTicket());
                  }
               }      
            }      
            if(OrderType()==OP_SELL){
               //if(OrderSymbol()==Symbol()){Print("Ask=",Ask,"; SL=",OrderStopLoss(),"OrderStopLoss()-Ask=",OrderStopLoss()-Ask," - ", SLAdjLimit*PIPSPerStep[ch]/10000*pScale);}
               //if(OrderSymbol()==Symbol()){Print("SLAdjLimit",SLAdjLimit,", ch=", ch, ",PIPSPerStep[ch]=", PIPSPerStep[ch], "PIPSPerStep[ch]/10000*pScale=",PIPSPerStep[ch]/10000*pScale);}

               if(OrderStopLoss()!=0 && (OrderStopLoss()-Ask)<(SLAdjLimit*PIPSPerStep[ch]/10000*pScale) ){
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+SLAdjFactor*PIPSPerStep[ch]/10000*pScale,OrderTakeProfit(),0)){
                     Print("Adjusted SL for SELL Trade ",OrderTicket());
                  }
                  else{
                     Print("Error ",GetLastError()," adjusting SL for SELL Trade ",OrderTicket());
                  }
               }
            }
         } // If OrderSymbol
      } // if OrderSelect
   }  // for i
  */ 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int NewOrder(string oSymbol, string oType, double oSetPoint, double oSL, double oTP, double oSize, int oLev, string oComment="Grid Standard Order"){
   int oTypei; int ticket;
   bool ret;
      //Print("NewOrder: called with ",oSymbol,"-",oType,"-",oSetPoint,"-",oSL,"-",oTP,"-",oSize,"-",oLev,"-",oScale);
      
      if(oType=="BUY"){
         if(oSetPoint<=Ask){
            oTypei=OP_BUYLIMIT;
         }
         else {
            oTypei=OP_BUYSTOP;
         }
         //oSL=oSetPoint-oSL/10000*pScale;
         oTP=oSetPoint+oTP/10000*pScale;
      }
      else{
         if(oSetPoint>=Bid){
            oTypei=OP_SELLLIMIT;
         }
         else {
            oTypei=OP_SELLSTOP;
         }
         //oSL=oSetPoint+oSL/10000*pScale;
         oTP=oSetPoint-oTP/10000*pScale;
      }
   //double oVolumei=oSize*AccountLeverage()/MarketInfo(oSymbol, MODE_LOTSIZE);
   double oVolumei=oSize;
   oSL=0;
   
   // Order Exists already?
   int OrdId=FindOrder(oSymbol,oSetPoint,oTypei, oVolumei);
   //Print("OrdId from FindOrder:"+OrdId);
   if (OrdId!=0)
   {
      //Print("Cannot place order. Order already there.");
      return (-1);
   }
   else
   {
      Print("Placing Order. Order NOT already there; Calling OrderSend(oSymbol=",oSymbol,", oTypei=",oTypei,", oVolumei=",oVolumei,", oSetPoint=",oSetPoint,", oSL=",oSL,", oTP=",oTP);
      //Print("Calling OrderSend(",oSymbol,",",oTypei,",",oSetPoint,",",oSL,",",oTP);
      ticket=OrderSend(oSymbol,oTypei,oVolumei,oSetPoint,3,oSL,oTP,oComment,16384,0,Green);      
      if(ticket>0)
        {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
        }
      else {
         int err=GetLastError();
         Print("Error opening order(oSymbol=",oSymbol,", oTypei=",oTypei,", oVolumei=",oVolumei,", oSetPoint=",oSetPoint,", oSL=",oSL,", oTP=",oTP,")=",err); 
         if(err==130){  // SetPoint too Close
            Print ("SetPoint too close; trying immediate execution; OrderType=",oTypei);
            if (oTypei==OP_SELLLIMIT || oTypei==OP_SELLSTOP){
               oTypei=OP_SELL;
            }
            else {
               oTypei=OP_BUY;
            }
            //oSL=0; oTP=0;
            ticket=OrderSend(oSymbol,oTypei,oVolumei,oSetPoint,3,0,0,oComment,16384,0,Green);      
            //Print("Ticket=",ticket);
            if(ticket==-1){
               Alert("Immediate Order (oSymbol=",oSymbol,", oTypei=",oTypei,", oVolumei=",oVolumei,", oSetPoint=",oSetPoint,", oSL=",oSL,", oTP=",oTP,") failed with error ",GetLastError());
               return (ticket);
            }
            if(!OrderModify(ticket,OrderOpenPrice(),oSL,oTP,0)){
               Alert("OrderModify(",ticket,") failed. Error=",GetLastError());
            } else{
               Print ("OrderModify(",ticket,") successful.");
            }
         } else {
            Alert("Error opening order(oSymbol=",oSymbol,", oTypei=",oTypei,", oVolumei=",oVolumei,", oSetPoint=",oSetPoint,", oSL=",oSL,", oTP=",oTP,")=",err); 
         }
          
      }     
   }
   return (ticket);
}


int FindOrder(string oSymbol, double oSetPoint,int oTypei, double oVolume)
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
         if (CompareDoubles(oSymbol, oSetPoint,OrderOpenPrice()) && CompareTypes(oTypei,OrderType()) && oVolume==OrderLots()){
            //Print("returning OrderTicket="+OrderTicket());
            return (OrderTicket());
         }
      }
      else { Print( "FindOrder: Error when order select ", GetLastError()); break; }
      //}
   }
   return (0);
}

bool CompareDoubles (string oSymbol, double A, double B) 
{
   double dff = A - B;
   double Eps;
   int c;
   
   
   for(int j=0; j<NumChannels; j++){
      if(oSymbol==vSymbol[j]) c=j;
   }
   Eps=gEpsilon*apScale[c];

   //if(StringSubstr(oSymbol,3,3)=="JPY"){Eps=gEpsilon*100;} else {Eps=gEpsilon;}
   //Print("dff=",dff,"; Eps*100000=",Eps*100000);
   //Print("c=",c," ; apScale[c]=",apScale[c]," , Eps*100000=",Eps*100000);
   //Print("A=",A,", B=",B,", dff=",dff,", Eps=",Eps);
   return (MathAbs(dff)<Eps);
}

bool CompareTypes (int t1, int t2){
   //Print("t1=",t1," , t2=",t2,". CompareTypes=",(t1%2 == t2%2));
   return (t1%2 == t2%2); 
}

int InitOrders(string pSymbol){
   
   // Init Orders
   //Print("InitOrders: Starting loop with pSymbol=",pSymbol);
   //for(int h=0;h<NumChannels; h++){Print("vSymbol[",h,"]=",vSymbol[h]);}
   int ch; double sp;
   double TradeSize; int mp;
   for(ch=0; ch<NumChannels; ch++){
      if(pSymbol==vSymbol[ch]){
         pScale=apScale[ch];
         //Print("pScale=",pScale);
         //if(StringSubstr(pSymbol,3,3)=="JPY"){pScale=100;} else {pScale=1;}
         //Print("InitOrders(",vSymbol," Started.");
         //Print("Tick:",Time[0]," - ",Symbol()," - Bid=",Bid," - Ask=",Ask," - Vol=",Volume);
         // Place Orders at Steps
         // First, choose size
         
         for(sp=CMin[ch]; sp<=CMax[ch]; sp=sp+PIPSPerStep[ch]/10000*pScale){
            if(MathAbs(sp-Ask)*10000/pScale<(LevelRange*PIPSPerStep[ch])){
               mp=1+(MaxSizeMultiplier-1)*(2*(0.5-MathAbs((sp-CMin[ch])/(CMax[ch]-CMin[ch])-0.5)));
               //Print("Ask=",Ask," CMin[ch]=",CMin[ch]," ;CMax[ch]=",CMax[ch]," ;sp=",sp," ;mp=",mp);
               TradeSize= DefTradeSize*mp;
               Print("TradeSize=",TradeSize);
               ret=NewOrder(vSymbol[ch], "BUY", sp, 10000/DefTradeLev, PIPSPerStep[ch], TradeSize, DefTradeLev);
               ret=NewOrder(vSymbol[ch], "SELL", sp, 10000/DefTradeLev, PIPSPerStep[ch], TradeSize, DefTradeLev);
            }
         }
      }
   }
   return(0);
}

int FindLastClosed (string vSymbol){
   for(int i=OrdersHistoryTotal()-1; i>=0; i--){
      //Print("FindLastClosed: i=",i);
      OrderSelect(i, SELECT_BY_POS,MODE_HISTORY);
      //OrderPrint();
      //Print("Selected Order SYmbol=",OrderSymbol());
      if(OrderSymbol()==vSymbol){
         return(OrderTicket());
      }
    }
    return(0);
}

bool FindOpenAnchor(int ch, int p){
   bool   result;
   int    cmd,total,i;
//----
   total=OrdersTotal();
//----
   //Print("OrdersTotal=",total);
   //Print("FindOpenAnchors(",ch,",",p,")");
   for (i=total; i>0; i--){    
      if(OrderSelect(i-1,SELECT_BY_POS)==true){
      //while (OrderSelect(1,SELECT_BY_POS,MODE_TRADES))
         //Print("Inside OrderSelect");
         cmd=OrderType();
         //---- open Anchor orders only are considered
         /*if(Symbol()==OrderSymbol() && (cmd==OP_BUY || cmd==OP_SELL)) {
            Print(Symbol(),"==",OrderSymbol(),"; ",cmd,"==",OP_BUY,"/",OP_SELL,"; ",OrderComment());
            Print((StringSubstr(OrderComment(),0,6)=="Anchor"),"-",(StrToInteger(StringSubstr(OrderComment(),7,1))==(ch+1)),"-",(StrToInteger(StringSubstr(OrderComment(),8,1))==p));
         }*/
         if(Symbol()==OrderSymbol() && (cmd==OP_BUY || cmd==OP_SELL) && StringSubstr(OrderComment(),0,6)=="Anchor" && StrToInteger(StringSubstr(OrderComment(),7,1))==(ch+1) && StrToInteger(StringSubstr(OrderComment(),8,1))==p){
            //Print("Inside Order Type");
            //---- delete first pending order
            //Print("FindOpenAnchor found ",OrderTicket()," having ",StringSubstr(OrderComment(),7,2));
            return(true);
        }
     }
  }
//----
   //Print("FindOpenAnchor returns FALSE");
  return(false);   
}