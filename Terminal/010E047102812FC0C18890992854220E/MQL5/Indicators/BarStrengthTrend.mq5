//+------------------------------------------------------------------+
//|                                           BarStrengthTrend.mq5  |
//|                        Copyright 2024, MetaTrader 5 Users        |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2024, MetaTrader 5 Users"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- indicator buffers
double BullishBuffer[];
double BearishBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffers mapping
   SetIndexBuffer(0, BullishBuffer);
   SetIndexBuffer(1, BearishBuffer);
   
   // Set the plot type to histogram
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   
   // Set colors for the plots
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrLime); // Bullish (green)
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);  // Bearish (red)
   
   // Set the width for the plots
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;

   // Calculate BSI for each bar
   for(int i = prev_calculated; i < rates_total; i++)
     {
      // Calculate the Bar Strength Index
      double range = high[i] - low[i];
      double bsi = 0;
      if(range != 0)
         bsi = (close[i] - open[i]) / range;
         
      // Set histogram values based on BSI
      if(bsi >= 0)
        {
         BullishBuffer[i] = bsi;  // Bullish candle strength
         BearishBuffer[i] = 0.0;  // No bearish strength
        }
      else
        { 
         BearishBuffer[i] = -bsi; // Bearish candle strength (negative for correct color)
         BullishBuffer[i] = 0.0;  // No bullish strength
         
        }
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
