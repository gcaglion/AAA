//+------------------------------------------------------------------+
//|                                                      MyExcel.mq4 |
//|                                                         gcaglion |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Green


//--- input parameters
//extern int       RefreshInterval=5;
//extern int       MaxHistory=10;
//--- buffers

//---
int Handle;
string File_Name;
int       SaveInterval=60;   //Useless

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
   bool ret;
   ret=ObjectCreate("AccountBalance", OBJ_LABEL, 0, 0,0);
   ret=ObjectCreate("AccountProfit", OBJ_LABEL, 0, 0,0);
   ret=ObjectCreate("AccountEquity", OBJ_LABEL, 0, 0,0);
   ret=ObjectCreate("AccountMargin", OBJ_LABEL, 0, 0,0);
   ret=ObjectCreate("NetBalance", OBJ_LABEL, 0, 0,0);
   ObjectSet("AccountBalance", OBJPROP_YDISTANCE, 30);
   ObjectSet("AccountProfit", OBJPROP_YDISTANCE, 60);
   ObjectSet("NetBalance", OBJPROP_YDISTANCE, 90);
   ObjectSet("AccountEquity", OBJPROP_YDISTANCE, 120);
   ObjectSet("AccountMargin", OBJPROP_YDISTANCE, 150);
   
   //File_Name=StringConcatenate("MT4Excel",Symbol(),".csv");
   File_Name="MT4Excel.csv";
   Print("File_Name=",File_Name);

   Handle=FileOpen(File_Name,FILE_CSV|FILE_WRITE,",");//File opening
   if(Handle==-1)                      // File opening fails
     {
      Alert("An error while opening the file. ","May be the file is busy by the other application");
      return;                          // Exir start()      
     }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("AccountBalance");
   ObjectDelete("AccountProfit");
   ObjectDelete("AccountEquity");
   ObjectDelete("AccountMargin");
   ObjectDelete("NetBalance");
   FileClose(Handle);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double AccountMarginP;
   int WrittenBytes;
   static int FileLines;
   static datetime LastSave;
   string OrigFileName;
   string NewFileName;
   string vLine;
   int rHandle; int wHandle;
   int i; string str;
//----

   str=StringConcatenate("Balance: ",DoubleToStr(AccountBalance(),2));
   ObjectSetText("AccountBalance", StringConcatenate("Balance: ",DoubleToStr(AccountBalance(),2)), 12, "Arial", Black);
   ObjectSetText("AccountProfit",  StringConcatenate("P/L: ",DoubleToStr(AccountProfit(),2)), 12, "Arial", Red);
   ObjectSetText("AccountEquity",  StringConcatenate("Equity: ",DoubleToStr(AccountEquity(),2)), 12, "Arial", Black);
   ObjectSetText("NetBalance",  StringConcatenate("Net Balance: ",DoubleToStr(AccountBalance()+AccountProfit(),2)), 12, "Arial", Black);
   if (AccountMargin()>0){
      AccountMarginP=100*AccountEquity()/AccountMargin();
   }
   else {
      AccountMarginP=0;
   }
   ObjectSetText("AccountMargin", StringConcatenate("Margin%: ",DoubleToStr(AccountMarginP,2)), 12, "Arial", Blue);
   WrittenBytes=FileWrite(Handle, TimeToStr(TimeCurrent()), AccountBalance(), AccountProfit(), AccountEquity(), AccountBalance()+AccountProfit(), AccountMarginP);
   //Print("Line ",FileLines,", ",WrittenBytes, " bytes written to file.");   
   FileLines=FileLines+1;
   //Print("LastSave=",LastSave);
   //Print("Time[0]=",Time[0]);
   //if (FileLines>MaxHistory){
   if (Time[0]-LastSave>=SaveInterval){
      LastSave=Time[0];
      FileClose(Handle);
      OrigFileName=File_Name;
      NewFileName="NEW_"+OrigFileName;
      //Print("OrigFileName=",OrigFileName);
      //Print("NewFileName=",NewFileName);
      
      rHandle=FileOpen(OrigFileName,FILE_CSV|FILE_READ,",");
      //Print("FileOpen rHandle=",rHandle);
      wHandle=FileOpen(NewFileName,FILE_CSV|FILE_WRITE,",");
      //Print("FileOpen wHandle=",wHandle);
      WrittenBytes=FileWrite(wHandle,"TimeStamp, AccountBalance, AccountProfit, AccountEquity, NetBalance, Margin%");
      //while(FileIsEnding(rHandle)==false){
         vLine="";
         for (i=0; i<6; i++){
            vLine=vLine+FileReadString(rHandle)+",";
         }
         Print("Writing to ",NewFileName,": ",vLine);
         WrittenBytes=FileWrite(wHandle,vLine);
      //}
      FileClose(rHandle);
      FileClose(wHandle);
      
      Handle=FileOpen(File_Name,FILE_CSV|FILE_WRITE,",");//File opening
      FileLines=0;
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+


//