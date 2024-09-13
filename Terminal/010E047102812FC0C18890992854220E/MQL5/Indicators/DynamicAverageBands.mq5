//+------------------------------------------------------------------+
//|                                          DynamicAverageBands.mq5 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- Plot 1: VIDYA
#property indicator_label1  "VIDYA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1
//--- Plot 2: Upper Band
#property indicator_label2  "Upper Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1
//--- Plot 3: Lower Band
#property indicator_label3  "Lower Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  1
//--- Input parameters
input int vidya_period = 14;              // Period for VIDYA
//--- Indicator buffers
double vidya_buffer[];
double upper_band_buffer[];
double lower_band_buffer[];
int handle_vidya;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Assign buffers to plots
   SetIndexBuffer(0, vidya_buffer, INDICATOR_DATA);
   SetIndexBuffer(1, upper_band_buffer, INDICATOR_DATA);
   SetIndexBuffer(2, lower_band_buffer, INDICATOR_DATA);
   //--- Create handles for the VIDYA
   handle_vidya = iVIDyA(NULL, 0, vidya_period, 12, 0, PRICE_CLOSE);
   //--- Check if the handle is valid
   if(handle_vidya == INVALID_HANDLE)
     {
      Print("Failed to create iVIDyA handle");
      return INIT_FAILED;
     }
   //--- Set Plot Names
   PlotIndexSetString(0, PLOT_LABEL, "VIDYA");
   PlotIndexSetString(1, PLOT_LABEL, "Upper Band");
   PlotIndexSetString(2, PLOT_LABEL, "Lower Band");
   //--- Set Data Begin Index
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, vidya_period);
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
   //--- Copy VIDYA data into the buffer
   if(CopyBuffer(handle_vidya, 0, start, rates_total, vidya_buffer) <= 0)
     {
      Print("Failed to copy data from iVIDYA");
      return 0; // exit the function if copying fails
     }
   //--- Calculate the upper and lower bands
   for(int i = start; i < rates_total; i++)
     {
      double vidya = vidya_buffer[i];
      // Calculate the upper and lower bands
      upper_band_buffer[i] = vidya * vidya;   // Square of VIDYA
      lower_band_buffer[i] = MathSqrt(vidya); // Square root of VIDYA
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+