//+------------------------------------------------------------------+
//|                                                    MyHistory.mq4 |
//|                                                         gcaglion |
//|                                        http://www.algoinvest.org |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      "http://www.algoinvest.org"
#property version   "1.00"
#property strict

//--- input parameters
extern string  OracleUserName="History";
extern string  OraclePassword="HistoryPwd";
extern string  OracleConnString="MyNN";
extern int     EnableDebug=1;    // Enable Debug? 0/1
extern string  DebugPath="C:/temp/MT4-1";


#define  SYMBOLS_TRADING    "GBPUSD","EURUSD","AUDUSD"

#define  CHART_EVENT_SYMBOL CHARTEVENT_TICK 
#include <OnTick(string symbol).mqh>

#import "MyHistory.dll"
   int OraConnect    (uchar &user_name[], uchar &user_pwd[], uchar &db_service[], int pDebug, uchar &pDebugPath[]);
   int InsertHistory (int pDebug, uchar &pDebugPath[], uchar &pSymbol[], int pPeriod, uchar &pBarCloseTime[], double pOpen, double pHigh, double pLow, double pClose, double pVolume);
#import

string vSymbol[]={SYMBOLS_TRADING};    int vSymbolsCount= ArraySize(vSymbol);


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit () {


   // First, Connect
   printf("Connecting to Oracle...");
   if(!OracleConnect(OracleUserName, OraclePassword, OracleConnString, EnableDebug, DebugPath)){
      return -1;
   } else {
      printf("Moving on with program...");
      DoInsertHistory();
      return 0;
   }
}

void OnTick(string symbol){
   // Only do this if there's a new bar
   static datetime stm; 
   datetime tm[];
   CopyTime(_Symbol, PERIOD_M1, 1,1, tm);
   //printf("tm[0]=%d ; stm=%d",tm[0],stm);
   if (tm[0]==stm) return;
   stm=tm[0];
   //Print("OnTick called");
   DoInsertHistory();
}

void DoInsertHistory(){
   int ret;
   datetime tm[];
   double vOpen[]; double vHigh[]; double vLow[]; double vClose[]; long vVolume[];
   for(int s=0; s<vSymbolsCount; s++){
      CopyTime(vSymbol[s], PERIOD_M1, 1, 1, tm);
      tm[0]=tm[0]+TimeGMTOffset()-5*3600; // (All Timestamps on NY time)
      string vBarCloseTime=TimeToString(tm[0],TIME_DATE)+" "+TimeToString(tm[0],TIME_MINUTES);
      ret=CopyOpen(vSymbol[s],PERIOD_M1,1,1,vOpen);
      ret=CopyHigh(vSymbol[s],PERIOD_M1,1,1,vHigh);
      ret=CopyLow(vSymbol[s],PERIOD_M1,1,1,vLow);
      ret=CopyClose(vSymbol[s],PERIOD_M1,1,1,vClose);
      ret=CopyTickVolume(vSymbol[s],PERIOD_M1,1,1,vVolume);
      ret=OracleInsertHistory(EnableDebug, DebugPath, vSymbol[s], PeriodSeconds(PERIOD_M1)/60, vBarCloseTime, vOpen[0], vHigh[0], vLow[0], vClose[0], vVolume[0]);
   }
}

bool OracleInsertHistory(int pDebug, string pDebugPath, string pSymbol, int pPeriod, string pBarCloseTime, double pOpen, double pHigh, double pLow, double pClose, long pVolume){
   uchar vDebugPath[]; uchar vuSymbol[]; uchar vBarCloseTime[];
   StringToCharArray(pDebugPath,    vDebugPath);
   StringToCharArray(pSymbol,       vuSymbol);
   StringToCharArray(pBarCloseTime, vBarCloseTime);
   int vDebug=pDebug; int vPeriod=pPeriod; double vOpen=pOpen; double vHigh=pHigh; double vLow=pLow; double vClose=pClose; long vVolume=pVolume;
   int oiret=InsertHistory(vDebug, vDebugPath, vuSymbol, vPeriod, vBarCloseTime, vOpen, vHigh, vLow, vClose, vVolume);
   if (oiret!=0){
      Print("Cannot Insert. Error: ",oiret);
      return false;
   } else {
      printf("Insert for %s Successful!",pSymbol);
      return true;
   }
}
bool OracleConnect (string DBUserName, string DBPassword, string DBConnString, int pDebug, string pDebugPath){
//bool OracleConnect (string DBUserName, string DBPassword, string DBConnString){
   uchar user_name[], user_pwd[], db_service[], debug_path[];
   StringToCharArray(DBUserName,   user_name);
   StringToCharArray(DBPassword,   user_pwd);
   StringToCharArray(DBConnString, db_service);
   StringToCharArray(pDebugPath, debug_path);   
   int ocret=OraConnect(user_name, user_pwd, db_service, pDebug, debug_path);
   if(ocret!=0){
      Print("Cannot connect to DB. Error: ",ocret," .Exiting...");
      return false;
   } else {
      printf("Connection Successful!");
      return true;
   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//| This function must be declared, even if it empty.                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event id
                  const long& lparam,   // event param of long type
                  const double& dparam, // event param of double type
                  const string& sparam) // event param of string type
  {
   //--- Add your code here...
  }