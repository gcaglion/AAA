//+------------------------------------------------------------------+
//|                                               delete_pending.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#property show_confirm

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
            //---- delete first pending order
            result=OrderClose(
                              OrderTicket(),
                              OrderLots(),
                              MarketInfo(Symbol(),MODE_ASK),
                              5);
            if(result!=TRUE) Print("LastError = ", GetLastError());
        }
     }
  }
//----
  return(0);
 }
//+------------------------------------------------------------------+