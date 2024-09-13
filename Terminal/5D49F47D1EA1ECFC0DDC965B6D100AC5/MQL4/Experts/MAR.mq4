
/*

//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict



int MAGIC_NUMBER = 12345;

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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Moving averages calculation
   double ma05 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma10 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma15 = iMA(NULL, 0, 15, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma20 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma25 = iMA(NULL, 0, 25, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma30 = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma35 = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma40 = iMA(NULL, 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma45 = iMA(NULL, 0, 45, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma55 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma60 = iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma70 = iMA(NULL, 0, 70, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma75 = iMA(NULL, 0, 75, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma80 = iMA(NULL, 0, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma85 = iMA(NULL, 0, 85, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma90 = iMA(NULL, 0, 90, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma100 = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);

   // Trend determination
   int trend = 0; // 1 for long, -1 for short, 0 for no trend

   if(ma05 > ma100 && ma10 > ma100 && ma15 > ma100 && ma20 > ma100 && ma25 > ma100 && ma30 > ma100 && ma35 > ma100 && ma40 > ma100 && ma45 > ma100 && ma50 > ma100 && ma55 > ma100 && ma60 > ma100 && ma65 > ma100 && ma70 > ma100 && ma75 > ma100 && ma80 > ma100 && ma85 > ma100 && ma90 > ma100)
     {
      trend = 1; // Uptrend
     }
   else if(ma05 < ma100 && ma10 < ma100 && ma15 < ma100 && ma20 < ma100 && ma25 < ma100 && ma30 < ma100 && ma35 < ma100 && ma40 < ma100 && ma45 < ma100 && ma50 < ma100 && ma55 < ma100 && ma60 < ma100 && ma65 < ma100 && ma70 < ma100 && ma75 < ma100 && ma80 < ma100 && ma85 < ma100 && ma90 < ma100)
     {
      trend = -1; // Downtrend
     }
   else
     {
      trend = 0; // No clear trend
     }

   // Martingale logic
   double lotSize = 0.1; // Starting lot size
   double martingaleMultiplier = 1.5;
   double currentLots = lotSize;

   int ordersTotal = OrdersTotal();

   if(ordersTotal > 0)
     {
      // Check last order and apply martingale if it was a loss
      OrderSelect(ordersTotal - 1, SELECT_BY_POS);
      if(OrderProfit() < 0)
        {
         currentLots *= martingaleMultiplier;
        }
     }

   // Trading logic
   if(trend == 1 && ordersTotal == 0)
     {
      // Open Buy Order
      OrderSend(Symbol(), OP_BUY, currentLots, Ask, 3, 0, 0, "Buy Order", MAGIC_NUMBER, 0, Blue);
     }
   else if(trend == -1 && ordersTotal == 0)
     {
      // Open Sell Order
      OrderSend(Symbol(), OP_SELL, currentLots, Bid, 3, 0, 0, "Sell Order", MAGIC_NUMBER, 0, Red);
     }
  }


*/

//=========================================================================================================================================================


