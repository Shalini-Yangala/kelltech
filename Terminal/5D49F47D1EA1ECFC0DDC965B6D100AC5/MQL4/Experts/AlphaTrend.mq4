//+------------------------------------------------------------------+
//|                                                   AlphaTrend.mq4 |
//|                             Copyright 2024, Mathematical Traders |
//|                                      http://www.tradermaths.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Mathematical Traders"
#property link      "http://www.tradermaths.com/"
#property version   "1.00"
#property strict

input int AP = 14;
input double coeff = 1.0;
input double martingale = 1.5;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Deinitialization of the Expert Advisor
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double AlphaTrend = iCustom(NULL, 0, "Alpha Trend", 0, coeff, AP, 1);
   double AlphaTrendPrev2 = iCustom(NULL, 0, "Alpha Trend", 0, 2); // Getting previous AlphaTrend value
   double AlphaTrendPrev3 = iCustom(NULL, 0, "Alpha Trend", 0, 3); // Getting previous AlphaTrend value

   bool buySignal = AlphaTrend < AlphaTrendPrev2 && AlphaTrendPrev2 > AlphaTrendPrev3;
   bool sellSignal = AlphaTrend > AlphaTrendPrev2 && AlphaTrendPrev2 < AlphaTrendPrev3;

   // Signal color for visualization
   color color1 = buySignal ? clrGreen : sellSignal ? clrRed : clrGray;

   // Execute trades based on signals
   static bool buySignalPrev = false;
   static bool sellSignalPrev = false;
   static double buyLotSize = 0.1; // Initial lot size for buy trades
   static double sellLotSize = 0.1; // Initial lot size for sell trades

   if (buySignal && !buySignalPrev)
   {
      int buy_order_id = OrderSend(Symbol(), OP_BUY, buyLotSize, Ask, 3, 0, 0, "Buy Trade", 0, 0, clrGreen);
      if (buy_order_id > 0)
      {
         buySignalPrev = true;
         buyLotSize *= martingale;
      }
   }
   else if (!buySignal && buySignalPrev)
   {
      buySignalPrev = false;
   }

   if (sellSignal && !sellSignalPrev)
   {
      int sell_order_id = OrderSend(Symbol(), OP_SELL, sellLotSize, Bid, 3, 0, 0, "Sell Trade", 0, 0, clrRed);
      if (sell_order_id > 0)
      {
         sellSignalPrev = true;
         sellLotSize *= martingale;
      }
   }
   else if (!sellSignal && sellSignalPrev)
   {
      sellSignalPrev = false;
   }

   // Reset lot size after a winning trade
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderType() == OP_BUY && OrderProfit() > 0)
         {
            buyLotSize = 0.1;
         }
         if (OrderType() == OP_SELL && OrderProfit() > 0)
         {
            sellLotSize = 0.1;
         }
      }
   }
}
