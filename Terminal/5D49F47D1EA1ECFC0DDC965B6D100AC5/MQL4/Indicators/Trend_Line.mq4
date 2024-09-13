//+------------------------------------------------------------------+
//|                                                   Trend_Line.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

//---Global Variables
input int lookBackPeriod_recent = 50;
input int lookBackPeriod_global= 200;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
//---Nothing here
  }
/*
//----Custom Function to check Pivot Points
void cal()
  {
   double test = iFractals(NULL, 0, MODE_UPPER, 100);
   printf(test);
  }
  */
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,"Local Resistance");
   ObjectDelete(0,"Local Support");
   ObjectDelete(0,"Global Resistance");
   ObjectDelete(0,"Global Support");
   ObjectDelete(0,"Trend");
  }
 
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   double localHigh = FindHighestFractal(lookBackPeriod_recent);
   double localLow = FindLowestFractal(lookBackPeriod_recent);
   double globalHigh = FindHighestFractal(lookBackPeriod_global);
   double globalLow = FindLowestFractal(lookBackPeriod_global);
   string localHighTime = FindHighestFractalTime(lookBackPeriod_recent);
   string localLowTime = FindLowestFractalTime(lookBackPeriod_recent);
   string globalHighTime = FindHighestFractalTime(lookBackPeriod_global);
   string globalLowTime = FindLowestFractalTime(lookBackPeriod_global);
   datetime globalHighTime1 = StrToTime(globalHighTime);
   datetime localHighTime1 = StrToTime(localHighTime);
   datetime globalLowTime1 = StrToTime(globalLowTime);
   datetime localLowTime1 = StrToTime(localLowTime);
   //Print(globalHighTime1,"---",localHighTime1);
   //Print("Trend:"+"--"+globalLowTime1+"--"+globalLow+"--"+localLowTime1+"---"+localLow);
   datetime cTime = TimeCurrent();  // Specify the time where you want to draw the line, or use any specific time
   DrawHorizontalLine("Local Resistance", localHigh, 0, cTime, 255);
   DrawHorizontalLine("Local Support", 0, localLow, cTime, 65280);
   DrawHorizontalLine("Global Resistance", globalHigh, 0, cTime, 255);
   DrawHorizontalLine("Global Support", 0, globalLow, cTime, 65280);
   DrawTrendLine("Trend",globalHighTime1,globalHigh,localHighTime1,localHigh,clrBlue);
   DrawTrendLine("Trend1",globalLowTime1,globalLow,localLowTime1,localLow,clrBlue);
   //DrawTrendLine("Trend",globalLowTime1,globalLow,localLowTime1,localLow,clrBlue);
   return (rates_total);
  }
//+------------------------------------------------------------------+
double FindHighestFractal(int count)
  {
   double highestFractal = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
     {
      double upper = iFractals(NULL, 0, MODE_UPPER, i);
      if(upper != 0.0 && (highestFractal == EMPTY_VALUE || upper > highestFractal))
        {
         highestFractal = upper;
        }
     }
   return highestFractal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindHighestFractalTime(int count)
  {
   double highestFractal = EMPTY_VALUE;
   string timeStamp1 = "";
   for(int i = 0; i < count; i++)
     {
      double upper = iFractals(NULL, 0, MODE_UPPER, i);
      if(upper != 0.0 && (highestFractal == EMPTY_VALUE || upper > highestFractal))
        {
         highestFractal = upper;
         string day = IntegerToString(TimeDay(Time[i]));
         string year=IntegerToString(TimeYear(Time[i]));
         string month=IntegerToString(TimeMonth(Time[i]));
         string hour=IntegerToString(TimeHour(Time[i]));
         string minute=IntegerToString(TimeMinute(Time[i]));
         string seconds=IntegerToString(TimeSeconds(Time[i]));
         timeStamp1=year+"/"+month+"/"+day+" "+hour+":"+minute+":"+seconds;
        }
     }
   return timeStamp1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLowestFractal(int count)
  {
   double lowestFractal = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
     {
      double lower = iFractals(NULL, 0, MODE_LOWER, i);
      if(lower != 0.0 && (lowestFractal == EMPTY_VALUE || lower < lowestFractal))
        {
         lowestFractal = lower;
        }
     }
   return lowestFractal;
  }
string FindLowestFractalTime(int count)
  {
   double lowestFractal = EMPTY_VALUE;
   string timeStamp2="";
   for(int i = 0; i < count; i++)
     {
      double lower = iFractals(NULL, 0, MODE_LOWER, i);
      if(lower != 0.0 && (lowestFractal == EMPTY_VALUE || lower < lowestFractal))
        {
         lowestFractal = lower;
         string day = IntegerToString(TimeDay(Time[i]));
         string year=IntegerToString(TimeYear(Time[i]));
         string month=IntegerToString(TimeMonth(Time[i]));
         string hour=IntegerToString(TimeHour(Time[i]));
         string minute=IntegerToString(TimeMinute(Time[i]));
         string seconds=IntegerToString(TimeSeconds(Time[i]));
         timeStamp2=year+"/"+month+"/"+day+" "+hour+":"+minute+":"+seconds;
        }
     }
   return timeStamp2;
  }
//+------------------------------------------------------------------+
void DrawHorizontalLine(string lineName_ = "Line", double priceHigh = 0,
                        double priceLow = 0, datetime time = 0, color lineColor = 65280)
  {
   if(priceLow == 0)
     {
      string lineName = lineName_ + DoubleToStr(priceHigh, Digits);
      ObjectCreate(0, lineName, OBJ_HLINE, 0, time, priceHigh);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
     }
   else
      if(priceHigh == 0)
        {
         string lineName__ = lineName_ + DoubleToStr(priceLow, Digits);
         ObjectCreate(0, lineName__, OBJ_HLINE, 0, time, priceLow);
         ObjectSetInteger(0, lineName__, OBJPROP_COLOR, lineColor);
        }
  }
//+------------------------------------------------------------------+
//-------TRENDLINES
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(string lineName, datetime X1_time, double Y1_Price, datetime X2_time, double Y2_Price, color lineColor)
  {
// Calculate slope and intercept of the trendline
   datetime var1 = X2_time - X1_time;
   if(var1>0)
     {
      double slope = (Y2_Price - Y1_Price) / var1;
      double intercept = Y1_Price - slope * X1_time;
      // Extend trendline into the future
      datetime futureX = X2_time + PeriodSeconds() * 50;
      double futureY = slope * futureX + intercept;
      // Draw the trendline
      ObjectCreate(0, lineName, OBJ_TREND, 0, X1_time, Y1_Price, futureX, futureY);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
     }
  }
//+------------------------------------------------------------------+
