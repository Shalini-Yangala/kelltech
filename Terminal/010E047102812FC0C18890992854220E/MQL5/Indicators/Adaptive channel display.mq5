//+------------------------------------------------------------------+
//|                                             AdaptiveChannel.mq5  |
//|                         Custom Indicator Implementation          |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "Your Link"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Plot 1: Momentum
#property indicator_label1  "Momentum"
#property indicator_type1   DRAW_NONE

//--- Plot 2: Adaptive Channel Upper
#property indicator_label2  "Adaptive Upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1

//--- Plot 3: Adaptive Channel Lower
#property indicator_label3  "Adaptive Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  1

//--- Input parameters
input int momentum_period = 14;  // Period for Momentum Indicator
input double adaptive_factor = 2.0;  // Factor to adjust the adaptive channel width

//--- Indicator buffers
double momentum_buffer[];
double adaptive_upper_buffer[];
double adaptive_lower_buffer[];
int handle_momentum;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Assign buffers to plots
   SetIndexBuffer(0, momentum_buffer, INDICATOR_DATA);
   SetIndexBuffer(1, adaptive_upper_buffer, INDICATOR_DATA);
   SetIndexBuffer(2, adaptive_lower_buffer, INDICATOR_DATA);

   //--- Create handle for Momentum Indicator
   handle_momentum = iMomentum(NULL, 0, momentum_period, PRICE_CLOSE);

   //--- Check if handle is valid
   if(handle_momentum == INVALID_HANDLE)
     {
      Print("Failed to create iMomentum handle");
      return INIT_FAILED;
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
   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   //--- Copy Momentum data into buffer
   if(CopyBuffer(handle_momentum, 0, start, rates_total - start, momentum_buffer) <= 0)
     {
      Print("Failed to copy data from iMomentum");
      return 0; // exit the function if copying fails
     }

   //--- Calculate Adaptive Channel bounds
   for(int i = start; i < rates_total; i++)
     {
      double momentum = momentum_buffer[i];
      adaptive_upper_buffer[i] = close[i] + momentum * adaptive_factor; // Upper bound
      adaptive_lower_buffer[i] = close[i] - momentum * adaptive_factor; // Lower bound
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
