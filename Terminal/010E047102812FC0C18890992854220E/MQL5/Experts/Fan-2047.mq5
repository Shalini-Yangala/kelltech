//+------------------------------------------------------------------+
//|                                                     Fan-2047.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Trade\Trade.mqh>
//--- trade object
CTrade trade;
// Define input parameters
input double InitialLotSize = 0.1;    // Initial lot size
input double MartingaleFactor = 1.5;  // Martingale factor
input int MaxTrades = 5;              // Maximum number of trades
input int ATRPeriod = 14;             // ATR period
input double ATRMultiplier = 1.5;     // ATR multiplier to detect consolidation
input ENUM_TIMEFRAMES TimeFrame = PERIOD_M5; // Timeframe selection
input double  StopLoss = 20.0;         // Stop loss in points
input double  TakeProfit = 50.0;       // Take profit in points
input int shortPeriod = 50;  // Short-term moving average period
input int longPeriod = 200;  // Long-term moving average period
input ENUM_MA_METHOD maMethod = MODE_SMA; // Moving average method
input int appliedPrice = PRICE_CLOSE; // Applied price
// Variables for trading
double LotSize;
int TradeCount = 0;
bool InConsolidation = false;
// Function to calculate ATR
double CalculateATR(int period)
  {
   return iATR(NULL, TimeFrame, period);
  }
// Function to check if the market is in consolidation
bool CheckConsolidation()
  {
   double atr = CalculateATR(ATRPeriod);
   double avgRange = atr * ATRMultiplier;
// Define consolidation as low volatility (low ATR)
   if(atr < avgRange)
     {
      Print("Market is in consolidation. ATR: ", atr, " AvgRange: ", avgRange);
      return true;
     }
   Print("Market is not in consolidation. ATR: ", atr, " AvgRange: ", avgRange);
   return false;
  }
//+------------------------------------------------------------------+
//|    Function to calculate and draw high Gann Fan level            |
//+------------------------------------------------------------------+
void CalculateHighGannfan()
  {
   int candleOnChart = Bars(_Symbol, _Period);
   int HighestCandle = iHighest(_Symbol, _Period, MODE_HIGH, candleOnChart, 0);
   ObjectCreate(0, "SimpleHighGannFan", OBJ_GANNFAN, 0,
                iTime(_Symbol,_Period,HighestCandle),iHigh(_Symbol,_Period,HighestCandle),
                iTime(_Symbol,_Period,0), iHigh(_Symbol,_Period,0));
   ObjectSetInteger(0, "SimpleHighGannFan", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "SimpleHighGannFan", OBJPROP_RAY, true);
  }
//+------------------------------------------------------------------+
//|    Function to calculate and draw low Gann Fan level             |
//+------------------------------------------------------------------+
void CalculateLowGannfan()
  {
   int candleOnChart = Bars(_Symbol, _Period);
   int LowestCandle = iLowest(_Symbol, _Period, MODE_LOW, candleOnChart, 0);
   ObjectCreate(0, "SimpleLowGannFan", OBJ_GANNFAN, 0,
                iTime(_Symbol,_Period,LowestCandle),iLow(_Symbol,_Period,LowestCandle),
                iTime(_Symbol,_Period,0), iLow(_Symbol,_Period,0));
   ObjectSetInteger(0, "SimpleLowGannFan", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "SimpleLowGannFan", OBJPROP_RAY, true);
  } 
//+------------------------------------------------------------------+
//|    Function to calculate and draw high Fibonacci Fan level       |
//+------------------------------------------------------------------+
void CalculateHighFibofan()
  {
   int candleOnChart = Bars(_Symbol, _Period);
   int HighestCandle = iHighest(_Symbol, _Period, MODE_HIGH, candleOnChart, 0);
   ObjectCreate(0, "SimpleHighFibofan", OBJ_FIBOFAN, 0,
                iTime(_Symbol,_Period,HighestCandle),iHigh(_Symbol,_Period,HighestCandle),
                iTime(_Symbol,_Period,0), iHigh(_Symbol,_Period,0));
   ObjectSetInteger(0, "SimpleHighFibofan", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "SimpleHighFibofan", OBJPROP_RAY, true);
  }
