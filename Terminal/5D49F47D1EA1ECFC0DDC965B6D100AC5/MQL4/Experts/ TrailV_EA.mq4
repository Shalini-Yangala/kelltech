//+------------------------------------------------------------------+
//|                                                    TrailV_EA.mq4 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict

// Input parameters for trailing stop
input double TrailingGap = 10;    // Gap in pips from bid/ask price
input double TrailingStart = 20;  // Distance in pips from order entry price to start trailing
input bool ClassicTrailing = true; // Use classic trailing stop (true) or virtual trailing (false)

// Global variables
double point;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   point = Point;
   if(Digits == 3 || Digits == 5)
      point = Point * 10;

   EventSetTimer(1);  // Set timer to call OnTimer function every second
   Print("TrailV_EA initialized. TrailingGap: ", TrailingGap, " pips, TrailingStart: ", TrailingStart, " pips, ClassicTrailing: ", ClassicTrailing);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();  // Kill timer on deinitialization
   Print("TrailV_EA deinitialized.");
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         double openPrice = OrderOpenPrice();
         double currentPrice = OrderType() == OP_BUY ? Bid : Ask;
         double distanceFromOpen = (OrderType() == OP_BUY ? (currentPrice - openPrice) : (openPrice - currentPrice)) / point;

         if(distanceFromOpen >= TrailingStart)
           {
            double newStopLevel = (OrderType() == OP_BUY ? (currentPrice - TrailingGap * point) : (currentPrice + TrailingGap * point));
            double currentStopLevel = OrderStopLoss();

            if(ClassicTrailing)
              {
               // Classic trailing stop
               if((OrderType() == OP_BUY && (currentStopLevel < newStopLevel || currentStopLevel == 0)) ||
                  (OrderType() == OP_SELL && (currentStopLevel > newStopLevel || currentStopLevel == 0)))
                 {
                  if(OrderModify(OrderTicket(), OrderOpenPrice(), newStopLevel, OrderTakeProfit(), 0, clrNONE))
                    {
                     Print("Order modified successfully. Ticket: ", OrderTicket(), " New StopLevel: ", newStopLevel);
                    }
                  else
                    {
                     Print("Error in OrderModify. Error code: ", GetLastError());
                    }
                 }
              }
            else
              {
               // Virtual trailing stop logic
               double virtualStopLevel = OrderType() == OP_BUY ? (currentPrice - TrailingGap * point) : (currentPrice + TrailingGap * point);
               if(OrderType() == OP_BUY && currentPrice <= virtualStopLevel)
                 {
                  Print("Virtual stop hit. Closing Buy Order. Ticket: ", OrderTicket());
                  if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed))
                    {
                     Print("Error closing Buy Order. Error code: ", GetLastError());
                    }
                 }
               else if(OrderType() == OP_SELL && currentPrice >= virtualStopLevel)
                 {
                  Print("Virtual stop hit. Closing Sell Order. Ticket: ", OrderTicket());
                  if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed))
                    {
                     Print("Error closing Sell Order. Error code: ", GetLastError());
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
