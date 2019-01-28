//+------------------------------------------------------------------+
//|                                                     download.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
   double vopen[], vhigh[], vlow[], vclose[], vvolume[];
   int vtime[]; string vtimeS[];

 void OnStart(){

   
   string symb=Symbol();   //"US500-MAR19";
   string tf="D1";

   int depth=loadAllBars(symb, tf);
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
      FileWrite(file_handle, vtimeS[i], vopen[i], vhigh[i], vlow[i], vclose[i], vvolume[i]);
   }
   FileClose(file_handle);
   
  }
//+------------------------------------------------------------------+
int loadAllBars(string symbolS, string timeframeS){
	int i=0;
	ENUM_TIMEFRAMES tf;
   MqlRates serierates[];
	tf = getTimeFrameEnum(timeframeS);
	int copied=CopyRates(symbolS, tf, 1, 10000000, serierates);	printf("copied=%d", copied);
	if(copied>0) {
      ArrayResize(vtime, copied);
   	ArrayResize(vtimeS, copied);
   	ArrayResize(vopen, copied);
   	ArrayResize(vhigh, copied);
   	ArrayResize(vlow, copied);
   	ArrayResize(vclose, copied);
   	ArrayResize(vvolume, copied);
   	for (int bar=0; bar<copied; bar++) {
   		vtime[i]=serierates[bar].time+TimeGMTOffset();
   		StringConcatenate(vtimeS[i], TimeToString(vtime[i], TIME_DATE), ".", TimeToString(vtime[i], TIME_MINUTES));
   		vopen[i]=serierates[bar].open;
   		vhigh[i]=serierates[bar].high;
   		vlow[i]=serierates[bar].low;
   		vclose[i]=serierates[bar].close;
   		vvolume[i]=serierates[bar].real_volume;
   		//printf("time[%d]=%s ; OHLCV[%d]=%f|%f|%f|%f|%f", i, vtimeS[i], i, vopen[i], vhigh[i], vlow[i], vclose[i], vvolume[i]);
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