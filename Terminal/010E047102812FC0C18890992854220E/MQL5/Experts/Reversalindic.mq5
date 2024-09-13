//+------------------------------------------------------------------+
//|                                                Reversalindic.mq5 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

// Input parameters for the EA
input int SMA_Period = 20;                // Period for Simple Moving Average (SMA)
input int RSI_Period = 14;                // Period for Relative Strength Index (RSI)
input double RSI_Oversold = 30;           // RSI level considered oversold
input double RSI_Overbought = 70;         // RSI level considered overbought
input double StdDev_Multiplier = 2.0;     // Multiplier for Standard Deviation to set entry levels
input double lot_size = 0.1;              // Lot size for trades

// Asian market hours (e.g., 00:00 to 08:00 server time)
input int Asian_Hour_Start = 0;           // Start hour of the Asian market session
input int Asian_Hour_End = 8;             // End hour of the Asian market session

double Ask, Bid;                         // Variables to store the current Ask and Bid prices

int sma_handle, stddev_handle, rsi_handle; // Handles for the indicators
// Indicator buffers to store calculated values
double SMA_Buffer[];
double StdDev_Buffer[];
double RSI_Buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create handles for the indicators
   sma_handle = iMA(_Symbol, _Period, SMA_Period, 0, MODE_SMA, PRICE_CLOSE);
   stddev_handle = iStdDev(_Symbol, _Period, SMA_Period, 0, MODE_SMA, PRICE_CLOSE);
   rsi_handle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);

   // Check if indicator handles are created successfully
   if(sma_handle <= 0 || stddev_handle <= 0 || rsi_handle <= 0)
     {
      Print("Failed to create indicator handles.");
      return INIT_FAILED;
     }

   // Add indicators to the chart
   ChartIndicatorAdd(0, 0, sma_handle);
   ChartIndicatorAdd(0, 1, stddev_handle);
   ChartIndicatorAdd(0, 2, rsi_handle);

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Release indicator handles when the EA is removed
   IndicatorRelease(sma_handle);
   IndicatorRelease(stddev_handle);
   IndicatorRelease(rsi_handle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Get the current server time
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   int hour = tm.hour;

   // Trade only during Asian market hours
   if(hour < Asian_Hour_Start || hour > Asian_Hour_End)
     {
      Print("Not in Asian market hours");
      return;
     }

   // Ensure the EA is trading EURUSD on the M5 chart
   if(_Symbol != "EURUSD" || _Period != PERIOD_M5)
     {
      Print("Not trading EURUSD on M5 timeframe");
      return;
     }

   // Retrieve indicator values
   if(CopyBuffer(sma_handle, 0, 0, 3, SMA_Buffer) <= 0 ||
      CopyBuffer(stddev_handle, 0, 0, 3, StdDev_Buffer) <= 0 ||
      CopyBuffer(rsi_handle, 0, 0, 3, RSI_Buffer) <= 0)
     {
      Print("Failed to retrieve indicator data");
      return;
     }

   // Calculate current values for indicators
   double sma = SMA_Buffer[0];
   double stddev = StdDev_Buffer[0];
   double rsi = RSI_Buffer[0];

   double openPrice = iOpen(_Symbol, _Period, 0);   // Current open price of the candle
   double closePrice = iClose(_Symbol, _Period, 0); // Current close price of the candle

   // Define entry levels based on SMA and Standard Deviation
   double buyEntryLevel = sma - StdDev_Multiplier * stddev;
   double sellEntryLevel = sma + StdDev_Multiplier * stddev;

   // Retrieve the current Ask and Bid prices
   double ask = NormalizeDouble(Ask, _Digits);
   double bid = NormalizeDouble(Bid, _Digits);

   // Check for buy signal
   if(openPrice < buyEntryLevel && rsi < RSI_Oversold && closePrice > buyEntryLevel && rsi > RSI_Oversold)
     {
      double tp = NormalizeDouble(ask + StdDev_Multiplier * stddev, _Digits); // Take Profit level
      double sl = NormalizeDouble(ask - stddev, _Digits);                      // Stop Loss level

      // Attempt to open a buy trade
      if(trade.Buy(lot_size, NULL, ask, sl, tp, "Buy Signal"))
        {
         // Create a green arrow on the chart to indicate a buy signal
         string objName = "BuyArrow_" + IntegerToString(TimeCurrent());
         ObjectCreate(0, objName, OBJ_ARROW, 0, TimeCurrent(), closePrice);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGreen);
         ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 233);  // Arrow up
        }
      else
        {
         Print("Buy order failed: Error = ", GetLastError());
        }
     }
   else
     {
      Print("Buy condition not met");
     }

   // Check for sell signal
   if(openPrice > sellEntryLevel && rsi > RSI_Overbought && closePrice < sellEntryLevel && rsi < RSI_Overbought)
     {
      double tp = NormalizeDouble(bid - StdDev_Multiplier * stddev, _Digits); // Take Profit level
      double sl = NormalizeDouble(bid + stddev, _Digits);                      // Stop Loss level

      // Attempt to open a sell trade
      if(trade.Sell(lot_size, NULL, bid, sl, tp, "Sell Signal"))
        {
         // Create a red arrow on the chart to indicate a sell signal
         string objName = "SellArrow_" + IntegerToString(TimeCurrent());
         ObjectCreate(0, objName, OBJ_ARROW, 0, TimeCurrent(), closePrice);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 234);  // Arrow down
        }
      else
        {
         Print("Sell order failed: Error = ", GetLastError());
        }
     }
   else
     {
      Print("Sell condition not met");
     }

   // Close buy position if the condition is met
   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && closePrice > sellEntryLevel)
        {
         Print("Closing Buy position");
         trade.PositionClose(_Symbol);
        }
      // Close sell position if the condition is met
      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && closePrice < buyEntryLevel)
        {
         Print("Closing Sell position");
         trade.PositionClose(_Symbol);
        }
     }
  }

//+------------------------------------------------------------------+
