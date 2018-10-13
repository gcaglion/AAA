//+------------------------------------------------------------------+
//|                                                  DailySidney.mq4 |
//|                                       Copyright 2013, cucushanji |
//|                                    http://liberax.altervista.org |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, cucushanji"
#property link      "http://liberax.altervista.org"
#include <stdlib.mqh> 

//-- Extern Parameters
extern string v_0.3.0="--[ DailySidney ]----------------------------";
extern string c1="-- Copyright 2013, Cucushanji    ";
extern int        MagicBase				=	20000;
extern bool       DisplayInfoPanel		=	false;
extern bool       StealthMode			=	true;   //-- fake StopLoss= StopLoss + 20Pips
extern string t1="-- Trading Hours settings ---------------";
extern int        StartHour             =   0;
extern int        EndHour               =   23;
extern int        GMT_Shift             =   0;
extern string s0="-- OpenPrices settings ------------------";
extern int        ExaminedBars			=   24;		//-- Number of last bars to examine in High/Low finding
extern int		  SetupPeriod			=   24;		//-- In Hours indicate time interval betwen pending order placement
extern int        SetupStartHour		=   0;		//-- def start at midnight and examine last D1(1440) iHigh & iLow, change value if not GMT broker time     
extern int        High_step				=   2;		//-- (def 5) pips added to Last Day High to setup LongPRICE
extern int        Low_step				=   1;		//-- (def 5) pips sub to Last Day Low to setup ShortPRICE
extern string s1="-- TakeProfit settings ------------------";
extern double     TakeProfit 			=	100;	//-- (def 15) 
extern bool       Close_at_end_of_day   =   false;
       double     MinimumTakeProfit     =   20;     //-- if Close_at_end_of_day==True at end of day close position with profit < MinimumTakeProfit Pips
extern string s2="-- StopLoss management ------------------";
extern double     StopLoss				=	8;	    //-- (def 30) global StopLoss
extern double     BreakEven             =   3;
extern double     BreakEvenPips         =   2;
extern double     TrailingStop			=	3.1;      //-- TrailingStop in pips

extern string s3="-- MA close settings --------------------";
extern bool       Use_Ma_close          =   true;
extern bool       Ma_close_all          =   true;   //-- True=close all orders on MA retracement, False=close only loser orders
extern int		  MA_close_method       =   0;      //-- Moving Average Method: 0 SMA | 1 EMA | 2 SMMA | 3 LWMA
extern int		  MA_close_period       =   12;
extern int        MA_TimeFrame          =   60;     //-- 1 _ 5 _ 15 _ 30 _ 60 _ 240 _ 1440 ....
extern string s4="-- Risk management settings -------------";
extern double     Fixed_Lots			=	0;
extern double     MaximumRisk			=	0.01;
extern string s6="-- Other settings -----------------------";
extern int        Slippage				=   3;		//-- in base point
extern double     MaxSymbolSpread		=   2.5;    //-- max acceptable spread
extern int        MaxWaiting_sec		=   300;	//-- 30=30seconds | Wait 100ms x MaxWaiting_sec times, if TradeContextBusy/TradeNotAllowed

//+------------------------------------------------------------------------+

//-- Other Parameters -----------------------------------------------------+
double   High_price;
double   Low_price;
double   StopLoss_L;
double   StopLoss_S;
int 	 MagicNumber;
int      MyPoint;
datetime Time_0;
bool     VisualSpreadLevel = true; //-- Display coloured spread level if(DisplayInfoPanel)
double   stoplevel;
//+------------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   HideTestIndicators(false);
//---- Set MyPoint
   if(Digits==3||Digits==5) MyPoint=10; else MyPoint=1;      
//----   
   GlobalVariableSet("MaxWaiting_sec"+Symbol(),MaxWaiting_sec);
//----
   GlobalVariableSet("DailySidney_Slippage"+Symbol(),Slippage);
//----
   GlobalVariableSet("DailySidney_MyPoint"+Symbol(),MyPoint);   
//----
   if(GlobalVariableGet("DailySidney_firstrun"+Symbol())==0)
    {
      GlobalVariableSet("DailySidney_firstrun"+Symbol(),1);
      Time_0=0;
      if(!IsTesting())Print("<<< First run, Time_0= ",Time_0," >>>");
    }
//---- set MagicNumber
    MagicNumber = MagicBase + func_Symbol2Val(Symbol())*100 + func_TimeFrame_Const2Val(Period());
//---- set minimum StopLoss
    stoplevel=(MarketInfo(Symbol(),MODE_STOPLEVEL)/MyPoint)+0.1;
