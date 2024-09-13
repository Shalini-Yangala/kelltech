//+------------------------------------------------------------------+
//|                                           QuantitativeAverage.mq5 |
//|                                                Elite Forex Trades |
//|                                      https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property indicator_separate_window  // Changed to plot on the main chart window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 2

// Input parameters
input int       X_Candles = 5;          // Number of previous candles to sum
input int       MA_Period = 14;         // Moving Average period
input ENUM_MA_METHOD MA_Method = MODE_SMA; // Moving Average type
input double    ScalingFactor = 0.1;    // Scaling factor to fit the range

// Indicator buffers
double QuantAverageBuffer[];

// Handle for the moving average
int ma_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Set the indicator buffer
   SetIndexBuffer(0, QuantAverageBuffer);
   
   // Set the label for the indicator line
   IndicatorSetString(INDICATOR_SHORTNAME, "QuantAverage");
   PlotIndexSetString(0, PLOT_LABEL, "QuantAverage");

   // Set index style
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);

   // Create the moving average handle
   ma_handle = iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_CLOSE);
   if (ma_handle == INVALID_HANDLE)
     {
      Print("Error creating MA handle");
      return(INIT_FAILED);
     }

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
   // Ensure enough bars for calculation
   if (rates_total < MA_Period + X_Candles) return(0);

   // Array to store MA values
   double ma_values[];

   // Resize the array to fit the required number of values
   ArrayResize(ma_values, rates_total);

   // Copy the MA values into the array
   if (CopyBuffer(ma_handle, 0, 0, rates_total, ma_values) <= 0)
     {
      Print("Error copying MA values");
      return(0);
     }

   // Calculate the Quantitative Average with scaling
   for (int i = MathMax(prev_calculated, X_Candles); i < rates_total; i++)
     {
      double sum_MA = 0.0;

      // Sum the previous X MA values
      for (int j = 1; j <= X_Candles; j++)
        {
         if (i - j >= 0)   // Ensure index is within bounds
            sum_MA += ma_values[i - j];
        }

      // Calculate the Quantitative Average and apply scaling
      QuantAverageBuffer[i] = ScalingFactor * (sum_MA - ma_values[i]);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
