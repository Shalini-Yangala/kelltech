//+------------------------------------------------------------------+
//|                                                   MacHi-3023.mq5 |
//|                                   Copyright 2024, Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"
#property strict
#include <Trade/Trade.mqh>
// Input variables
input double LotSize = 0.1;
input double StopLoss = 50;            // Stop loss in points
input double TakeProfit = 50;          // Take profit in points
input double DailyDrawdownLimit = 3.0; // Daily drawdown limit percentage
input double MonthlyDrawdownLimit = 8.0; // Monthly drawdown limit percentage
input string JPYPairs = "USDJPY,EURJPY,GBPJPY,AUDJPY,CADJPY"; // JPY pairs as input
input int FastEMAPeriod = 12;          // Fast EMA period for MACD
input int SlowEMAPeriod = 26;          // Slow EMA period for MACD
input int SignalPeriod = 9;            // Signal period for MACD
input int ChaikinShortPeriod = 3;      // Short period for Chaikin Oscillator
input int ChaikinLongPeriod = 10;      // Long period for Chaikin Oscillator
// Global variables
double maxBalance;
double dailyEquityLow;
double monthlyEquityLow;
datetime lastTradeTime = 0; // To store the time of the last trade
// Handles for indicators
int MACDHandle;
int ChaikinHandle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialize indicators
   MACDHandle = iMACD(_Symbol, _Period, FastEMAPeriod, SlowEMAPeriod, SignalPeriod, PRICE_CLOSE);
   ChaikinHandle = iChaikin(_Symbol, _Period, ChaikinShortPeriod, ChaikinLongPeriod,MODE_SMA, VOLUME_TICK);
// Check if the handles are valid
   if(MACDHandle == INVALID_HANDLE || ChaikinHandle == INVALID_HANDLE)
     {
      Print("Error initializing indicators.");
      return(INIT_FAILED);
     }
// Initialize max balance with the current account balance
   maxBalance = AccountInfoDouble(ACCOUNT_BALANCE);
// Set the timer to check every minute
   EventSetTimer(60);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Clean up
   EventKillTimer();
// Release indicator handles
   IndicatorRelease(MACDHandle);
   IndicatorRelease(ChaikinHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check and update drawdown limits
   UpdateDrawdown();
// Calculate MACD and Chaikin Oscillator values
   double macdValue[3];
   double chaikinValue[1];
   if(CopyBuffer(MACDHandle, 0, 0, 3, macdValue) <= 0 || CopyBuffer(ChaikinHandle, 0, 0, 1, chaikinValue) <= 0)
     {
      Print("Error fetching indicator values.");
      return;
     }
   double macdLine = macdValue[0];
   double signalLine = macdValue[1];
   double histogram = macdValue[2];
// Check entry conditions based on MACD and Chaikin Oscillator
   if(IsCorrelatedWithJPY(_Symbol) && PositionsTotal() == 0)
     {
      if(macdLine > signalLine && chaikinValue[0] > 0)
        {
         // Place buy trade
         ExecuteBuy();
        }
      else
         if(macdLine < signalLine && chaikinValue[0] < 0)
           {
            // Place sell trade
            ExecuteSell();
           }
     }
  }
//+------------------------------------------------------------------+
//| Function to update daily and monthly drawdown                     |
//+------------------------------------------------------------------+
void UpdateDrawdown()
  {
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
// Update daily drawdown
   if(currentEquity < dailyEquityLow || dailyEquityLow == 0.0)
     {
      dailyEquityLow = currentEquity;
     }
   double dailyDrawdown = (maxBalance - currentEquity) / maxBalance * 100.0;
// Check daily drawdown limit
   if(dailyDrawdown >= DailyDrawdownLimit)
     {
      Print("Daily drawdown limit exceeded. Trading halted for today.");
      ExpertRemove();
     }
// Update monthly drawdown
   if(currentEquity < monthlyEquityLow || monthlyEquityLow == 0.0)
     {
      monthlyEquityLow = currentEquity;
     }
   double monthlyDrawdown = (maxBalance - currentEquity) / maxBalance * 100.0;
// Check monthly drawdown limit
   if(monthlyDrawdown >= MonthlyDrawdownLimit)
     {
      Print("Monthly drawdown limit exceeded. Trading halted for the month.");
      ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
//| Function to execute a buy trade                                   |
//+------------------------------------------------------------------+
void ExecuteBuy()
  {
   if(PositionsTotal() == 0)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      // Place buy order
      CTrade trade;
      if(trade.Buy(LotSize, _Symbol, ask, ask - StopLoss * _Point, ask + TakeProfit * _Point))
        {
         lastTradeTime = TimeCurrent(); // Update the last trade time on successful trade
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to execute a sell trade                                  |
//+------------------------------------------------------------------+
void ExecuteSell()
  {
   if(PositionsTotal() == 0)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      // Place sell order
      CTrade trade;
      if(trade.Sell(LotSize, _Symbol, bid, bid + StopLoss * _Point, bid - TakeProfit * _Point))
        {
         lastTradeTime = TimeCurrent(); // Update the last trade time on successful trade
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to check if symbol correlates with JPY                   |
//+------------------------------------------------------------------+
bool IsCorrelatedWithJPY(string symbol)
  {
   string pairs[];
   int totalPairs = StringSplit(JPYPairs, ',', pairs);
   for(int i = 0; i < totalPairs; i++)
     {
      if(symbol == pairs[i])
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+