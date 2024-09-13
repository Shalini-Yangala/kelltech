//+------------------------------------------------------------------+
//|                                                          GMA.mq5 |
//|                                                    Tibra Capital |
//|                                            http://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Tibra Capital"
#property link      "http://www.tibra.com/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "GMA"
#property indicator_color1  clrGreen
#property indicator_width1  2
#property indicator_type1   DRAW_LINE

//--- input parameters
input int period = 14;  // period for GMA

//--- indicator buffers
double gmaBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, gmaBuffer, INDICATOR_DATA);
   
   //--- name
   IndicatorSetString(INDICATOR_SHORTNAME, "Geometric MA (" + IntegerToString(period) + ")");
   
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
   int start = MathMax(period, prev_calculated - 1);

   for(int i = start; i < rates_total; i++)
     {
      double product = 1.0;
      for(int j = 0; j < period; j++)
        {
         product *= close[i - j];
        }
      gmaBuffer[i] = pow(product, 1.0 / period);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
