//+------------------------------------------------------------------+
//|                                                   TiltTrader.mq5 |
//|                                        Copyright 2024, Fx Empire |
//|                                        https://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Fx Empire"
#property link      "https://www.fxempire.com/"
#property version   "1.00"

#include <Trade\Trade.mqh>
// Input Parameters
input double RiskPercent = 1.0; // Risk per trade as a percentage of account balance
input int MaxTradesPerDay = 7;  // Maximum trades per day
input int MaxActiveTrades = 3;  // Maximum active trades at a time
input int ChannelPeriod = 50; // Period to calculate the channel
input int WedgePeriod = 50;   // Period to calculate the wedge
int tradeCount = 0;
int activeTrades = 0;
datetime lastTradeDay;
CTrade trade;
double highestHigh1, lowestLow1;
double askPrice1, bidPrice1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   askPrice1 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bidPrice1 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   tradeCount = 0;
   activeTrades = 0;
   lastTradeDay = 0;
   // Draw the channel and wedges for the specified periods
   DrawChannel(ChannelPeriod);
   DrawWedge(WedgePeriod, true);
   DrawWedge(WedgePeriod, false);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Remove graphical objects
   ObjectDelete(0, "UpperChannelObject");
   ObjectDelete(0, "RisingWedge");
   ObjectDelete(0, "FallingWedge");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentDay = TimeCurrent() / 86400;
   if (currentDay != lastTradeDay)
     {
      tradeCount = 0;
      activeTrades = 0;
      lastTradeDay = currentDay;
     }
   // Check the maximum total trades and active trades
   if (tradeCount < MaxTradesPerDay && activeTrades < MaxActiveTrades)
     {
      // placeholder for trade logic
      bool breakoutDetected = CheckForBreakout();
      if (breakoutDetected)
        {
         // Place the trade
         double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
         PlaceTrade(riskAmount);
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to check for breakout                                   |
//+------------------------------------------------------------------+
bool CheckForBreakout()
  {
   double highestHigh = ObjectGetDouble(0, "UpperChannelObject", OBJPROP_PRICE);
   askPrice1 = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bidPrice1 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if (askPrice1 > highestHigh) // Buy trade condition
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Function to place a trade                                        |
//+------------------------------------------------------------------+
void PlaceTrade(double riskAmount)
  {
   double lotSize = riskAmount / 1000.0; // Example calculation for lot size
   lotSize = NormalizeDouble(lotSize, 2);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   if (askPrice1 > highestHigh1) // Buy condition
     {
      if (trade.Buy(lotSize, _Symbol, askPrice, 0, 0, "TradeEA"))
        {
         tradeCount++;
         activeTrades++;
         Print("Trade placed successfully, ticket: ", trade.ResultOrder());
        }
      else
        {
         Print("Failed to place trade: ", GetLastError());
        }
     }
   else if (bidPrice1 < lowestLow1) // Sell condition
     {
      if (trade.Sell(lotSize, _Symbol, bidPrice, 0, 0, "TradeEA"))
        {
         tradeCount++;
         activeTrades++;
         Print("Trade placed successfully, ticket: ", trade.ResultOrder());
        }
      else
        {
         Print("Failed to place trade: ", GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to draw the channel                                     |
//+------------------------------------------------------------------+
void DrawChannel(int period)
  {
   int limit = 50;  // Number of candles to consider for the channel
   int CandleOnChart = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR, 0);
   int startBar = MathMax(0, CandleOnChart - limit + 1); // Start from this bar
   int endBar = CandleOnChart;  // End at this bar
   double Low[];
   double High[];
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(High, true);
   // Copy low and high prices of the last `limit` candles
   CopyLow(_Symbol, _Period, startBar, limit, Low);
   CopyHigh(_Symbol, _Period, startBar, limit, High);
   // Find the lowest low and highest high within the specified candles
   int LowestCandle = ArrayMinimum(Low, 0, limit - 1);
   int HighestCandle = ArrayMaximum(High, 0, limit - 1);
   MqlRates PriceInformation[];
   ArraySetAsSeries(PriceInformation, true);
   // Copy the necessary price information for object creation
   int Data = CopyRates(_Symbol, _Period, startBar, limit, PriceInformation);
   // Delete the existing object if it exists
   ObjectDelete(_Symbol, "UpperChannelObject");
   // Create the channel object based on the extracted data
   double startingPrice = PriceInformation[LowestCandle].low;
   double endingPrice = PriceInformation[HighestCandle].high;
   // Use the time of the current candle for starting point
   datetime startTime = PriceInformation[limit - 1].time;
   datetime endTime = PriceInformation[LowestCandle].time;
   ObjectCreate(_Symbol, "UpperChannelObject", OBJ_STDDEVCHANNEL, 0,
                startTime, startingPrice,
                endTime, endingPrice,
                startTime, endingPrice);
   // Set properties for the channel object
   ObjectSetInteger(0, "UpperChannelObject", OBJPROP_COLOR, Red);
   ObjectSetDouble(0, "UpperChannelObject", OBJPROP_DEVIATION, 2);
   ObjectSetInteger(0, "UpperChannelObject", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "UpperChannelObject", OBJPROP_RAY_RIGHT, true);
  }
//+------------------------------------------------------------------+
//| Function to draw the wedges                                      |
//+------------------------------------------------------------------+
void DrawWedge(int period, bool isRising)
  {
   int bars = MathMin(period, iBars(NULL, 0) - 1);
   if (bars <= 0)
      return;
   int upperStart = 0, upperEnd = 0;
   double upperStartPrice = iHigh(_Symbol, 0, upperStart);
   double upperEndPrice = iHigh(_Symbol, 0, upperEnd);
   int lowerStart = 0, lowerEnd = 0;
   double lowerStartPrice = iLow(_Symbol, 0, lowerStart);
   double lowerEndPrice = iLow(_Symbol, 0, lowerEnd);
   for (int i = 1; i < bars; i++)
     {
      double high = iHigh(_Symbol, 0, i);
      double low = iLow(_Symbol, 0, i);
      if (high > upperStartPrice)
        {
         upperEnd = upperStart;
         upperEndPrice = upperStartPrice;
         upperStart = i;
         upperStartPrice = high;
        }
      else if (high > upperEndPrice)
        {
         upperEnd = i;
         upperEndPrice = high;
        }
      if (low < lowerStartPrice)
        {
         lowerEnd = lowerStart;
         lowerEndPrice = lowerStartPrice;
         lowerStart = i;
         lowerStartPrice = low;
        }
      else if (low < lowerEndPrice)
        {
         lowerEnd = i;
         lowerEndPrice = low;
        }
     }
   datetime upperStartTime = iTime(_Symbol, 0, upperStart);
   datetime upperEndTime = iTime(_Symbol, 0, upperEnd);
   datetime lowerStartTime = iTime(_Symbol, 0, lowerStart);
   datetime lowerEndTime = iTime(_Symbol, 0, lowerEnd);
   string wedgeName = isRising ? "RisingWedge" : "FallingWedge";
   // Draw wedge
   if (ObjectFind(0, wedgeName) == INVALID_HANDLE)
     {
      if (!ObjectCreate(0, wedgeName, OBJ_TRIANGLE, 0, upperStartTime, upperStartPrice, lowerStartTime, lowerStartPrice, lowerEndTime, lowerEndPrice))
        {
         Print("Failed to create ", wedgeName, ": ", GetLastError());
        }
     }
   else
     {
      ObjectMove(0, wedgeName, 0, upperStartTime, upperStartPrice);
      ObjectMove(0, wedgeName, 1, lowerStartTime, lowerStartPrice);
      ObjectMove(0, wedgeName, 2, lowerEndTime, lowerEndPrice);
     }
   ObjectSetInteger(0, wedgeName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, wedgeName, OBJPROP_WIDTH, 2);
  }
//+-----------------------------------------------------------------