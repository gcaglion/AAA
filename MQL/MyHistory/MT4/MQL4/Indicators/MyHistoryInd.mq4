//+------------------------------------------------------------------+
//|                                                 MyHistoryInd.mq4 |
//|                                                         gcaglion |
//|                                           https://algoinvest.org |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      "https://algoinvest.org"
#property version   "2.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
//--- buffers
double ExtMapBuffer0[];
//--- variables
long     current_chart_id;
string   t_chWidth="label_object";

#define BULK_SIZE 9000

int    vBarTimeYY [BULK_SIZE]; 
int    vBarTimeMM [BULK_SIZE]; 
int    vBarTimeDD [BULK_SIZE]; 
int    vBarTimeHH [BULK_SIZE]; 
int    vBarTimeMI [BULK_SIZE]; 
double vBarOpen   [BULK_SIZE];
double vBarHigh   [BULK_SIZE];
double vBarLow    [BULK_SIZE];
double vBarClose  [BULK_SIZE];
double vBarVolume [BULK_SIZE];
datetime vBarTime;

uchar vuDebugFile[];    
uchar vuSymbol[];       
uchar user_name[];      
uchar user_pwd[];       
uchar db_service[];     
uchar vuBarTime[];
int ret;

//--- input parameters
input int      NYTimeDiff=7;
input int      LoadPastAuto=1;   // Load since the last record in the database? (0/1)
input datetime LoadPastSince=D'1990.01.01 00:00:00'; // Load Since then. (NY Time)
input string   OracleUserName="History";
input string   OraclePassword="History";
input string   OracleConnString="Algo";
input int      DebugLevel=0;
input string   DebugFile="C:/temp/MyHistoryV2.log";

#import "kernel32.dll"
   int lstrlenA(int);
   void RtlMoveMemory(uchar & arr[], int, int);
   int LocalFree(int); // May need to be changed depending on how the DLL allocates memory
#import
#import "MyHistory.dll"
   int InsertHistory (int pDebug, uchar &pLogFile[], int pCtx, uchar &pSymbol[], int pPeriod, int& pBarCount, int& pBarTimeYY[], int& pBarTimeMM[], int& pBarTimeDD[], int& pBarTimeHH[], int& pBarTimeMI[], double &pOpen[], double &pHigh[], double &pLow[], double &pClose[], double &pVolume[]);
   int GetLastBar (int pDebug, uchar &pDebugPath[], int pCtx, uchar &pSymbol[], int pPeriod);
#import
int vCtx;
#import "MyProCSubs.dll"
   int  OraConnect_MQ4(uchar &pUserName[], uchar &pPassword[], uchar &pDBString[], int pDebugLevel, uchar &pLogFileName[], int &pCtx);
   void OraDisconnect(int pCtx);
