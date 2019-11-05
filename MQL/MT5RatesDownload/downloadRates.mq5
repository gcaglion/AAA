//+------------------------------------------------------------------+
//|                                                     download.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int historyLen=100;
input string tf="H1";
input int ATR_MAperiod=15;
input int EMA_fastPeriod=5;
input int EMA_slowPeriod=10;
input int EMA_signalPeriod=5;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
   double vopen[], vhigh[], vlow[], vclose[], vvolume[];
   int vtime[]; string vtimeS[];

   
   int ATRhandle;  double ATRvalue[]; 
   int MACDhandle;  double MACDvalue[]; 

 void OnStart(){

   
   string symb=Symbol();   //"US500-MAR19";
   

   MACDhandle = iMACD(symb, 0, EMA_fastPeriod, EMA_slowPeriod, EMA_signalPeriod, PRICE_CLOSE);
   ArraySetAsSeries(MACDvalue, true);
   if(CopyBuffer(MACDhandle, 0, 0, historyLen, MACDvalue)==0) {
      printf("MACD copyBuffer failed.");
      return;
   }
     
   ATRhandle = iATR(symb, 0,ATR_MAperiod);
   ArraySetAsSeries(ATRvalue, true);
   if(CopyBuffer(ATRhandle, 0, 0, historyLen, ATRvalue)==0) {
      printf("ATR copyBuffer failed.");
      return;
   }
   
   int depth=loadAllBars(symb, tf, historyLen);
   if(depth==0) {
      printf("loadBars failed.");
      return;
   }
   
   
   string outFileName;
   StringConcatenate(outFileName, symb,"_",tf,".csv");
   int file_handle=FileOpen(outFileName, FILE_WRITE|FILE_CSV); 
   if(file_handle==INVALID_HANDLE) { 
      PrintFormat("Failed to open %s file, Error code = %d",outFileName,GetLastError()); 
      return;
   }
   
   for(int i=0; i<depth; i++) {
      //FileWrite(file_handle, vtimeS[i], NormalizeDouble(vopen[i], 6), NormalizeDouble(vhigh[i], 6), NormalizeDouble(vlow[i], 6), NormalizeDouble(vclose[i], 6), NormalizeDouble(vvolume[i], 1));
      FileWrite(file_handle, vtimeS[i],",", vopen[i],",", vhigh[i],",", vlow[i],",", vclose[i],",", vvolume[i]);
   }
   FileClose(file_handle);
   
  }
//+------------------------------------------------------------------+
int loadAllBars(string symbolS, string timeframeS, int hlen){
	int i=0;
	ENUM_TIMEFRAMES tf;
   MqlRates serierates[];
	tf = getTimeFrameEnum(timeframeS);
	int copied=CopyRates(symbolS, tf, 1, hlen, serierates);	printf("copied=%d", copied);
	if(copied>0) {
      ArrayResize(vtime, copied);
   	ArrayResize(vtimeS, copied);
   	ArrayResize(vopen, copied);
   	ArrayResize(vhigh, copied);
   	ArrayResize(vlow, copied);
   	ArrayResize(vclose, copied);
   	ArrayResize(vvolume, copied);
   	for (int bar=0; bar<copied; bar++) {
   		vtime[i]=serierates[bar].time;//+TimeGMTOffset();
   		StringConcatenate(vtimeS[i], TimeToString(vtime[i], TIME_DATE), ".", TimeToString(vtime[i], TIME_MINUTES));
   		vopen[i]=serierates[bar].open;
   		vhigh[i]=serierates[bar].high;
   		vlow[i]=serierates[bar].low;
   		vclose[i]=serierates[bar].close;
   		vvolume[i]=serierates[bar].real_volume;
   		printf("time[%d]=%s ; OHLCV[%d]=%f|%f|%f|%f|%f ; ATR=%f ; MACD=%f", i, vtimeS[i], i, vopen[i], vhigh[i], vlow[i], vclose[i], vvolume[i], ATRvalue[i], MACDvalue[i]);
   		i++;
   	}
	}
	return copied;
}
ENUM_TIMEFRAMES getTimeFrameEnum(string tfS) {
	if (tfS=="H1") return PERIOD_H1;
	if (tfS=="D1") return PERIOD_D1;
	return 0;
}

//-- EXCEL FORMULA to build insert statements:
//-- ="insert into ETXEUR_H1(newdatetime, open, high, low, close, volume) values(to_date('"&A1&"','YYYY.MM.DD HH24:MI'), "&B1&","&C1&","&D1&","&E1&","&F1&");"