//----
//----
   return(0);
  }


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   if(!IsTesting())if(!IsTesting())Print("<<< EA expert deinitialization function called >>>");
//----
   GlobalVariableSet("DailySidney_firstrun"+Symbol(),0);
//----
   return(0);
  }


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//---- TradingDays setup
   if(DayOfWeek()==0 || DayOfWeek()==6) return(0);

//---- DisplayInfoPanel
   if(DisplayInfoPanel)
    {
	    SpreadVisualAlarm();
	    SupportResistace(1);
		PrintInfo();
	}
 
//---- Single OrdersTotal() cycle (trade management functions)
  for(int i=0;i<OrdersTotal();i++)
	{
	  OrderSelect(i,SELECT_BY_POS);	   
      if(OrderMagicNumber()!=MagicNumber && OrderSymbol()!=Symbol()) continue;
	  
	  //--- Begin Move stop  To BE -----------------------------------------
      if(BreakEven>0)
	  {
			MoveStopAtBreakEven();    
	  } 
	        
      //--- Begin TrailingStop ---------------------------------------------
      if(TrailingStop>0)
      {
			TrailingStop();
	  }
      
      //---- Begin StealthMode ---------------------------------------------
      if(StealthMode)
      {
			StealthClose();
      }  
      
      //---- Begin close on Ma signal --------------------------------------
			CloseOnMaSignal();
      
      //---- Begin close @ end of day --------------------------------------
      if(Close_at_end_of_day)
      {
			CloseAtEndOfDay();  
	  }  
      
    }//---- for cycle (orders scroll)

 //----
 if(NewPeriod()==1 && DayOfWeek()!=1)
 {
    //---- PriceSetupCondition ---------------------------------------------
	if( PriceSetupCondition() )
	{
 
	  //---- set OpenPrice for LONG ----------------------------------------
	  High_price = NormalizeDouble(High[iHighest(NULL,0,MODE_HIGH,ExaminedBars+1,1)] + High_step*Point*MyPoint, Digits);   
	  //----
	  int emergency_step_long=10;
	  if(High_price<Ask+2*Point*MyPoint){High_price=Ask+emergency_step_long*Point*MyPoint; Print("<<< Price High is closer to Ask ! >>>");}
      //---- print price
      if(!IsTesting())Print("<<< Price for long= ",High_price, "  >>>");

      //---- set OpenPrice for SHORT ---------------------------------------
	  Low_price = NormalizeDouble(Low[iLowest(NULL,0,MODE_LOW,ExaminedBars+1,1)] - Low_step*Point*MyPoint, Digits);		  
	  //----
	  int emergecy_step_short=10;
	  if(Low_price>Bid-2*Point*MyPoint){Low_price=Bid-emergecy_step_short*Point*MyPoint; Print("<<< Price Low is closer to Bid ! >>>");}
	  //---- print price
	  if(!IsTesting())Print("<<< Price for short= ",Low_price, " >>>");
		  
	  //---- time flag 
	  Time_0=TimeCurrent(); 
	  if(!IsTesting())Print("<<< reinit Time_0= ",Time_0," >>>");     
	  
	  //---- draw target price
	  if(DisplayInfoPanel)
	  {
	    drawLine(High_price, "High_price", Magenta,  1);
	    drawLine(Low_price,  "Low_price",  Magenta, 1);
	  }
	  
	}//if PriceSetupCondition()   
  
	//---- first run flag
	if(GlobalVariableGet("DailySidney_firstrun"+Symbol())==1)GlobalVariableSet("DailySidney_firstrun"+Symbol(),2);
	
 }//if NewPeriod()==1

//----

//---- Send OP_BUY ---------------------------------------------------------
RefreshRates();
double long_price=Ask;
if(long_price >= High_price && long_price < High_price + (High_price*0.001) &&
   long_price > MA(MA_TimeFrame, MA_close_period) &&
   Hour()>=StartHour-GMT_Shift && Hour()<EndHour-GMT_Shift &&
   SpreadLimit() &&
   StrategyOrdersTotal(MagicNumber)==0)
{
   Send_Long( MagicNumber, long_price, StopLoss, TakeProfit, StealthMode);
   High_price=999999;
}

//---- Send OP_SHORT -------------------------------------------------------
RefreshRates();
double short_price=Bid;
if(short_price <= Low_price && short_price > Low_price - (Low_price*0.001) && 
   short_price < MA(MA_TimeFrame, MA_close_period) &&
   Hour()>=StartHour-GMT_Shift && Hour()<EndHour-GMT_Shift &&
   SpreadLimit() &&
   StrategyOrdersTotal(MagicNumber)==0)
{
   Send_Short( MagicNumber, short_price, StopLoss, TakeProfit, StealthMode);
   Low_price=0.00000;
}

