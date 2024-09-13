//+------------------------------------------------------------------+
//|                                                   HarmonicMA.mq5 |
//|                                                     Tibra Capita |
//|                                            http://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Tibra Capita"
#property link      "http://www.tibra.com/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 2

//--- input parameters
input int InpPeriod = 14; // Harmonic MA period

//--- indicator buffers
double HMA_Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, HMA_Buffer);
   //--- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "Harmonic MA (" + IntegerToString(InpPeriod) + ")");
   //--- set index label
   PlotIndexSetString(0, PLOT_LABEL, "Harmonic MA");
   //--- set index style
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);
   //---
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
   //--- check if bars count is enough for calculation
   if (rates_total < InpPeriod) return 0;

   int start = prev_calculated;
   if (start < InpPeriod) start = InpPeriod;

   //--- main calculation loop
   for (int i = start; i < rates_total; i++)
   {
      double reciprocal_sum = 0.0;
      for (int j = 0; j < InpPeriod; j++)
      {
         reciprocal_sum += 1.0 / close[i - j];
      }
      HMA_Buffer[i] = InpPeriod / reciprocal_sum;
   }

   return rates_total;
  }
//+------------------------------------------------------------------+
