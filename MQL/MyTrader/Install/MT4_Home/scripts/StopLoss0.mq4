//+------------------------------------------------------------------+
//|                                               delete_pending.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#property show_confirm

//=================================================
//  ===   Sets StopLoss=0 for open positions   ====
//=================================================

int start()
  {
   bool   result;
   int    cmd,total,i;
//----
   total=OrdersTotal();
//----
   Print("OrdersTotal=",total);
   for (i=total; i>0; i--){    
      if(OrderSelect(i-1,SELECT_BY_POS)==true){
      //while (OrderSelect(1,SELECT_BY_POS,MODE_TRADES))
         //Print("Inside OrderSelect");
         cmd=OrderType();
         //---- open orders only are considered
         if(Symbol()==OrderSymbol() && (cmd==OP_BUY || cmd==OP_SELL)){
            //Print("Inside Order Type");
            // if SL!=0, Set SL=0
            if(OrderStopLoss()!=0){
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0)){
                  Alert("OrderModify(",OrderTicket(),") failed. Error=",GetLastError());
               } else {
                  Print ("OrderModify(",OrderTicket(),") successful.");
               }
            }   
        }
     }
  }
//----
  return(0);
 }
//+------------------------------------------------------------------+