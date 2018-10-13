//+------------------------------------------------------------------+
//|                                                       Levels.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

#define NumChannels  14
#property show_inputs
extern bool RemoveOnly;

int start()
  {
//----
string vSymbol[NumChannels]      = {"EURUSD", "NZDUSD", "USDCAD", "USDJPY","EURJPY", "GBPNZD", "NZDCHF", "EURGBP", "EURNOK", "GBPUSD", "USDCHF",   "AUDJPY",   "GBPCHF",   "CADJPY"};
double PIPSPerStep[NumChannels]  = {30,        20,       20,      20,      20,         40,      20,      20,       100,      30,		     20,          20,       20,         20     };
double CMin[NumChannels]         = {1.1900,    0.6615,   0.9400,  85.00,   92.00,      1.7700,  0.6390,  0.7780,   7.2500,   1.4800,		0.8550,     74.00,    1.3800,     87.00  };
double CMax[NumChannels]         = {1.5000,    0.8800,   1.0700,  115.00,  140.00,     2.2200,  0.8150,  0.9400,   8.2500,   1.6600,		1.0000,     105.00,   1.5500,     101.00 };
double DefTradeSize[NumChannels] = {0.1,       0.1,      0.1,     0.1,     0.1,        0.1,     0.1,     0.1,      0.1,      0.1,         0.1,        0.1,      0.1,        0.1    };
int    apScale[NumChannels]      = {1,          1,       1,       100,     100,         1,      1,       1,        1,        1,		      1,           100,     1,          100    };
int vWindow=0;

   ObjectsDeleteAll(0,OBJ_HLINE);
   if(!RemoveOnly)
   for(int ch=0;ch<NumChannels;ch++){
      if(Symbol()==vSymbol[ch]){
         Print("Pipsperstep=",PIPSPerStep[ch]," - apScale[ch]=",apScale[ch]);
         for (double l=CMin[ch];l<=CMax[ch];l=l+PIPSPerStep[ch]/10000*apScale[ch]){
            Print("Create level ",l);
            if(!ObjectCreate("BUY "+l,OBJ_HLINE,vWindow,0,l)){
               Print("Error Creating Object: ",GetLastError());
            }
         }
      
      }
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+