#import
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   int i=0;
   datetime aLPS;   // Actual LoadPastSince value 

   //-- 0. Convert strings to uchar[]
   StringToCharArray(DebugFile,         vuDebugFile);
   StringToCharArray(_Symbol,           vuSymbol);
   StringToCharArray(OracleUserName,    user_name);
   StringToCharArray(OraclePassword,    user_pwd);
   StringToCharArray(OracleConnString,  db_service);
   
   //-- 1. Connect to Oracle
   if(OraConnect_MQ4(user_name, user_pwd, db_service, DebugLevel, vuDebugFile, vCtx)!=0) return(INIT_FAILED);
   
   //-- 2. Define Earliest Bar to load
   if (LoadPastAuto==1){
      int ptrStringMemory = GetLastBar(DebugLevel, vuDebugFile, vCtx, vuSymbol, PeriodSeconds(_Period)/60);
      if(ptrStringMemory==0){
         printf("GetLastBar() Failed. Exiting...");
         return(INIT_FAILED);
      }
      int szString = lstrlenA(ptrStringMemory);
      uchar ucValue[];
      ArrayResize(ucValue, szString + 1);
      RtlMoveMemory(ucValue, ptrStringMemory, szString + 1);
      string strValue = CharArrayToString(ucValue);
      aLPS=StrToTime( strValue );
      LocalFree(ptrStringMemory);
   } else{
      aLPS=LoadPastSince;
   }

   //-- 3. Populate Arrays for T, O,H,L,C,V
   printf("Available Bars: %d ; Loading past bars since %s...", Bars, TimeToStr(aLPS,TIME_DATE|TIME_SECONDS));
   int BarId=1;
   i=0;
   int TotalInsertCount=0;
   while(Time[BarId]>=(aLPS+NYTimeDiff*3600) && (BarId)<(Bars-1)){
      vBarTime     =   Time  [BarId]-NYTimeDiff*3600; StringToCharArray(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), vuBarTime); 
      vBarTimeYY[i]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 0,  4) );
      vBarTimeMM[i]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 5,  2) ); 
      vBarTimeDD[i]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 8,  2) ); 
      vBarTimeHH[i]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 11, 2) ); 
      vBarTimeMI[i]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 14, 2) ); 
      vBarOpen  [i]=   Open  [BarId];
      vBarHigh  [i]=   High  [BarId];
      vBarLow   [i]=   Low   [BarId];
      vBarClose [i]=   Close [BarId];
      vBarVolume[i]=   (double)Volume[BarId];
      i++;
      if(i==BULK_SIZE){
         //ret = InsertHistory (DebugLevel, vuDebugFile, user_name, user_pwd, db_service, vuSymbol, PeriodSeconds(_Period)/60, i, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vBarOpen, vBarHigh, vBarLow, vBarClose, vBarVolume);
         ret = InsertHistory (DebugLevel, vuDebugFile, vCtx, vuSymbol, PeriodSeconds(_Period)/60, i, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vBarOpen, vBarHigh, vBarLow, vBarClose, vBarVolume);
         printf("InsertHistory returned %d ; %d Bars Inserted.", ret, i);
         if(ret<-1) return(INIT_FAILED);
         TotalInsertCount += i;
         i=0;
      }
      BarId++;
   }
   //-- Call InsertHistory
   if(i>0){
      ret = InsertHistory (DebugLevel, vuDebugFile, vCtx, vuSymbol, PeriodSeconds(_Period)/60, i, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vBarOpen, vBarHigh, vBarLow, vBarClose, vBarVolume);
      printf("InsertHistory returned %d ; %d Bars Inserted.", ret, i);
      TotalInsertCount += i;
   }
   printf("Total Bars Inserted=%d", TotalInsertCount);
   
   ret=CreateText();
   WriteText(StringConcatenate(TimeToString(Time[1], TIME_DATE)," ",TimeToString(Time[1]-NYTimeDiff*3600, TIME_MINUTES)));
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   // Only do this if there's a new bar
   static datetime Time0; if (Time0 == Time[1]) return(rates_total); Time0 = Time[1];   // Time[1] is the last closed bar
   int vBarCount=1;
   //-- 2. Populate Arrays for T, O,H,L,C,V
   vBarTime     =   Time  [0]-NYTimeDiff*3600; StringToCharArray(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), vuBarTime); 
   vBarTimeYY[0]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 0,  4) );
   vBarTimeMM[0]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 5,  2) ); 
   vBarTimeDD[0]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 8,  2) ); 
   vBarTimeHH[0]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 11, 2) ); 
   vBarTimeMI[0]= StrToInteger( StringSubstr(TimeToStr(vBarTime,TIME_DATE|TIME_SECONDS), 14, 2) ); 
   vBarOpen  [0]=   Open  [0];
   vBarHigh  [0]=   High  [0];
   vBarLow   [0]=   Low   [0];
   vBarClose [0]=   Close [0];
   vBarVolume[0]=   (double)Volume[0];
   //-- Call InsertHistory
   ret = InsertHistory (DebugLevel, vuDebugFile, vCtx, vuSymbol, PeriodSeconds(_Period)/60, vBarCount, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vBarOpen, vBarHigh, vBarLow, vBarClose, vBarVolume);
   //ret = InsertHistory (DebugLevel, vuDebugFile, user_name, user_pwd, db_service, vuSymbol, PeriodSeconds(_Period)/60, vBarCount, vBarTimeYY, vBarTimeMM, vBarTimeDD, vBarTimeHH, vBarTimeMI, vBarOpen, vBarHigh, vBarLow, vBarClose, vBarVolume);
   printf("InsertHistory returned %d ; %d Bars Inserted.", ret, vBarCount);
   
   //DoInsertHistory(1);  // '1' is for latest closed bar
   WriteText(StringConcatenate(TimeToString(Time[1], TIME_DATE)," ",TimeToString(Time[1]-NYTimeDiff*3600, TIME_MINUTES)));
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   OraDisconnect(vCtx);
   DeleteText();
}

int WriteText(string msg){
   return (ObjectSetString(current_chart_id,t_chWidth,OBJPROP_TEXT, msg));
}

int DeleteText(){
   ObjectDelete(t_chWidth);
   return 0;
}

int CreateText() {
//--- creating label object (it does not have time/price coordinates)
   //if(!ObjectCreate(current_chart_id,obj_name,OBJ_LABEL,0,0,0))
   if(!ObjectCreate(t_chWidth, OBJ_LABEL, 0, 0, 0))
     {
      Print("Error: can't create label! code #",GetLastError());
      return(-1);
     }
//--- set color to Red
   ObjectSetInteger(current_chart_id,t_chWidth,OBJPROP_COLOR,clrBlue);
//--- move object down and change its text
//   for(i=0; i<200; i++)
//     {
      //--- set text property
//      ObjectSetString(current_chart_id,t_chWidth,OBJPROP_TEXT,StringFormat("Simple Label at y= %d",i));
      //--- set distance property
//      ObjectSet(t_chWidth,OBJPROP_YDISTANCE,i);
      ObjectSet(t_chWidth,OBJPROP_YDISTANCE,0);
      ObjectSet(t_chWidth,OBJPROP_XDISTANCE,80);
      //--- forced chart redraw
//      ChartRedraw(current_chart_id);
//      Sleep(10);
//     }
//--- set color to Blue
 //  ObjectSetInteger(current_chart_id,t_chWidth,OBJPROP_COLOR,clrBlue);
//--- move object up and change its text
//   for(i=200; i>0; i--)
//     {
      //--- set text property
//      ObjectSetString(current_chart_id,t_chWidth,OBJPROP_TEXT,StringFormat("Simple Label at y= %d",i));
      //--- set distance property
//      ObjectSet(t_chWidth,OBJPROP_YDISTANCE,i);
      //--- forced chart redraw
//      ChartRedraw(current_chart_id);
//      Sleep(10);
//     }
   return (0);
}
