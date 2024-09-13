//+------------------------------------------------------------------+
//|                                                     MultiPGF.mq4 |
//|                                                Guerrilla Trading |
//|                               http://www.guerrillatrading.co.uk/ |
//+------------------------------------------------------------------+
#property copyright "Guerrilla Trading"
#property link      "http://www.guerrillatrading.co.uk/"
#property version   "1.01"
#property strict

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//--- input parameters
input int PeriodGaussian = 14;   // Gaussian filter period
input int PeriodSMA = 5;         // SMA period for additional smoothing
input double a = 1.0;            // height of the peak
input double c = 1.0;            // standard deviation

//--- indicator buffers
double SmoothHigh[];
double SmoothLow[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffer mapping
   SetIndexBuffer(0, SmoothHigh);
   SetIndexBuffer(1, SmoothLow);
   //--- buffer styles
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   //--- names
   PlotIndexSetString(0, PLOT_LABEL, "Smoothed High");
   PlotIndexSetString(1, PLOT_LABEL, "Smoothed Low");
   //--- initialization done
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Gaussian function calculation                                    |
//+------------------------------------------------------------------+
double GaussianFunction(int x, double b)
{
   double exponent = -((x - b) * (x - b)) / (2.0 * c * c);
   return a * MathExp(exponent);
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
   //--- check for rates total
   if(rates_total <= PeriodGaussian || rates_total <= PeriodSMA)
      return(0);
   
   int start = prev_calculated - 1;
   if (start < 0) start = 0;

   //--- calculate Gaussian Filter and SMA
   for (int i = start; i < rates_total; i++)
   {
      // Avoid index out of bounds
      if(i < PeriodGaussian || i < PeriodSMA) continue;

      //--- Gaussian Filter for Highs and Lows
      double sumHigh = 0.0;
      double sumLow = 0.0;
      double sumWeights = 0.0;

      for (int j = 0; j < PeriodGaussian; j++)
      {
         double weight = GaussianFunction(j, PeriodGaussian / 2.0);
         sumHigh += high[i - j] * weight;
         sumLow += low[i - j] * weight;
         sumWeights += weight;
      }

      double gaussianHigh = sumHigh / sumWeights;
      double gaussianLow = sumLow / sumWeights;

      //--- SMA smoothing for Highs and Lows
      double sumSMAHigh = 0.0;
      double sumSMALow = 0.0;

      for (int k = 0; k < PeriodSMA; k++)
      {
         sumSMAHigh += gaussianHigh;
         sumSMALow += gaussianLow;
      }

      SmoothHigh[i] = sumSMAHigh / PeriodSMA;
      SmoothLow[i] = sumSMALow / PeriodSMA;
   }

   //--- return the number of bars
   return(rates_total);
}
//+------------------------------------------------------------------+