//+------------------------------------------------------------------+
//|    Function to calculate and draw low Fibonacci Fan level        |
//+------------------------------------------------------------------+
void CalculateLowFibofan()
  {
   int candleOnChart = Bars(_Symbol, _Period);
   int LowestCandle = iLowest(_Symbol, _Period, MODE_LOW, candleOnChart, 0);
   ObjectCreate(0, "SimpleLowFibofan", OBJ_FIBOFAN, 0,
                iTime(_Symbol,_Period,LowestCandle),iLow(_Symbol,_Period,LowestCandle),
                iTime(_Symbol,_Period,0), iLow(_Symbol,_Period,0));
   ObjectSetInteger(0, "SimpleLowFibofan", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "SimpleLowFibofan", OBJPROP_RAY, true);
  } 
// Function to detect crossover between Gann Fan and Fibonacci Fan
bool DetectCrossover(bool &isBuySignal)
  {
   double shortMA = iMA(NULL, 0, shortPeriod, 0, maMethod, appliedPrice);
   double longMA = iMA(NULL, 0, longPeriod, 0, maMethod, appliedPrice);

   if (shortMA > longMA)
     {
      isBuySignal = true;
      Print("Uptrend detected, drawing high Gann Fan and high Fibonacci Fan.");
      CalculateHighGannfan();
      CalculateHighFibofan();
      return true;
     }
   else if (shortMA < longMA)
     {
      isBuySignal = false;
      Print("Downtrend detected, drawing low Gann Fan and low Fibonacci Fan.");
      CalculateLowGannfan();
      CalculateLowFibofan();
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceOrder(bool isBuy, double lotSize)
  {
   double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = isBuy ? price - StopLoss * _Point : price + StopLoss * _Point;
   double tp = isBuy ? price + TakeProfit * _Point : price - TakeProfit * _Point;
   if(isBuy)
     {
      if(trade.Buy(lotSize, _Symbol, price, sl, tp, "Buy Order"))
        {
         Print("Buy order placed successfully. LotSize: ", lotSize, " Price: ", price, " SL: ", sl, " TP: ", tp);
         TradeCount++;
        }
      else
        {
         Print("Failed to place buy order. Error: ", GetLastError());
        }
     }
   else
     {
      if(trade.Sell(lotSize, _Symbol, price, sl, tp, "Sell Order"))
        {
         Print("Sell order placed successfully. LotSize: ", lotSize, " Price: ", price, " SL: ", sl, " TP: ", tp);
         TradeCount++;
        }
      else
        {
         Print("Failed to place sell order. Error: ", GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderExists(bool isBuy)
  {
   int totalOrders = PositionsTotal();
   for(int i = 0; i < totalOrders; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket != -1)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_TYPE) == (isBuy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL))
           {
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   LotSize = InitialLotSize;
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
   InConsolidation = CheckConsolidation();
   if(InConsolidation)
     {
      bool isBuySignal = false;
      if(DetectCrossover(isBuySignal))
        {
         if(!OrderExists(isBuySignal) && TradeCount < MaxTrades)
           {
            PlaceOrder(isBuySignal, LotSize);
           }
         else
           {
            Print("Order already exists or max trades reached. TradeCount: ", TradeCount);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert trade event function                                      |
//+------------------------------------------------------------------+
void OnTrade()
  {
// Check for closed trades and reset LotSize if necessary
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      if(HistoryDealSelect(i))
        {
         if(HistoryDealGetString(i, DEAL_SYMBOL) == Symbol() && HistoryDealGetInteger(i, DEAL_MAGIC) == 0)
           {
            if(HistoryDealGetInteger(i, DEAL_ENTRY) == DEAL_ENTRY_OUT)
              {
               double profit = HistoryDealGetDouble(i, DEAL_PROFIT);
               if(profit < 0)
                 {
                  // Apply martingale factor on next trade
                  LotSize *= MartingaleFactor;
                  Print("Loss detected. Increasing lot size to: ", LotSize);
                 }
               else
                 {
                  // Reset lot size on profit
                  LotSize = InitialLotSize;
                  Print("Profit detected. Resetting lot size to: ", LotSize);
                 }
               TradeCount--;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+