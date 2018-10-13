//+------------------------------------------------------------------+
//|                                               delete_pending.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#property show_confirm

//+------------------------------------------------------------------+
//| script "delete first pending order"                              |
//+------------------------------------------------------------------+
int start()
  {
   bool   result;
   int    i;
   int cmd,total;
//----
   total=OrdersTotal(); Print("OrdersTotal=",total);
//----
   for(i=total-1; i>=0; i--){
     Print("i=",i);
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderType();
         //---- pending orders only are considered
         if(Symbol()==OrderSymbol() && cmd!=OP_BUY && cmd!=OP_SELL)
           {
            //---- print selected order
            //OrderPrint();
            //---- delete first pending order
            result=OrderDelete(OrderTicket());
            if(result!=TRUE) Print("LastError = ", GetLastError());
           }
        }
      else { Print( "Error when order select ", GetLastError()); break; }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+