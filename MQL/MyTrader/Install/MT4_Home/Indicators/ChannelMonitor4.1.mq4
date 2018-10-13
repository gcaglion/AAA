//+------------------------------------------------------------------+
//|                                          ChannelMonitor V4.1.mq4 |
//|                                                         gcaglion |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "gcaglion"
#property link      ""

// Parameters
input bool WriteToFiles = false;
#property indicator_separate_window
#property indicator_buffers 5

//--- buffers
double ExtMapBuffer0[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int      Handle;
string   File_Name;
int      WrittenBytes;
int      SaveInterval=60;   //Useless
int      ch, i;
double   pScale;
long     current_chart_id;
string   t_chWidth="label_object";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexLabel(0,"Channel Max");
   SetIndexStyle(0,DRAW_LINE,EMPTY,3,clrRed);
   SetIndexBuffer(0,ExtMapBuffer0);
   SetIndexLabel(1,"Channel Avg");
   SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,clrGreen);
   SetIndexBuffer(1,ExtMapBuffer1);
   SetIndexLabel(2,"Channel Bid");
   SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,clrBlue);
   SetIndexBuffer(2,ExtMapBuffer2);
   SetIndexLabel(3,"Channel Min");
   SetIndexStyle(3,DRAW_LINE,EMPTY,3,clrRed);
   SetIndexBuffer(3,ExtMapBuffer3);
   //SetIndexStyle(4,);
   //SetIndexBuffer(4,ExtMapBuffer4);
   //SetIndexLabel(4,"Channel Width");
   int ret=CreateText();

   // ========================================================================
   // =======  TO BE FINALIZED !!!  ======
      double scale=MarketInfo(Symbol(),MODE_TICKSIZE);
      Print("scale=",scale);
      if(scale>0.0001){
         pScale=100000*scale;
      } else {
         pScale=10000;
      }
      Print("pScale=",pScale);
   // ========================================================================
   if (WriteToFiles){
      File_Name=StringConcatenate(Symbol(),".csv");
      Print("File_Name=",File_Name);
      Handle=FileOpen(File_Name,FILE_CSV|FILE_WRITE,",");//File opening
      if(Handle==-1)                      // File opening fails
        {
         Alert("An error while opening the file. ","May be the file is busy by the other application");
         return (-1);                          // Exir start()      
        }
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
   return (DeleteText());
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //int    Counted_bars=IndicatorCounted();
//----
   int    total;
   double chMin=10000;
   double chMax=0;
   double chAvg=0;
   
   static int FileLines;
   static datetime LastSave;
   string OrigFileName;
   string NewFileName;
   string vLine;
   int rHandle; int wHandle;

   total=OrdersTotal();
   for (i=total; i>0; i--){    
      if(OrderSelect(i-1,SELECT_BY_POS)==true){
         if(OrderSymbol()==Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL) ){
            //Print("In the loop syth Symbol=",Symbol(),", OrderSymbol=",OrderSymbol(),", OrderOpenPrice=",OrderOpenPrice());
            if(OrderOpenPrice()>chMax) chMax=OrderOpenPrice();
            if(OrderOpenPrice()<chMin) chMin=OrderOpenPrice();
         }
      }
   }

   chAvg=(chMin+chMax)/2;
   ExtMapBuffer0[0]=chMax;
   ExtMapBuffer1[0]=chAvg;
   ExtMapBuffer2[0]=Bid;
   ExtMapBuffer3[0]=chMin;   
   //Adjust Displayed Min & Max
   IndicatorSetDouble(INDICATOR_MINIMUM,chMin);
   IndicatorSetDouble(INDICATOR_MAXIMUM,chMax);  
   // Display Channel Width
   WriteText(StringFormat("Channel Width=%4.0f ; Current Pos=%2.0f%%",NormalizeDouble((chMax-chMin)*pScale,1),NormalizeDouble(100*(Bid-chMin)/(chMax-chMin),0))); 

   if (WriteToFiles){   
      WrittenBytes=FileWrite(Handle,chMin, chMax, chAvg, Bid);
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
         WrittenBytes=FileWrite(wHandle,"chMin, chMax, chAvg, Bid");
         //while(FileIsEnding(rHandle)==false){
            vLine="";
            for (i=0; i<4; i++){
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
}
//----
   return(0);
  }
//+------------------------------------------------------------------+
int WriteText(string msg){
   return (ObjectSetString(current_chart_id,t_chWidth,OBJPROP_TEXT, msg));
}
int DeleteText(){
   ObjectDelete(t_chWidth);
   return 0;
}
int CreateText()
{
   
//--- creating label object (it does not have time/price coordinates)
   //if(!ObjectCreate(current_chart_id,obj_name,OBJ_LABEL,0,0,0))
   if(!ObjectCreate(t_chWidth, OBJ_LABEL, 1, 0, 0))
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
      ObjectSet(t_chWidth,OBJPROP_XDISTANCE,250);
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