/*

//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict

int MAGIC_NUMBER = 12345;
double initialLotSize = 0.1; // Initial lot size
double martingaleMultiplier = 1.5;
double lotSize = initialLotSize;
double stopLossPips = 50;
double takeProfitPips = 100;

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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Moving averages calculation
   double ma05 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma10 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma15 = iMA(NULL, 0, 15, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma20 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma25 = iMA(NULL, 0, 25, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma30 = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma35 = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma40 = iMA(NULL, 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma45 = iMA(NULL, 0, 45, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma55 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma60 = iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma70 = iMA(NULL, 0, 70, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma75 = iMA(NULL, 0, 75, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma80 = iMA(NULL, 0, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma85 = iMA(NULL, 0, 85, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma90 = iMA(NULL, 0, 90, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma100 = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);

   // Trend determination
   int trend = 0; // 1 for long, -1 for short, 0 for no trend

   if(ma05 > ma100 && ma10 > ma100 && ma15 > ma100 && ma20 > ma100 && ma25 > ma100 && ma30 > ma100 && ma35 > ma100 && ma40 > ma100 && ma45 > ma100 && ma50 > ma100 && ma55 > ma100 && ma60 > ma100 && ma65 > ma100 && ma70 > ma100 && ma75 > ma100 && ma80 > ma100 && ma85 > ma100 && ma90 > ma100)
     {
      trend = 1; // Uptrend
     }
   else if(ma05 < ma100 && ma10 < ma100 && ma15 < ma100 && ma20 < ma100 && ma25 < ma100 && ma30 < ma100 && ma35 < ma100 && ma40 < ma100 && ma45 < ma100 && ma50 < ma100 && ma55 < ma100 && ma60 < ma100 && ma65 < ma100 && ma70 < ma100 && ma75 < ma100 && ma80 < ma100 && ma85 < ma100 && ma90 < ma100)
     {
      trend = -1; // Downtrend
     }
   else
     {
      trend = 0; // No clear trend
     }

   // Martingale logic
   int ordersTotal = OrdersTotal();
   if(ordersTotal > 0)
     {
      // Check last order and apply martingale if it was a loss
      if(OrderSelect(ordersTotal - 1, SELECT_BY_POS))
        {
         if(OrderProfit() < 0)
           {
            lotSize *= martingaleMultiplier;
           }
         else
           {
            lotSize = initialLotSize;
           }
        }
     }

   // Trading logic
   if(trend == 1 && ordersTotal == 0)
     {
      // Open Buy Order
      double sl = Ask - stopLossPips * Point;
      double tp = Ask + takeProfitPips * Point;
      int ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, sl, tp, "Buy Order", MAGIC_NUMBER, 0, Blue);
      if(ticket < 0)
        {
         Print("Error opening BUY order: ", GetLastError());
        }
     }
   else if(trend == -1 && ordersTotal == 0)
     {
      // Open Sell Order
      double sl = Bid + stopLossPips * Point;
      double tp = Bid - takeProfitPips * Point;
      int ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, sl, tp, "Sell Order", MAGIC_NUMBER, 0, Red);
      if(ticket < 0)
        {
         Print("Error opening SELL order: ", GetLastError());
        }
     }
  }
*/
//===================================================================================

/*

//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict

int MAGIC_NUMBER = 12345;
double initialLotSize = 0.1; // Initial lot size
double martingaleMultiplier = 1.5;
double lotSize = initialLotSize;
double stopLossPips = 50;
double takeProfitPips = 100;
datetime lastTradeTime = 0;
int minimumTradeInterval = 3600; // Minimum interval between trades in seconds (e.g., 1 hour)

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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Moving averages calculation
   double ma05 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma10 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma15 = iMA(NULL, 0, 15, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma20 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma25 = iMA(NULL, 0, 25, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma30 = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma35 = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma40 = iMA(NULL, 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma45 = iMA(NULL, 0, 45, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma55 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma60 = iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma70 = iMA(NULL, 0, 70, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma75 = iMA(NULL, 0, 75, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma80 = iMA(NULL, 0, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma85 = iMA(NULL, 0, 85, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma90 = iMA(NULL, 0, 90, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma100 = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);

   // Trend determination
   int trend = 0; // 1 for long, -1 for short, 0 for no trend

   if(ma05 > ma100 && ma10 > ma100 && ma15 > ma100 && ma20 > ma100 && ma25 > ma100 && ma30 > ma100 && ma35 > ma100 && ma40 > ma100 && ma45 > ma100 && ma50 > ma100 && ma55 > ma100 && ma60 > ma100 && ma65 > ma100 && ma70 > ma100 && ma75 > ma100 && ma80 > ma100 && ma85 > ma100 && ma90 > ma100)
     {
      trend = 1; // Uptrend
     }
   else if(ma05 < ma100 && ma10 < ma100 && ma15 < ma100 && ma20 < ma100 && ma25 < ma100 && ma30 < ma100 && ma35 < ma100 && ma40 < ma100 && ma45 < ma100 && ma50 < ma100 && ma55 < ma100 && ma60 < ma100 && ma65 < ma100 && ma70 < ma100 && ma75 < ma100 && ma80 < ma100 && ma85 < ma100 && ma90 < ma100)
     {
      trend = -1; // Downtrend
     }
   else
     {
      trend = 0; // No clear trend
     }

   // Check for open positions
   int buyOrders = 0;
   int sellOrders = 0;
   double currentLots = lotSize;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
           {
            if(OrderType() == OP_BUY)
              buyOrders++;
            else if(OrderType() == OP_SELL)
              sellOrders++;

            // Apply martingale if last order was a loss
            if(OrderProfit() < 0)
              currentLots *= martingaleMultiplier;
           }
        }
     }

   // Trading logic
   if(TimeCurrent() - lastTradeTime >= minimumTradeInterval)
     {
      if(trend == 1 && buyOrders == 0 && sellOrders == 0)
        {
         // Open Buy Order
         double sl = Ask - stopLossPips * Point;
         double tp = Ask + takeProfitPips * Point;
         int ticket = OrderSend(Symbol(), OP_BUY, currentLots, Ask, 3, sl, tp, "Buy Order", MAGIC_NUMBER, 0, Blue);
         if(ticket < 0)
           {
            Print("Error opening BUY order: ", GetLastError());
           }
         else
           {
            lastTradeTime = TimeCurrent(); // Update last trade time
           }
        }
      else if(trend == -1 && buyOrders == 0 && sellOrders == 0)
        {
         // Open Sell Order
         double sl = Bid + stopLossPips * Point;
         double tp = Bid - takeProfitPips * Point;
         int ticket = OrderSend(Symbol(), OP_SELL, currentLots, Bid, 3, sl, tp, "Sell Order", MAGIC_NUMBER, 0, Red);
         if(ticket < 0)
           {
            Print("Error opening SELL order: ", GetLastError());
           }
         else
           {
            lastTradeTime = TimeCurrent(); // Update last trade time
           }
        }
     }
  }
//+------------------------------------------------------------------+

*/

