//+------------------------------------------------------------------+
//|                                              RMacDivergence.mq5  |
//|                                               Copyright 2024, NA |
//|                                                               NA |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA"
#property link      "NA"
#property version   "1.00"
#property description "RSI + MACD Divergence Detection"
#include <MovingAverages.mqh>

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3

#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Silver
#property indicator_width1  2
#property indicator_label1  "MACD"

#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_width2  1
#property indicator_label2  "Signal"

#property indicator_type3   DRAW_LINE
#property indicator_color3  Lime
#property indicator_width3  1
#property indicator_label3  "RSI"

//--- input parameters
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input int                InpRSIPeriod=14;             // RSI period
input bool               EnableAlerts=true;           // Enable alerts
input bool               EnableDoubleFilter=false;    // Enable double divergence filter
input bool               EnableTripleFilter=false;    // Enable triple divergence filter

//--- indicator buffers
double ExtMacdBuffer[];
double ExtSignalBuffer[];
double ExtRSIBuffer[];
double ExtFastMaBuffer[];
double ExtSlowMaBuffer[];
int    ExtFastMaHandle;
int    ExtSlowMaHandle;
int    ExtRSIHandle;

datetime lastAlertTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, ExtMacdBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtRSIBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtFastMaBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ExtSlowMaBuffer, INDICATOR_CALCULATIONS);

   //--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpSignalSMA - 1);

   //--- name for indicator subwindow label
   string short_name = StringFormat("RMacDivergence(%d,%d,%d,%d)", InpFastEMA, InpSlowEMA, InpSignalSMA, InpRSIPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);

   //--- get MA handles
   ExtFastMaHandle = iMA(NULL, 0, InpFastEMA, 0, MODE_EMA, InpAppliedPrice);
   ExtSlowMaHandle = iMA(NULL, 0, InpSlowEMA, 0, MODE_EMA, InpAppliedPrice);
   ExtRSIHandle = iRSI(NULL, 0, InpRSIPeriod, InpAppliedPrice);
  }

//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence + RSI                     |
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
   if(rates_total < InpSignalSMA)
      return(0);

   //--- not all data may be calculated
   int calculated = BarsCalculated(ExtFastMaHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return(0);
     }

   calculated = BarsCalculated(ExtSlowMaHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return(0);
     }

   calculated = BarsCalculated(ExtRSIHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of ExtRSIHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return(0);
     }

   //--- we can copy not all data
   int to_copy;
   if(prev_calculated > rates_total || prev_calculated < 0)
      to_copy = rates_total;
   else
     {
      to_copy = rates_total - prev_calculated;
      if(prev_calculated > 0)
         to_copy++;
     }

   //--- get Fast EMA buffer
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtFastMaHandle, 0, 0, to_copy, ExtFastMaBuffer) <= 0)
     {
      Print("Getting fast EMA is failed! Error ", GetLastError());
      return(0);
     }

   //--- get Slow EMA buffer
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtSlowMaHandle, 0, 0, to_copy, ExtSlowMaBuffer) <= 0)
     {
      Print("Getting slow EMA is failed! Error ", GetLastError());
      return(0);
     }

   //--- get RSI buffer
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtRSIHandle, 0, 0, to_copy, ExtRSIBuffer) <= 0)
     {
      Print("Getting RSI is failed! Error ", GetLastError());
      return(0);
     }

   //--- calculate MACD
   int start;
   if(prev_calculated == 0)
      start = 0;
   else
      start = prev_calculated - 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
      ExtMacdBuffer[i] = ExtFastMaBuffer[i] - ExtSlowMaBuffer[i];

   //--- calculate Signal
   SimpleMAOnBuffer(rates_total, prev_calculated, 0, InpSignalSMA, ExtMacdBuffer, ExtSignalBuffer);

   //--- detect divergence and plot arrows
   for(int i = start; i < rates_total; i++)
     {
      // Delete old arrows
      string buy_arrow_name = "BuyArrow" + IntegerToString(i);
      string sell_arrow_name = "SellArrow" + IntegerToString(i);
      ObjectDelete(0, buy_arrow_name);
      ObjectDelete(0, sell_arrow_name);

      if(i >= 2)
        {
         // Bullish divergence: MACD below 0 & divergence with downwards slant
         if(ExtMacdBuffer[i] < 0 && high[i] > high[i-1] && high[i-1] > high[i-2] &&
            ExtMacdBuffer[i] < ExtMacdBuffer[i-1] && ExtMacdBuffer[i-1] < ExtMacdBuffer[i-2] &&
            (EnableDoubleFilter || ExtRSIBuffer[i] < ExtRSIBuffer[i-1]) &&
            (EnableTripleFilter || ExtRSIBuffer[i-1] < ExtRSIBuffer[i-2]))
           {
            ObjectCreate(0, buy_arrow_name, OBJ_ARROW, 0, time[i], low[i] - 10 * Point());
            ObjectSetInteger(0, buy_arrow_name, OBJPROP_COLOR, clrBlue);
            ObjectSetInteger(0, buy_arrow_name, OBJPROP_ARROWCODE, 233);

            if(EnableAlerts && (iTime(_Symbol, PERIOD_CURRENT, 0) != lastAlertTime))
              {
               Alert("Bullish divergence detected. Buy signal.", TimeToString(time[i]));
               lastAlertTime = iTime(_Symbol, PERIOD_CURRENT, 0);
              }
           }

         // Bearish divergence: MACD above 0 & divergence with upwards slant
         if(ExtMacdBuffer[i] > 0 && low[i] < low[i-1] && low[i-1] < low[i-2] &&
            ExtMacdBuffer[i] > ExtMacdBuffer[i-1] && ExtMacdBuffer[i-1] > ExtMacdBuffer[i-2] &&
            (EnableDoubleFilter || ExtRSIBuffer[i] > ExtRSIBuffer[i-1]) &&
            (EnableTripleFilter || ExtRSIBuffer[i-1] > ExtRSIBuffer[i-2]))
           {
            ObjectCreate(0, sell_arrow_name, OBJ_ARROW, 0, time[i], high[i] + 10 * Point());
            ObjectSetInteger(0, sell_arrow_name, OBJPROP_COLOR, clrMagenta);
            ObjectSetInteger(0, sell_arrow_name, OBJPROP_ARROWCODE, 234);

            if(EnableAlerts && (iTime(_Symbol, PERIOD_CURRENT, 0) != lastAlertTime))
              {
               Alert("Bearish divergence detected. Sell signal.", TimeToString(time[i]));
               lastAlertTime = iTime(_Symbol, PERIOD_CURRENT, 0);
              }
           }
        }
     }

   //--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
