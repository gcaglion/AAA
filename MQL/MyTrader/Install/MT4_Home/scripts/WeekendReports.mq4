//+------------------------------------------------------------------+
//|                                                ExportHistory.mq4 |
//|                                 Copyright © 20101 Thomas Quester |
//|                                        http://www.mt4-expert.de/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 20101 Thomas Quester"
#property link      "http://www.mt4-expert.de/"

#property show_inputs
extern int WeekNumber =52;

bool WantKomma=false;       // if Excel wants "," instead of "." for cent

//+------------------------------------------------------------------+
//| script program start function                                    |

//+------------------------------------------------------------------+

/*
string StringChangeToUpperCase(string sText) {
  // Example: StringChangeToUpperCase("oNe mAn"); // ONE MAN 
  int iLen=StringLen(sText), i, iChar;
  for(i=0; i < iLen; i++) {
    iChar=StringGetChar(sText, i);
    if(iChar >= 97 && iChar <= 122) sText=StringSetChar(sText, i, iChar-32);
  }
  return(sText);
}
*/ 

string StringChangeToLowerCase(string sText) {
  // Example: StringChangeToLowerCase("oNe mAn"); // one man
  int iLen=StringLen(sText), i, iChar;
  for(i=0; i < iLen; i++) {
    iChar=StringGetChar(sText, i);
    if(iChar >= 65 && iChar <= 90) sText=StringSetChar(sText, i, iChar+32);
  }
  return(sText);  
}
 
string typ2str(int typ)
{
   string r = "";
   if (typ == OP_BUY)  r = "buy";
   if (typ == OP_SELL) r = "sell";
   return (r);
 }

string p2str(double p, int digits)
{
   string s,r;
   s = DoubleToStr(p,digits);
   r = s;
   if (WantKomma)
   {
      p = StringFind(s,".",0);
   
      if (p != -1)
      {
         r = StringSubstr(s,0,p)+","+StringSubstr(s,p+1);
      }
   }
   return (r);
}
   
   
void SaveOrder(string title, int handle)
{
     int typ;
     typ = OrderType();
     if (typ == OP_BUY || typ == OP_SELL)
     {

         FileWrite(handle,
                  //title,
                  p2str(OrderTicket(),0),
                  TimeToStr(OrderOpenTime()),
                  typ2str(OrderType()),
                  p2str(OrderLots(),3),
                  StringChangeToLowerCase(OrderSymbol()),
                  p2str(OrderOpenPrice(),5),
                  p2str(OrderStopLoss(),5),
                  p2str(OrderTakeProfit(),5),
                  TimeToStr(OrderCloseTime()),
                  p2str(OrderClosePrice(),5),
                  p2str(OrderCommission(),5),
                  "0",  //Order Taxes
                  p2str(OrderSwap(),3),
                  p2str(OrderProfit(),3),
                  OrderComment(),
                  p2str(WeekNumber,0));
     }
 
}   
int start()
  {
//----
   int handle,cnt,i;


//--- Open Trades ---
   cnt = OrdersHistoryTotal();
   handle = FileOpen("OpenTrades.csv",FILE_WRITE|FILE_CSV,',');
   //FileWrite(handle,"Opened/Closed","Type","Time and Date","Symbol","Magic Number","Lots","Open","Close","Profit","Comment","Week");
   FileWrite(handle,"Ticket","Open Time","Type","Size","Item","Price","S/L","T/P","Close Time","Price","Commissions","Taxes","Swap","Profit","Comment","Week");
   cnt = OrdersTotal();
   for (i=0;i<cnt;i++)
   {
       if (OrderSelect(i,SELECT_BY_POS, MODE_TRADES) == true)
       {
         SaveOrder("open",handle);
       }
   }
   FileClose(handle);

//--- History  ---
   cnt = OrdersHistoryTotal();
   handle = FileOpen("History.csv",FILE_WRITE|FILE_CSV,',');
   //FileWrite(handle,"Opened/Closed","Type","Time and Date","Symbol","Magic Number","Lots","Open","Close","Profit","Comment","Week");
   FileWrite(handle,"Ticket","Open Time","Type","Size","Item","Price","S/L","T/P","Close Time","Price","Commissions","Taxes","Swap","Profit","Comment","Week");
   cnt = OrdersTotal();
   for (i=0;i<cnt;i++)
   {
       if (OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) == true)
       {
         SaveOrder("closed",handle);
       }
   }
   FileClose(handle);
       
//----
   return(0);
  }
//+------------------------------------------------------------------+