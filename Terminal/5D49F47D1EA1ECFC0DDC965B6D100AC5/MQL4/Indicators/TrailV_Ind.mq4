//+------------------------------------------------------------------+
//|                                                   TrailV_Ind.mq4 |
//|                                               Elite Forex Trades |
//|                                      https://eliteforextrades.com|
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue

// Input parameters for visualization
input double TrailingGap = 10;    // Gap in pips from bid/ask price
input double TrailingStart = 20;  // Distance in pips from order entry price to start trailing

// Buffers
double TrailingBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, TrailingBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233); // Arrow code for symbol
   IndicatorShortName("TrailV Parameters");
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
   // Ensure there are enough bars to calculate
   if(rates_total < TrailingStart)
     return(0);

   int start = int(TrailingStart); // Ensure TrailingStart is an integer for indexing

   for(int i = start; i < rates_total; i++)
     {
      //  Draw arrow when the price is greater than the trailing start level
      if(close[i] >= close[i - start] + TrailingGap * Point)
        {
         TrailingBuffer[i] = close[i];
        }
      else
        {
         TrailingBuffer[i] = EMPTY_VALUE; // No arrow if condition is not met
        }
     }
   return(rates_total);
  }
