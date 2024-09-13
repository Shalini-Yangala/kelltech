//+------------------------------------------------------------------+
//|                                                     OXiScalp.mq5 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"

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
// Variables to track the highest equity for the day and month
double highestDailyEquity;
double highestMonthlyEquity;
datetime startOfDay;
datetime startOfMonth;
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
   if (ParabolicSARHandle == INVALID_HANDLE || TEMA14Handle == INVALID_HANDLE || TEMA36Handle == INVALID_HANDLE)
     {
      Print("Failed to initialize indicators");
      return INIT_FAILED;
     }
     
     // Remove indicators from the chart
    ChartIndicatorDelete(0, 0, "Parabolic SAR");
    ChartIndicatorDelete(0, 0, "TEMA 14");
    ChartIndicatorDelete(0, 0, "TEMA 36");
     
      
   // Initialize equity tracking
   highestDailyEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   highestMonthlyEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   startOfDay = TimeCurrent();
   startOfMonth = TimeCurrent();
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
   // Update highest equity values for daily and monthly tracking
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   if (currentEquity > highestDailyEquity) highestDailyEquity = currentEquity;
   if (currentEquity > highestMonthlyEquity) highestMonthlyEquity = currentEquity;
   // Get current time
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   int currentHour = tm.hour;
   int currentMonth = tm.mon;
   TimeToStruct(startOfDay, tm);
   // Reset daily and monthly tracking at the start of a new day or month
   if (tm.hour != currentHour)
     {
      highestDailyEquity = currentEquity;
      startOfDay = TimeCurrent();
     }
   TimeToStruct(startOfMonth, tm);
   if (tm.mon != currentMonth)
     {
      highestMonthlyEquity = currentEquity;
      startOfMonth = TimeCurrent();
     }
   // Calculate drawdown percentages
   double dailyDrawdown = (highestDailyEquity - currentEquity) / highestDailyEquity * 100;
   double monthlyDrawdown = (highestMonthlyEquity - currentEquity) / highestMonthlyEquity * 100;
   // Check drawdown limits
   if (dailyDrawdown > DailyDrawdownLimit || monthlyDrawdown > MonthlyDrawdownLimit)
     {
      Print("Drawdown limit exceeded. Stopping EA.");
      ExpertRemove();
      return;
     }
   // Buffer arrays
   double TEMABuffer14[2], TEMABuffer36[2], ParabolicSARBuffer[2];
   if (CopyBuffer(TEMA14Handle, 0, 0, 2, TEMABuffer14) <= 0 ||
       CopyBuffer(TEMA36Handle, 0, 0, 2, TEMABuffer36) <= 0 ||
       CopyBuffer(ParabolicSARHandle, 0, 0, 2, ParabolicSARBuffer) <= 0)
     {
      return;
     }
   static double lastTEMA14 = 0;
   static double lastTEMA36 = 0;
   double ParabolicSAR = ParabolicSARBuffer[0];
   double TEMA14 = TEMABuffer14[0];
   double TEMA36 = TEMABuffer36[0];
   // Check for crossover and Parabolic SAR confirmation
   if (TEMA14 > TEMA36 && lastTEMA14 <= lastTEMA36 && ParabolicSAR < iClose(_Symbol, _Period, 1))
     {
      // Buy signal
      if (trade.Buy(Lots))
        {
         string arrowName = "BuyArrow_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
         ObjectCreate(0, arrowName, OBJ_ARROW, 0, iTime(_Symbol, PERIOD_CURRENT, 0), iLow(_Symbol, PERIOD_CURRENT, 0) - 10 * _Point);
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrBlue);
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233);
        }
     }
   else if (TEMA14 < TEMA36 && lastTEMA14 >= lastTEMA36 && ParabolicSAR > iClose(_Symbol, _Period, 1))
     {
      // Sell signal
      if (trade.Sell(Lots))
        {
         string arrowName = "SellArrow_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
         ObjectCreate(0, arrowName, OBJ_ARROW, 0, iTime(_Symbol, PERIOD_CURRENT, 0), iHigh(_Symbol, PERIOD_CURRENT, 0) + 10 * _Point);
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 234);
        }
     }
   // Update last values
   lastTEMA14 = TEMA14;
   lastTEMA36 = TEMA36;
  }
//+------------------------------------------------------------------+

