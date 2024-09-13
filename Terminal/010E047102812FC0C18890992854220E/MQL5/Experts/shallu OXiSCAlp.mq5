//+------------------------------------------------------------------+
//|                                                       OXiScalp.mq5|
//|                        Copyright 2024, MetaTrader 5              |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

CTrade trade;
input double Lots = 0.1;                   // Lot size
input double ParabolicSARStep = 0.02;      // Parabolic SAR step
input double ParabolicSARMaximum = 0.2;    // Parabolic SAR maximum
input double DailyDrawdownLimit = 3.5;     // Daily drawdown limit in percentage
input double MonthlyDrawdownLimit = 10.0;  // Monthly drawdown limit in percentage
// Indicator handles
int ParabolicSARHandle;
int TEMA14Handle;
int TEMA36Handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialize Parabolic SAR
   ParabolicSARHandle = iSAR(_Symbol, _Period, ParabolicSARStep, ParabolicSARMaximum);
// Initialize TEMA
   TEMA14Handle = iTEMA(_Symbol, _Period, 14, 0, PRICE_CLOSE);
   TEMA36Handle = iTEMA(_Symbol, _Period, 36, 0, PRICE_CLOSE);
// Check for indicator initialization errors
   if(ParabolicSARHandle == INVALID_HANDLE || TEMA14Handle == INVALID_HANDLE || TEMA36Handle == INVALID_HANDLE)
     {
      Print("Failed to initialize indicators");
      return INIT_FAILED;
     }
     
 // Remove indicators from the chart
    ChartIndicatorDelete(0, 0, "Parabolic SAR");
    ChartIndicatorDelete(0, 0, "TEMA 14");
    ChartIndicatorDelete(0, 0, "TEMA 36");
   
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Release indicator handles
   IndicatorRelease(ParabolicSARHandle);
   IndicatorRelease(TEMA14Handle);
   IndicatorRelease(TEMA36Handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double TEMABuffer14[], TEMABuffer36[], ParabolicSARBuffer[];
   if(CopyBuffer(TEMA14Handle, 0, 0, 2, TEMABuffer14) <= 0 ||
      CopyBuffer(TEMA36Handle, 0, 0, 2, TEMABuffer36) <= 0 ||
      CopyBuffer(ParabolicSARHandle, 0, 0, 2, ParabolicSARBuffer) <= 0)
     {
      return ;
     }
   static double lastTEMA14 = 0;
   static double lastTEMA36 = 0;
   double ParabolicSAR = ParabolicSARBuffer[0];
   double TEMA14 = TEMABuffer14[0];
   double TEMA36 = TEMABuffer36[0];
// Check for crossover and Parabolic SAR confirmation
   if(TEMA14 > TEMA36 && lastTEMA14 <= lastTEMA36 && ParabolicSAR < iClose(_Symbol, _Period, 1))
     {
      // Buy signal
      trade.Buy(Lots);
      Print("Buy trade placed");
      ObjectCreate(0, "BuyArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJ_ARROW, 0, TimeCurrent(), iLow(_Symbol, _Period, 0) - 10 * _Point);
      ObjectSetInteger(0, "BuyArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, "BuyArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJPROP_ARROWCODE, 233);
     }
   else if(TEMA14 < TEMA36 && lastTEMA14 >= lastTEMA36 && ParabolicSAR > iClose(_Symbol, _Period, 1))
     {
      // Sell signal
      trade.Sell(Lots);
      Print("Sell trade placed");
      ObjectCreate(0, "SellArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJ_ARROW, 0, TimeCurrent(), iHigh(_Symbol, _Period, 0) + 10 * _Point);
      ObjectSetInteger(0, "SellArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, "SellArrow" + TimeToString(TimeCurrent(), TIME_MINUTES), OBJPROP_ARROWCODE, 234);
     }
// Update last values
   lastTEMA14 = TEMA14;
   lastTEMA36 = TEMA36;
// Implement money management
   static double startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyDrawdown = (startBalance - AccountInfoDouble(ACCOUNT_BALANCE)) / startBalance * 100;
   double monthlyDrawdown = (startBalance - AccountInfoDouble(ACCOUNT_BALANCE)) / startBalance * 100;
   if(dailyDrawdown >= DailyDrawdownLimit || monthlyDrawdown >= MonthlyDrawdownLimit)
     {
      ExpertRemove();
      Print("EA removed due to drawdown limits");
     }
  }
//+------------------------------------------------------------------+