return(0);
}
//+------------------------------------------------------------------+


//
//+------------------------------------------------------------------+
//--- Custom functions begin ----------------------------------------+
//
	


//+--------------------------------- PriceSetupCondition ---------+	
bool PriceSetupCondition()
{

  if(Period()==60 && Hour()==SetupStartHour && Minute()>1) // add other filter here if needed
  {
    return(true);
  }
 
  if(Period()!=60 && Hour()>=SetupStartHour && Minute()>1) // add other filter here if needed
  {
    return(true);
  }

}
//+------------------------------------------------------------------+	




//+------------------------------------------------------------------+
//|Wait_For_Market()                                                 |
//+------------------------------------------------------------------+
/**
 * @brief 
 * sleep 1000ms until !IsTradeContextBusy() or IsTradeAllowed()
 * 
 * @param MaxWaiting_sec
 */
// Based on:
//
//+------------------------------------------------------------------+
//|                                                                  |
//|                                  TradeContext.mq4 for Doug by CB |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
//#property copyright "komposter"
//#property link      "komposterius@mail.ru"
/////////////////////////////////////////////////////////////////////////////////
// int _IsTradeAllowed( int MaxWaiting_sec = 30 )
//
// the function checks the trade context status. Return codes:
//  1 - trade context is free, trade allowed
//  0 - trade context was busy, but became free. Trade is allowed only after 
//      the market info has been refreshed.
// -1 - trade context is busy, waiting interrupted by the user (expert was removed from 
//      the chart, terminal was shut down, the chart period and/or symbol was changed, etc.)
// -2 - trade context is busy, the waiting limit is reached (MaxWaiting_sec). 
//      Possibly, the expert is not allowed to trade (checkbox "Allow live trading" 
//      in the expert settings).
//
// MaxWaiting_sec - time (in seconds) within which the function will wait 
// until the trade context is free (if it is busy). By default,30.
/////////////////////////////////////////////////////////////////////////////////
int Wait_For_Market(int MaxWaiting_sec)
{
 //----  

    // check whether the trade context is free
    if(!IsTradeAllowed())
    {
        int StartWaitingTime = GetTickCount();
        if(!IsTesting())Print("<<< Trade context is busy! Wait until it is free... >>>");
        // infinite loop
        while(true)
        {
            // if the expert was terminated by the user, stop operation
            if(IsStopped()) 
            { 
                if(!IsTesting())Print("<<< DailiSidney was terminated by the user! >>>"); 
                return(-1); 
            }
            // if the waiting time exceeds the time specified in the 
            // MaxWaiting_sec variable, stop operation, as well
            if(GetTickCount() - StartWaitingTime > MaxWaiting_sec * 1000)
            {
                if(!IsTesting())Print("<<< The waiting limit exceeded (" + MaxWaiting_sec + " ???.)! >>>");
                return(-2);
            }
            // if the trade context has become free,
            if(IsTradeAllowed())
            {
                if(!IsTesting())Print("<<< Trade context has become free! >>>");
                return(0);
            }
             // if no loop breaking condition has been met, "wait" for 0.1 
             //second and then restart checking            
             RefreshRates();
             Sleep(100);
        }
    }
    else
    {
        if(!IsTesting())Print("<<< Trade context is free! >>>");
        return(1);
    }
}
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| NewPeriod                                                        |
//+------------------------------------------------------------------+
int NewPeriod(){
//----

//----
	int NewPeriod=0;                                           
    int Time_1 = TimeCurrent();
    if( Time_1 - Time_0 >= SetupPeriod*3600 )
    {
      NewPeriod = 1; 
      return(NewPeriod); 
    }
//----    
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| LotsOptimized()                                                  |
//+------------------------------------------------------------------+
/**
 * @brief define lot size
 * @returns lot
 * 
 * 
 */
double LotsOptimized()
{
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(Fixed_Lots>0)maxlot=Fixed_Lots;
   //----	   
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double lot=minlot;
   //----
   int    lotsdigit=0;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01) lotsdigit=2;
   else   lotsdigit=1;
   
   //---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,lotsdigit);
   
   //---- static settings
   if(minlot==0.01 && lot<0.01) lot=0.01;
   if(minlot==0.1 && lot<0.1) lot=0.1;
   if(lot>maxlot) lot=maxlot;
   
   return(lot);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| PrintInfo()                                                      |
//+------------------------------------------------------------------+
/**
 * @brief display some stuff on the graph
 * 
 * 
 */
void PrintInfo() 
{ 
   //----
     int MyPoint=GlobalVariableGet("DailySidney_MyPoint"+Symbol());
   //---- 
     int lotsdigit; 
   //----
     if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01) lotsdigit=2;
     else lotsdigit=1;
   //----
     double Spread=NormalizeDouble( (MarketInfo(Symbol(),MODE_SPREAD)/MyPoint) ,2);
   //----
     string cmt="";
   //---- populate cmt
     cmt = "=====[ "+WindowExpertName()+" ]====";
     if(!IsDemo())cmt =  cmt + "\nAccount Name: [ " + AccountName() + " ]";            
     cmt =  cmt + "\nAccount Leverage: [ 1:" + DoubleToStr( AccountLeverage(), 0 ) + " ]";      
     if(MaximumRisk>0){
		 cmt =  cmt + "\nDailySidney Lot: [ " + DoubleToStr( LotsOptimized(), 2 ) + " ]";      
     }
     else cmt =  cmt + "\nDailySidney Lot: [ " + Fixed_Lots + " ]";      
     cmt =  cmt + "\nMin Lot: [ " + DoubleToStr( MarketInfo(Symbol(),MODE_MINLOT), 2 ) + " ]";      
     cmt =  cmt + "\nMax Lot: [ " + DoubleToStr( MarketInfo(Symbol(),MODE_MAXLOT), 2 ) + " ]";      
     cmt =  cmt + "\nLot Step: [ " + DoubleToStr( MarketInfo(Symbol(),MODE_LOTSTEP), 2 ) + " ]";      
     cmt =  cmt + "\nCurrent Profit: [ " + DoubleToStr(AccountEquity()-AccountBalance(),2) + " ]";
     cmt =  cmt + "\nAccount Balance: [ " + DoubleToStr(AccountBalance(),2) + " ]";
     cmt =  cmt + "\nAccount Equity: [ " + DoubleToStr(AccountEquity(),2) + " ]";      
     cmt =  cmt + "\nServer Time: "+TimeToStr(TimeCurrent(),TIME_MINUTES);
     cmt =  cmt + "\nLocal Time   "+TimeToStr(TimeLocal(),TIME_MINUTES);
     cmt =  cmt + "\n==================";

   //---- display cmt on chart
   Comment(cmt);

   //-- Profit signal
   if (AccountProfit()>0)
   {
	  ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0);  
	  ObjectSetText("Profit", "Profit "+DoubleToStr(AccountProfit(),2)+" "+AccountCurrency(	), 14, "Arial", Chartreuse); 
	  ObjectSet("Profit", OBJPROP_CORNER,    1);
	  ObjectSet("Profit", OBJPROP_XDISTANCE, 10);
	  ObjectSet("Profit", OBJPROP_YDISTANCE, 48);
	  WindowRedraw();  
   }  else ObjectDelete("Profit");
      
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//+ SpreadVisualAlarm()                                              +
//+------------------------------------------------------------------+
void SpreadVisualAlarm()
{
  double Spread=NormalizeDouble( (MarketInfo(Symbol(),MODE_SPREAD)/MyPoint) ,2);
  color spread_color;
  //----
  if(Spread <= 0.2)spread_color=PaleGreen;
  if(Spread > 0.2 && Spread <= 0.5)spread_color=Lime;
  if(Spread > 0.5 && Spread <= 0.9)spread_color=LimeGreen;
  if(Spread > 0.9 && Spread <= 1.5)spread_color=Yellow;
  if(Spread > 1.5 && Spread <= 2.0)spread_color=Gold;
  if(Spread > 2.0 && Spread <= 2.5)spread_color=Orange;
  if(Spread > 2.5 )spread_color=Tomato;
  //----
  if( VisualSpreadLevel )
  {
      ObjectCreate("Spread", OBJ_LABEL, 0, 0, 0);  
	  ObjectSetText("Spread", "Spread "+DoubleToStr(Spread,2)+" / "+DoubleToStr(MaxSymbolSpread,2)+" Pips", 14, "Arial", spread_color); 
	  ObjectSet("Spread", OBJPROP_CORNER,    1);
	  ObjectSet("Spread", OBJPROP_XDISTANCE, 10);
	  ObjectSet("Spread", OBJPROP_YDISTANCE, 24);
	  WindowRedraw();
  }   else ObjectDelete("Spread");


      ObjectCreate("EAname", OBJ_LABEL, 0, 0, 0);  
	  ObjectSetText("EAname", WindowExpertName() , 14, "Arial", Lime); 
	  ObjectSet("EAname", OBJPROP_CORNER,    2);
	  ObjectSet("EAname", OBJPROP_XDISTANCE, 10);
	  ObjectSet("EAname", OBJPROP_YDISTANCE, 24);
	  

}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| TrailingStop()                                                   |
//+------------------------------------------------------------------+
bool TrailingStop() 
{     
     switch(OrderType())
     {
       case OP_BUY: if(TrailingStop>0 )  
		            {                 
		               if(Bid-OrderOpenPrice()>Point*MyPoint*TrailingStop)
		               {
		                  if(OrderStopLoss()<Bid-Point*MyPoint*TrailingStop || OrderStopLoss()==0)
		                  {
		                     bool trail_l;
		                     trail_l=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*MyPoint*TrailingStop, Digits),OrderTakeProfit(),0,Green);
		                     if(trail_l)return(true); 
		                     else {if(GetLastError()!=1)return(false);}
		                  } 
		               }
		            }
     
       
       case OP_SELL: if(TrailingStop>0)  
		             {                 
		               if(OrderOpenPrice()-Ask > Point*MyPoint*TrailingStop)
		               {
		                  if(OrderStopLoss() > Ask+Point*MyPoint*TrailingStop || OrderStopLoss()==0)
		                  {
		                     bool trail_s;
		                     trail_s=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*MyPoint*TrailingStop, Digits),OrderTakeProfit(),0,Red);
		                     if(trail_s)return(true); 
		                     else {if(GetLastError()!=1)return(false);}
		                  }
		               }
		             }
	                  
       default: break;
     }   

