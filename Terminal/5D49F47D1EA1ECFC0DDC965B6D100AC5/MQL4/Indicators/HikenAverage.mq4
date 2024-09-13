
//+------------------------------------------------------------------+
//|                                                 HikenAverage.mq4 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red   // Color for Heikin-Ashi Open (Dotted Line)
#property indicator_color2 Blue  // Color for Heikin-Ashi Close (Solid Line)

//--- indicator buffers
double haOpenBuffer[];
double haCloseBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffers setup
   SetIndexBuffer(0, haOpenBuffer);
   SetIndexBuffer(1, haCloseBuffer);

   // Setting the style for the indicator lines
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, clrRed);   // Heikin-Ashi Open as dotted line
   SetIndexLabel(0, "Heikin-Ashi Open");

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrBlue); // Heikin-Ashi Close as solid line
   SetIndexLabel(1, "Heikin-Ashi Close");

   // Set indicator properties
   IndicatorShortName("HikenAverage (Heikin-Ashi Open & Close Lines)");

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
   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   // Check if there are enough bars
   if (rates_total < 2)
      return (0);

   // Calculate Heikin-Ashi values
   for (int i = start; i < rates_total; i++)
     {
      // Calculate Heikin-Ashi Close
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4;

      // Calculate Heikin-Ashi Open
      double haOpen;
      if (i == 0)
        {
         haOpen = (open[i] + close[i]) / 2; // Initial value
        }
      else
        {
         haOpen = (haOpenBuffer[i - 1] + haCloseBuffer[i - 1]) / 2;
        }

      // Store values in buffers
      haOpenBuffer[i] = haOpen;
      haCloseBuffer[i] = haClose;
     }

   return (rates_total);
  }
//+------------------------------------------------------------------+