//===========================================================================================



/*
//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict

int MAGIC_NUMBER = 12345;
double initialLotSize = 0.1; // Initial lot size
double martingaleMultiplier = 1.5;
double lotSize = initialLotSize;
double stopLossPips = 50;
double takeProfitPips = 100;
datetime lastTradeTime = 0;

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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Moving averages calculation
   double ma05 = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma10 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma15 = iMA(NULL, 0, 15, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma20 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma25 = iMA(NULL, 0, 25, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma30 = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma35 = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma40 = iMA(NULL, 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma45 = iMA(NULL, 0, 45, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma55 = iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma60 = iMA(NULL, 0, 60, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma70 = iMA(NULL, 0, 70, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma75 = iMA(NULL, 0, 75, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma80 = iMA(NULL, 0, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma85 = iMA(NULL, 0, 85, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma90 = iMA(NULL, 0, 90, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ma100 = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);

   // Trend determination
   int trend = 0; // 1 for long, -1 for short, 0 for no trend

   if(ma05 > ma100 && ma10 > ma100 && ma15 > ma100 && ma20 > ma100 && ma25 > ma100 && ma30 > ma100 && ma35 > ma100 && ma40 > ma100 && ma45 > ma100 && ma50 > ma100 && ma55 > ma100 && ma60 > ma100 && ma65 > ma100 && ma70 > ma100 && ma75 > ma100 && ma80 > ma100 && ma85 > ma100 && ma90 > ma100)
     {
      trend = 1; // Uptrend
     }
   else if(ma05 < ma100 && ma10 < ma100 && ma15 < ma100 && ma20 < ma100 && ma25 < ma100 && ma30 < ma100 && ma35 < ma100 && ma40 < ma100 && ma45 < ma100 && ma50 < ma100 && ma55 < ma100 && ma60 < ma100 && ma65 < ma100 && ma70 < ma100 && ma75 < ma100 && ma80 < ma100 && ma85 < ma100 && ma90 < ma100)
     {
      trend = -1; // Downtrend
     }
   else
     {
      trend = 0; // No clear trend
     }

   // Check for open positions
   int buyOrders = 0;
   int sellOrders = 0;
   double currentLots = lotSize;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
           {
            if(OrderType() == OP_BUY)
              buyOrders++;
            else if(OrderType() == OP_SELL)
              sellOrders++;

            // Apply martingale if last order was a loss
            if(OrderProfit() < 0)
              currentLots *= martingaleMultiplier;
           }
        }
     }

   // Get the current date
   datetime currentDate = TimeCurrent();
   int currentDay = TimeDay(currentDate);
   int currentMonth = TimeMonth(currentDate);
   int currentYear = TimeYear(currentDate);

   // Get the date of the last trade
   int lastTradeDay = TimeDay(lastTradeTime);
   int lastTradeMonth = TimeMonth(lastTradeTime);
   int lastTradeYear = TimeYear(lastTradeTime);

   // Trading logic
   if((currentYear > lastTradeYear) ||
      (currentYear == lastTradeYear && currentMonth > lastTradeMonth) ||
      (currentYear == lastTradeYear && currentMonth == lastTradeMonth && currentDay > lastTradeDay))
     {
      if(trend == 1 && buyOrders == 0 && sellOrders == 0)
        {
         // Open Buy Order
         double sl = Ask - stopLossPips * Point;
         double tp = Ask + takeProfitPips * Point;
         int ticket = OrderSend(Symbol(), OP_BUY, currentLots, Ask, 3, sl, tp, "Buy Order", MAGIC_NUMBER, 0, Blue);
         if(ticket < 0)
           {
            Print("Error opening BUY order: ", GetLastError());
           }
         else
           {
            lastTradeTime = TimeCurrent(); // Update last trade time
           }
        }
      else if(trend == -1 && buyOrders == 0 && sellOrders == 0)
        {
         // Open Sell Order
         double sl = Bid + stopLossPips * Point;
         double tp = Bid - takeProfitPips * Point;
         int ticket = OrderSend(Symbol(), OP_SELL, currentLots, Bid, 3, sl, tp, "Sell Order", MAGIC_NUMBER, 0, Red);
         if(ticket < 0)
           {
            Print("Error opening SELL order: ", GetLastError());
           }
         else
           {
            lastTradeTime = TimeCurrent(); // Update last trade time
           }
        }
     }
  }
//+------------------------------------------------------------------+


*/