return(true);
}
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| SupportResistace()                                               |
//+------------------------------------------------------------------+  
bool SupportResistace(bool Display_VisualObjects) {
   double barvalue[1][6];
   double close;
   double high;
   double low;
      
   ArrayCopyRates(barvalue, Symbol(), PERIOD_D1);
   if (DayOfWeek() == 1) 
   {
      if (TimeDayOfWeek(iTime(Symbol(), PERIOD_D1, 1)) == 5) 
      {
         close = barvalue[1][4];
         high = barvalue[1][3];
         low = barvalue[1][2];
      } 
      else 
      {
         for (int j = 5; j >= 0; j--) 
         {
            if (TimeDayOfWeek(iTime(Symbol(), PERIOD_D1, j)) == 5) 
            {
               close = barvalue[j][4];
               high  = barvalue[j][3];
               low   = barvalue[j][2];
            }
         }
      }
   } 
   else 
   {
      close = barvalue[1][4];
      high  = barvalue[1][3];
      low  = barvalue[1][2];
   }
   
   if(Display_VisualObjects)
   {
       double rangehl = high - low;
       double pivot = (high + low + close) / 3.0;
       double R3 = pivot + 1.0 * rangehl;
       double R2 = pivot + 0.618 * rangehl;
       double R1 = pivot + rangehl / 2.0;
       double S1 = pivot - rangehl / 2.0;
       double S2 = pivot - 0.618 * rangehl;
       double S3 = pivot - 1.0 * rangehl;
     
	   //----   R3
		   drawLine(R3, "R3", DeepSkyBlue, 0);
       //----   R2
		   drawLine(R2, "R2", Lime, 0);		
	   //----   R1
		   drawLine(R1, "R1", Tomato, 0);
       //----   pivot
		   drawLine(pivot, "pivot", Yellow, 0);			   
	   //----   S3
		   drawLine(S3, "S3", DeepSkyBlue, 0);
       //----   S2
		   drawLine(S2, "S2", Lime, 0);		
	   //----   S1
		   drawLine(S1, "S1", Tomato, 0);
	   //----	   
   }
}  
//+------------------------------------------------------------------+


 
//+------------------------------------------------------------------+
//| drawLine()                                                       |
//+------------------------------------------------------------------+   
void drawLine(double priceline, string drawline, color colorline, int ai_20) {
   if (ObjectFind(drawline) != 0) 
   {
      ObjectCreate(drawline, OBJ_HLINE, 0, Time[0], priceline, Time[0], priceline);
      if (ai_20 == 1) ObjectSet(drawline, OBJPROP_STYLE, STYLE_SOLID);
      else ObjectSet(drawline, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(drawline, OBJPROP_COLOR, colorline);
      ObjectSet(drawline, OBJPROP_WIDTH, 1);
      return;
   }
   ObjectDelete(drawline);
   ObjectCreate(drawline, OBJ_HLINE, 0, Time[0], priceline, Time[0], priceline);
   if (ai_20 == 1) ObjectSet(drawline, OBJPROP_STYLE, STYLE_SOLID);
   else ObjectSet(drawline, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(drawline, OBJPROP_COLOR, colorline);
   ObjectSet(drawline, OBJPROP_WIDTH, 1);
} 

//+------------------------------------------------------------------+
//+ SpreadLimit()                                                    +
//+------------------------------------------------------------------+
bool SpreadLimit()
{
  double Spread=NormalizeDouble( (MarketInfo(Symbol(),MODE_SPREAD)/MyPoint) ,2);
  
  if(Spread>=MaxSymbolSpread){ return(false); }
  else return(true);
  
}





//+------------------------------------------------------------------+
//| Symbol appropriation  function                                   |
//+------------------------------------------------------------------+
int func_Symbol2Val(string symbol)
{
   string mySymbol = StringSubstr(symbol,0,6);
   
	if(mySymbol=="AUDCAD") return(1);
	if(mySymbol=="AUDJPY") return(2);
	if(mySymbol=="AUDNZD") return(3);
	if(mySymbol=="AUDUSD") return(4);
	if(mySymbol=="CHFJPY") return(5);
	if(mySymbol=="EURAUD") return(6);
	if(mySymbol=="EURCAD") return(7);
	if(mySymbol=="EURCHF") return(8);
	if(mySymbol=="EURGBP") return(9);
	if(mySymbol=="EURJPY") return(10);
	if(mySymbol=="EURUSD") return(11);
	if(mySymbol=="GBPCHF") return(12);
	if(mySymbol=="GBPJPY") return(13);
	if(mySymbol=="GBPUSD") return(14);
	if(mySymbol=="NZDJPY") return(15);
	if(mySymbol=="NZDUSD") return(16);
	if(mySymbol=="USDCAD") return(17);
	if(mySymbol=="USDCHF") return(18);
	if(mySymbol=="USDJPY") return(19);
   Comment("unexpected Symbol");
	return(999);
}

//+------------------------------------------------------------------+
//| Time frame interval appropriation  function                      |
//+------------------------------------------------------------------+
int func_TimeFrame_Const2Val(int Constant ) 
{
   switch(Constant) 
   {
      case 1:     // M1
         return(1);
      case 5:     // M5
         return(2);
      case 15:    //M15
         return(3);
      case 30:    //M30
         return(4);
      case 60:    //H1
         return(5);
      case 240:   //H4
         return(6);
      case 1440:  //D1
         return(7);
      case 10080: //W1
         return(8);
      case 43200: //MN1
         return(9);
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Send_Long  			                                             |
//+------------------------------------------------------------------+
/**
 * @brief open long order
 * @param MagicNumber 
 * @param StopLoss 
 * @param StrategyLotFactor
 * @returns 
 * 
 * 
 */
   int Send_Long(int MagicNumber, double price, double StopLoss, double TakeProfit, bool StealthMode){

   //----
     int MySlippage=GlobalVariableGet("DailySidney_Slippage"+Symbol());
   //----
     int MyPoint=GlobalVariableGet("DailySidney_MyPoint"+Symbol());
   //----
   double Spread=NormalizeDouble( (MarketInfo(Symbol(),MODE_SPREAD)/MyPoint) ,2);
   string OrderCMT="DailySidney: "+MagicNumber +" "+DoubleToStr(Spread,1)+" "+Symbol(); 
 
   // set lot size
   double lotti=LotsOptimized();
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(lotti<minlot) lotti=minlot;
   if(lotti>maxlot) lotti=maxlot;
   int MaxWaiting_sec=GlobalVariableGet("MaxWaiting_sec"+Symbol());
 
   double SL=0;
      
//----

//----  
      int n;
      int strategy_orders=StrategyOrdersTotal(MagicNumber);
      while(strategy_orders == StrategyOrdersTotal(MagicNumber))
	  {
	      if(Wait_For_Market(MaxWaiting_sec)==1)
	      {
	         n++; Print("OrderSend() [ ", n, " ]");
	         int TicketB = OrderSend(Symbol(),OP_BUY,lotti,NormalizeDouble(Ask, Digits),MySlippage,0,0,OrderCMT,MagicNumber,0,Blue);
	      }
	      if(TicketB > 0 )
	      {
	         // set fake StopLoss
             if(StealthMode)SL=NormalizeDouble(Bid-((StopLoss+20)*Point*MyPoint),Digits);
             // otherwise set real StopLoss
             if(!StealthMode)SL=NormalizeDouble(Bid-(StopLoss*Point*MyPoint),Digits);	
	         OrderSelect(TicketB,SELECT_BY_TICKET);
	         if(OrderStopLoss()==0)
	         {
	            OrderModify(OrderTicket(),lotti,NormalizeDouble(SL, Digits),NormalizeDouble(Ask+TakeProfit*Point*MyPoint, Digits),0,Blue);
		     }
             strategy_orders=StrategyOrdersTotal(MagicNumber);
	         return;
	      }
	      else
	      {
	         int lasterror=GetLastError();
	         Print( "Error OrderSend OP_BUY -- ", OrderCMT," - ", ErrorDescription(lasterror) );
	         if(lasterror==148)return;
	         if(n>=1000)return;
	         Sleep(300);
	      }  
       }
}//----
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Send_Short  			                                         |
//+------------------------------------------------------------------+
/**
 * @brief open short order
 * @param MagicNumber 
 * @param StopLoss 
 * @param StrategyLotFactor
 * @returns 
 * 
 * 
 */
   int Send_Short(int MagicNumber, double price, double StopLoss, double TakeProfit, bool StealthMode){
   //----
     int MySlippage=GlobalVariableGet("DailySidney_Slippage"+Symbol());
   //----
     int MyPoint=GlobalVariableGet("DailySidney_MyPoint"+Symbol());
   //----
   double Spread=NormalizeDouble( (MarketInfo(Symbol(),MODE_SPREAD)/MyPoint) ,2);
   string OrderCMT="DailySidney: "+MagicNumber +" "+DoubleToStr(Spread,1)+" "+Symbol(); 
 
   // set lot size
   double lotti=LotsOptimized();
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(lotti<minlot) lotti=minlot;
   if(lotti>maxlot) lotti=maxlot;
   int MaxWaiting_sec=GlobalVariableGet("MaxWaiting_sec"+Symbol());
   
   double SL=0;
   	
//----
      int n;
      int strategy_orders=StrategyOrdersTotal(MagicNumber);
      while(strategy_orders == StrategyOrdersTotal(MagicNumber))
	  {
	      if(Wait_For_Market(MaxWaiting_sec)==1)
	      {
	         n++; Print("OrderSend() [ ", n, " ]");
	         int TicketS = OrderSend(Symbol(),OP_SELL,lotti,NormalizeDouble(Bid, Digits),MySlippage,0,0,OrderCMT,MagicNumber,0,Red);
	      }
	      if(TicketS > 0)
	        {
             // set fake StopLoss
             if(StealthMode)SL=NormalizeDouble(Ask+((StopLoss+20)*Point*MyPoint),Digits);
             // otherwise set real StopLoss
             if(!StealthMode)SL=NormalizeDouble(Ask+(StopLoss*Point*MyPoint),Digits);
	         OrderSelect(TicketS,SELECT_BY_TICKET);
	         if(OrderStopLoss()==0)
	         {
	            OrderModify(OrderTicket(),lotti,NormalizeDouble(SL, Digits),NormalizeDouble(Bid-TakeProfit*Point*MyPoint, Digits),0,Red);
	         }
	         strategy_orders=StrategyOrdersTotal(MagicNumber);
	         return;
	        }
	        else
	        {
	         int lasterror=GetLastError();
	         Print( "Error OrderSend OP_SELL -- ", OrderCMT," - ", ErrorDescription(lasterror) );
	         if(lasterror==148)return;
	         if(n>=1000)return;
	         Sleep(300);
	        } 
	  }
}//----
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| StrategyOrdersTotal()   
//+------------------------------------------------------------------+
/**
 * @brief returns orders
 * @param MagicNumber 
 * @returns ordini
 * 
 * 
 */
int StrategyOrdersTotal(int MagicNumber)
{
   int ordini=0;
   for(int i=0;i<OrdersTotal();i++)
   {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if(OrderMagicNumber()!=MagicNumber) continue;
     switch(OrderType())
     {
       //----
       case OP_BUY: if(OrderMagicNumber()==MagicNumber && OrderStopLoss()<OrderOpenPrice() )ordini++;
       case OP_SELL:if(OrderMagicNumber()==MagicNumber && OrderStopLoss()>OrderOpenPrice() )ordini++;
       default: break;
     }
   }
   //----
   return(ordini);
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| MA(int TimeFrame, MA_close_period)   
//+------------------------------------------------------------------+
//---- 
double MA(int TimeFrame, int MA_close_period)
{
	return( iMA(NULL,TimeFrame,MA_close_period,0,MA_close_method,PRICE_OPEN,0) );
	
}	
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| CloseAtEndOfDay()  
//+------------------------------------------------------------------+
void CloseAtEndOfDay()
{
          bool is_closed_d;
          //---- Close BUY @ end of day
	      if( OrderType()==OP_BUY && OrderProfit()>0 && 
	          Bid <= OrderOpenPrice()+MinimumTakeProfit*Point*MyPoint &&
	          TimeCurrent()-OrderOpenTime()>(1*3600) &&
	          Hour()==23-GMT_Shift && Minute()>=55)     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_d=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Aqua);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_d=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Aqua);
	          } 
	          if(!is_closed_d)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	       
	      //---- Close SELL @ end of day
	      if( OrderType()==OP_SELL && OrderProfit()>0 && 
	          Ask >= OrderOpenPrice()-MinimumTakeProfit*Point*MyPoint &&
	          TimeCurrent()-OrderOpenTime()>(1*3600) &&
	          Hour()==23-GMT_Shift && Minute()>=55)     
	      {
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_d=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Aqua);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_d=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Aqua);
		      }
	          if(!is_closed_d)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| MoveStopAtBreakEven()  
//+------------------------------------------------------------------+
void MoveStopAtBreakEven()
{
          bool is_modified;
          RefreshRates();
	      if( OrderType()==OP_BUY && 
	          Bid >= OrderOpenPrice()+BreakEven*Point*MyPoint &&
	          OrderStopLoss() < OrderOpenPrice() )     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_modified=OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+BreakEvenPips*Point*MyPoint, OrderTakeProfit(), 0);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_modified=OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+BreakEvenPips*Point*MyPoint, OrderTakeProfit(), 0);
	          } 
	          if(!is_modified)Alert("ERROR on OrderModify()  TICKET= ",OrderTicket());
	      }	    	      
	      if( OrderType()==OP_SELL &&
	          Ask <= OrderOpenPrice()-BreakEven*Point*MyPoint &&
	          OrderStopLoss() > OrderOpenPrice() )     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_modified=OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BreakEvenPips*Point*MyPoint, OrderTakeProfit(), 0);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_modified=OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-BreakEvenPips*Point*MyPoint, OrderTakeProfit(), 0);
	          } 
	          if(!is_modified)Alert("ERROR on OrderModify()  TICKET= ",OrderTicket());
	      }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CloseOnMaSignal()  
