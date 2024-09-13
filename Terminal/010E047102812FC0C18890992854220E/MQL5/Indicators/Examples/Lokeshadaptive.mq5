//+------------------------------------------------------------------+
//|                                             AdaptiveChannel.mq5 |
//|                            Copyright 2024, Elite Forex Trades.     |
//|                                https://eliteforextrades.com        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Elite Forex Trades."
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_separate_window // Display in main chart window
#property indicator_buffers 5
#property indicator_plots   3

//--- Plot 1: Adaptive Channel Upper
#property indicator_label1  "Adaptive Channel Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1

//--- Plot 2: Adaptive Channel Lower
#property indicator_label2  "Adaptive Channel Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1

//--- Plot 3: Momentum
#property indicator_label3  "Momentum"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_width3  1

//--- Input parameters
input int momentum_period = 14;       // Momentum period
input int donchian_period = 20;       // Donchian channel period

//--- Indicator buffers
double adaptive_upper_buffer[];
double adaptive_lower_buffer[];
double donchian_upper_buffer[];
double donchian_lower_buffer[];
int handle_momentum;
double momentum_buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Initialize buffers
   SetIndexBuffer(0, adaptive_upper_buffer);
   SetIndexBuffer(1, adaptive_lower_buffer);
   SetIndexBuffer(2, momentum_buffer);
   SetIndexBuffer(3, donchian_upper_buffer); // Buffer for Donchian upper
   SetIndexBuffer(4, donchian_lower_buffer); // Buffer for Donchian lower

   //--- Create handle for Momentum Indicator
   handle_momentum = iMomentum(NULL, 0, momentum_period, PRICE_CLOSE);

   //--- Check if handle is valid
   if(handle_momentum == INVALID_HANDLE)
     {
      Print("Failed to create iMomentum handle");
      return INIT_FAILED;
     }

   //--- Set Plot Names
   PlotIndexSetString(0, PLOT_LABEL, "Adaptive Channel Upper");
   PlotIndexSetString(1, PLOT_LABEL, "Adaptive Channel Lower");
   PlotIndexSetString(2, PLOT_LABEL, "Momentum");
   PlotIndexSetString(3, PLOT_LABEL, "Donchian Channel Upper");
   PlotIndexSetString(4, PLOT_LABEL, "Donchian Channel Lower");

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
   // Check if enough bars are available
   if(rates_total < donchian_period || rates_total < momentum_period)
     {
      Print("Not enough bars to calculate indicators");
      return 0;
     }

   // Copy Momentum data into buffer
   if(CopyBuffer(handle_momentum, 0, 0, rates_total, momentum_buffer) <= 0)
     {
      Print("Failed to copy data from iMomentum");
      return 0; // exit the function if copying fails
     }

   // Calculate Donchian channel bounds
   for(int i = donchian_period - 1; i < rates_total; i++)
     {
      int highest_index = iHighest(NULL, 0, MODE_HIGH, donchian_period, i - donchian_period + 1);
      int lowest_index = iLowest(NULL, 0, MODE_LOW, donchian_period, i - donchian_period + 1);

      // Validate indices
      /*if(highest_index >= donchian_period - 1 && lowest_index >= donchian_period - 1 && 
         highest_index < rates_total && lowest_index < rates_total)
        {
         donchian_upper_buffer[i] = high[highest_index];
         donchian_lower_buffer[i] = low[lowest_index];
        }*/
      /*else
        {
         donchian_upper_buffer[i] = EMPTY_VALUE;
         donchian_lower_buffer[i] = EMPTY_VALUE;
        }*/
     }

   // Calculate Adaptive Channel bounds
   for(int i = momentum_period - 1; i < rates_total; i++)
     {
      double momentum = momentum_buffer[i];
      // Adjust the adaptive channel bounds based on momentum values
      adaptive_upper_buffer[i] = close[i] + momentum; // Channel upper bound
      adaptive_lower_buffer[i] = close[i] - momentum; // Channel lower bound
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