//+------------------------------------------------------------------+
//|                                                          MAR.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict
input bool i_exp = true;  // Use Exponential Moving Averages
input double initialLotSize = 0.1; // Initial lot size
double martingaleMultiplier = 1.5;
double lotSize = initialLotSize;
input double stopLossPips = 50;
input double takeProfitPips = 100;
int MAGIC_NUMBER = 12345;
datetime lastTradeTime = 0;
double ma05, ma10, ma15, ma20, ma25, ma30, ma35, ma40, ma45, ma50, ma55, ma60, ma65, ma70, ma75, ma80, ma85, ma90, ma100;
double prevMa05, prevMa10, prevMa15, prevMa20, prevMa25, prevMa30, prevMa35, prevMa40, prevMa45, prevMa50, prevMa55, prevMa60, prevMa65, prevMa70, prevMa75, prevMa80, prevMa85, prevMa90, prevMa100;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize previous MA values to 0
   prevMa05 = 0; prevMa10 = 0; prevMa15 = 0; prevMa20 = 0; prevMa25 = 0;
   prevMa30 = 0; prevMa35 = 0; prevMa40 = 0; prevMa45 = 0; prevMa50 = 0;
   prevMa55 = 0; prevMa60 = 0; prevMa65 = 0; prevMa70 = 0; prevMa75 = 0;
   prevMa80 = 0; prevMa85 = 0; prevMa90 = 0; prevMa100 = 0;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Calculate current MAs
   ma05 = i_exp ? iMA(Symbol(), 0, 5, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma10 = i_exp ? iMA(Symbol(), 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma15 = i_exp ? iMA(Symbol(), 0, 15, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 15, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma20 = i_exp ? iMA(Symbol(), 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma25 = i_exp ? iMA(Symbol(), 0, 25, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 25, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma30 = i_exp ? iMA(Symbol(), 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 30, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma35 = i_exp ? iMA(Symbol(), 0, 35, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 35, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma40 = i_exp ? iMA(Symbol(), 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 40, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma45 = i_exp ? iMA(Symbol(), 0, 45, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 45, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma50 = i_exp ? iMA(Symbol(), 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma55 = i_exp ? iMA(Symbol(), 0, 55, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 55, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma60 = i_exp ? iMA(Symbol(), 0, 60, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 60, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma65 = i_exp ? iMA(Symbol(), 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 65, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma70 = i_exp ? iMA(Symbol(), 0, 70, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 70, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma75 = i_exp ? iMA(Symbol(), 0, 75, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 75, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma80 = i_exp ? iMA(Symbol(), 0, 80, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 80, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma85 = i_exp ? iMA(Symbol(), 0, 85, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 85, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma90 = i_exp ? iMA(Symbol(), 0, 90, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 90, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma100 = i_exp ? iMA(Symbol(), 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0) : iMA(Symbol(), 0, 100, 0, MODE_SMA, PRICE_CLOSE, 0);
   // Trend determination
   int trend = 0; // 1 for long, -1 for short, 0 for no trend
   if(ma05 > ma100 && ma10 > ma100 && ma15 > ma100 && ma20 > ma100 && ma25 > ma100 && ma30 > ma100 && ma35 > ma100 && ma40 > ma100 && ma45 > ma100 && ma50 > ma100 && ma55 > ma100 && ma60 > ma100 && ma65 > ma100 && ma70 > ma100 && ma75 > ma100 && ma80 > ma100 && ma85 > ma100 && ma90 > ma100)
     {
      trend = 1; // Uptrend
     }
   else if(ma05 < ma100 && ma10 < ma100 && ma15 < ma100 && ma20 < ma100 && ma25 < ma100 && ma30 < ma100 && ma35 < ma100 && ma40 < ma100 && ma45 < ma100 && ma50 < ma100 && ma55 < ma100 && ma60 < ma100 && ma65 < ma100 && ma70 < ma100 && ma75 < ma100 && ma80 < ma100 && ma85 < ma100 && ma90 < ma100)
     {
      trend = -1; // Downtrend
     }
   else
     {
      trend = 0; // No clear trend
     }
   // Check for open positions
   int buyOrders = 0;
   int sellOrders = 0;
   double currentLots = lotSize;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
           {
            if(OrderType() == OP_BUY)
              buyOrders++;
            else if(OrderType() == OP_SELL)
              sellOrders++;
            // Apply martingale if last order was a loss
            if(OrderProfit() < 0)
              currentLots *= martingaleMultiplier;
           }
        }
     }
   // Trading logic based on comparison with previous MA values
      if(trend == 1 && buyOrders == 0 && sellOrders == 0)
        {
         if(ma05 < prevMa05 && ma10 < prevMa10 && ma15 < prevMa15 && ma20 < prevMa20 && ma25 < prevMa25 && ma30 < prevMa30 && ma35 < prevMa35 && ma40 < prevMa40 && ma45 < prevMa45 && ma50 < prevMa50 && ma55 < prevMa55 && ma60 < prevMa60 && ma65 < prevMa65 && ma70 < prevMa70 && ma75 < prevMa75 && ma80 < prevMa80 && ma85 < prevMa85 && ma90 < prevMa90)
           {
            // Open Buy Order
            double sl = Ask - stopLossPips * Point;
            double tp = Ask + takeProfitPips * Point;
            int ticket = OrderSend(Symbol(), OP_BUY, currentLots, Ask, 3, sl, tp, "Buy Order", MAGIC_NUMBER, 0, Blue);
            if(ticket < 0)
              {
               Print("Error opening BUY order: ", GetLastError());
              }
            else
              {
               lastTradeTime = TimeCurrent(); // Update last trade time
              }
           }
        }
      else if(trend == -1 && buyOrders == 0 && sellOrders == 0)
        {
         if(ma05 > prevMa05 && ma10 > prevMa10 && ma15 > prevMa15 && ma20 > prevMa20 && ma25 > prevMa25 && ma30 > prevMa30 && ma35 > prevMa35 && ma40 > prevMa40 && ma45 > prevMa45 && ma50 > prevMa50 && ma55 > prevMa55 && ma60 > prevMa60 && ma65 > prevMa65 && ma70 > prevMa70 && ma75 > prevMa75 && ma80 > prevMa80 && ma85 > prevMa85 && ma90 > prevMa90)
           {
            // Open Sell Order
            double sl = Bid + stopLossPips * Point;
            double tp = Bid - takeProfitPips * Point;
            int ticket = OrderSend(Symbol(), OP_SELL, currentLots, Bid, 3, sl, tp, "Sell Order", MAGIC_NUMBER, 0, Red);
            if(ticket < 0)
              {
               Print("Error opening SELL order: ", GetLastError());
              }
            else
              {
               lastTradeTime = TimeCurrent(); // Update last trade time
              }
           }
        }
   // Update previous MA values
   prevMa05 = ma05; prevMa10 = ma10; prevMa15 = ma15; prevMa20 = ma20; prevMa25 = ma25;
   prevMa30 = ma30; prevMa35 = ma35; prevMa40 = ma40; prevMa45 = ma45; prevMa50 = ma50;
   prevMa55 = ma55; prevMa60 = ma60; prevMa65 = ma65; prevMa70 = ma70; prevMa75 = ma75;
   prevMa80 = ma80; prevMa85 = ma85; prevMa90 = ma90; prevMa100 = ma100;
  }
//+------------------------------------------------------------------+