//+------------------------------------------------------------------+
void CloseOnMaSignal() 
{
RefreshRates();
if(Use_Ma_close && Ma_close_all)
      {
	      bool is_closed_m;
          //---- Close BUY on  MA signal
	      if( OrderType()==OP_BUY && Bid <= MA(MA_TimeFrame, MA_close_period) )     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_m=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Lime);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_m=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Lime);
	          } 
	          if(!is_closed_m)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	      
	      //---- Close SELL on MA signal
	      if( OrderType()==OP_SELL && Ask >= MA(MA_TimeFrame, MA_close_period) )     
	      {
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_m=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Lime);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_m=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Lime);
		      }
	          if(!is_closed_m)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	  
	  }
      if(Use_Ma_close && !Ma_close_all)  // close only negative
      {
	      bool is_closed_mn;
          //---- Close BUY on  MA signal
	      if( OrderType()==OP_BUY && OrderProfit()<0 && Bid <= MA(MA_TimeFrame, MA_close_period) )     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_mn=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Lime);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_mn=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Lime);
	          } 
	          if(!is_closed_mn)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	      
	      //---- Close SELL on MA signal
	      if( OrderType()==OP_SELL && OrderProfit()<0 && Ask >= MA(MA_TimeFrame, MA_close_period) )     
	      {
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed_mn=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Lime);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed_mn=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Lime);
		      }
	          if(!is_closed_mn)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	  
	  }

}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| StealthClose()  
//+------------------------------------------------------------------+
void StealthClose()
{
          RefreshRates();
          
          bool is_closed;
	      //---- Close BUY on SL
	      if(OrderType()==OP_BUY && ( Bid <= OrderOpenPrice()-StopLoss*Point*MyPoint) )     
	      {           
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Magenta);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 0, Magenta);
	          } 
	          if(!is_closed)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }
	      //---- Close SELL on SL
	      if(OrderType()==OP_SELL && ( Ask >= OrderOpenPrice()+StopLoss*Point*MyPoint) )     
	      {
	          if(Wait_For_Market(MaxWaiting_sec)==1)is_closed=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Magenta);
	          else
	          while(Wait_For_Market(MaxWaiting_sec)!=1)
	          {
	                is_closed=OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 0, Magenta);
		      }
	          if(!is_closed)Alert("ERROR on OrderClose()  TICKET= ",OrderTicket());
	      }	
	
}	
//+------------------------------------------------------------------+



//--- Custom functions end ------------------------------------------+
//+------------------------------------------------------------------+
