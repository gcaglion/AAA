//+------------------------------------------------------------------+
//|                                                     download.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property script_show_inputs
input int historyLen=95000;
input ENUM_APPLIED_PRICE priceType=PRICE_CLOSE;
input string tf="H1";
input int ATR_MAperiod=15;
input int EMA_fastPeriod=5;
input int EMA_slowPeriod=10;
input int EMA_signalPeriod=5;
input int CCI_MAperiod=15;
input int BOLL_period=20;
input int BOLL_shift=0;
input double BOLL_deviation=2.0;
input int DEMA_period=20;
input int DEMA_shift=0;
input int MA_period=10;
input int MA_shift=0;
input int MOM_period=4320;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
   double vopen[], vhigh[], vlow[], vclose[], vvolume[];
   int vtime[]; string vtimeS[];
   int copied;
   
   int MACDhandle; double MACDvalue[]; 
   int CCIhandle;  double CCIvalue[];
   int ATRhandle;  double ATRvalue[];
   int BOLLhandle; double BOLLvalueH[]; double BOLLvalueM[]; double BOLLvalueL[]; 
   int DEMAhandle; double DEMAvalue[];
   int MAhandle;   double MAvalue[];
   int MOMhandle;  double MOMvalue[];
   int ADhandle;   double ADvalue[];
   
 void OnStart(){

   string symb=Symbol();   //"US500-MAR19";
   

   MACDhandle = iMACD(symb, 0, EMA_fastPeriod, EMA_slowPeriod, EMA_signalPeriod, priceType);
   ArraySetAsSeries(MACDvalue, false);
   copied=CopyBuffer(MACDhandle, 0, 0, historyLen, MACDvalue);
   if(copied<historyLen) {
      printf("MACD copyBuffer failed. copied=%d", copied);
      return;
   }
     
   CCIhandle = iCCI(symb, 0, CCI_MAperiod, priceType);
   ArraySetAsSeries(CCIvalue, false);
   copied=CopyBuffer(CCIhandle, 0, 0, historyLen, CCIvalue);
   if(copied<historyLen) {
      printf("CCI copyBuffer failed. copied=%d", copied);
      return;
   }
     
   ATRhandle = iATR(symb, 0,ATR_MAperiod);
   ArraySetAsSeries(ATRvalue, false);
   copied=CopyBuffer(ATRhandle, 0, 0, historyLen, ATRvalue);
   if(copied<historyLen) {
      printf("ATR copyBuffer failed. copied=%d", copied);
      return;
   }
   
   BOLLhandle = iBands(symb, 0,BOLL_period, BOLL_shift, BOLL_deviation, priceType);
   ArraySetAsSeries(BOLLvalueH, false); ArraySetAsSeries(BOLLvalueM, false); ArraySetAsSeries(BOLLvalueL, false);
   if(CopyBuffer(BOLLhandle, 0, 0, historyLen, BOLLvalueM)<historyLen || CopyBuffer(BOLLhandle, 1, 0, historyLen, BOLLvalueH)<historyLen || CopyBuffer(BOLLhandle, 2, 0, historyLen, BOLLvalueL)<historyLen) {
      printf("BOLL copyBuffer failed.");
      return;
   }
   
   DEMAhandle = iDEMA(symb, 0,DEMA_period, DEMA_shift, priceType);
   ArraySetAsSeries(DEMAvalue, false);
   copied=CopyBuffer(DEMAhandle, 0, 0, historyLen, DEMAvalue);
   if(copied<historyLen) {
      printf("DEMA copyBuffer failed. copied=%d", copied);
      return;
   }
   
   MAhandle = iMA(symb, 0,MA_period, MA_shift, MODE_SMA, priceType);
   ArraySetAsSeries(MAvalue, false);
   copied=CopyBuffer(MAhandle, 0, 0, historyLen, MAvalue);
   if(copied<historyLen) {
      printf("MA copyBuffer failed. copied=%d", copied);
      return;
   }
   
   MOMhandle = iMomentum(symb, 0, MOM_period, priceType);
   ArraySetAsSeries(MOMvalue, false);
   copied=CopyBuffer(MOMhandle, 0, 0, historyLen, MOMvalue);
   if(copied<historyLen) {
      printf("MOM copyBuffer failed. copied=%d", copied);
      return;
   }
   
//   ADhandle = iAD(symb, 0, VOLUME_REAL);
//   ArraySetAsSeries(ADvalue, false);
//   if(CopyBuffer(ADhandle, 0, 0, historyLen, ADvalue)<=0) {
//      printf("AD copyBuffer failed.");
//      return;
//   }
   
   
   
   if(!loadAllBars(symb, tf, historyLen)){
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
   
   for(int i=0; i<historyLen; i++) {
      //FileWrite(file_handle, vtimeS[i], NormalizeDouble(vopen[i], 6), NormalizeDouble(vhigh[i], 6), NormalizeDouble(vlow[i], 6), NormalizeDouble(vclose[i], 6), NormalizeDouble(vvolume[i], 1));
      //FileWrite(file_handle, vtimeS[i],",", vopen[i],",", vhigh[i],",", vlow[i],",", vclose[i],",", vvolume[i], MACDvalue[i], ",", CCIvalue[i], ",", ATRvalue[i], ",", BOLLvalueH[i], ",", BOLLvalueM[i], ",", BOLLvalueL[i], ",", DEMAvalue[i], ",", MAvalue[i], ",", MOMvalue[i], ",", ADvalue[i]);
      FileWrite(file_handle, vtimeS[i], vopen[i], vhigh[i], vlow[i], vclose[i], vvolume[i], MACDvalue[i], CCIvalue[i], ATRvalue[i], BOLLvalueH[i], BOLLvalueM[i], BOLLvalueL[i], DEMAvalue[i], MAvalue[i], MOMvalue[i]);
   }
   FileClose(file_handle);
   
  }
//+------------------------------------------------------------------+
bool loadAllBars(string symbolS, string timeframeS, int hlen){
	int i=0;
	ENUM_TIMEFRAMES etf;
   MqlRates serierates[];
	etf = getTimeFrameEnum(timeframeS);
	copied=CopyRates(symbolS, etf, i, hlen, serierates);
	   if(copied<historyLen) {
      printf("OHLCV copyRates failed. copied=%d", copied);
      return false;
   }
 
   ArrayResize(vtime, copied);
	ArrayResize(vtimeS, copied);
	ArrayResize(vopen, copied);
	ArrayResize(vhigh, copied);
	ArrayResize(vlow, copied);
	ArrayResize(vclose, copied);
	ArrayResize(vvolume, copied);
	for (int bar=0; bar<copied; bar++) {
		vtime[i]=(int)serierates[bar].time;//+TimeGMTOffset();
		StringConcatenate(vtimeS[i], TimeToString(vtime[i], TIME_DATE), ".", TimeToString(vtime[i], TIME_MINUTES));
		vopen[i]=serierates[bar].open;
		vhigh[i]=serierates[bar].high;
		vlow[i]=serierates[bar].low;
		vclose[i]=serierates[bar].close;
		vvolume[i]=(double)serierates[bar].real_volume; if(vvolume[i]<0||vvolume[i]>1000) vvolume[i]=0;
		//printf("time[%d]=%s ; OHLCV[%d]=%f|%f|%f|%f|%f ; ATR=%f ; MACD=%f ; CCI=%f ; BOLL_H=%f ; BOLL_M=%f ; BOLL_L=%f", i, vtimeS[i], i, vopen[i], vhigh[i], vlow[i], vclose[i], vvolume[i], ATRvalue[i], MACDvalue[i], CCIvalue[i], BOLLvalueH[i], BOLLvalueM[i], BOLLvalueL[i]);
		i++;
	}
	return true;
}
ENUM_TIMEFRAMES getTimeFrameEnum(string tfS) {
	if (tfS=="H1") return PERIOD_H1;
	if (tfS=="D1") return PERIOD_D1;
	return 0;
}

//-- EXCEL FORMULA to build insert statements:
//-- ="insert into ETXEUR_H1(newdatetime, open, high, low, close, volume) values(to_date('"&A1&"','YYYY.MM.DD HH24:MI'), "&B1&","&C1&","&D1&","&E1&","&F1&");"
