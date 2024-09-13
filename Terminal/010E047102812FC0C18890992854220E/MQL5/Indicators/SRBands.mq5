/*
//+------------------------------------------------------------------+
//|                                                   SRBands.mq5    |
//|                        Copyright 2024, Shalini Yangala           |
//|                                    https://www.yourwebsite.com   |
//+------------------------------------------------------------------+
#property indicator_separate_window       // Display in the main chart window
#property indicator_buffers 3
#property indicator_color1 clrGreen    // Color for the upper band
#property indicator_color2 clrRed      // Color for the lower band
#property indicator_color3 clrBlue     // Color for the support/resistance band
#property indicator_width1 2           // Width of the upper band line
#property indicator_width2 2           // Width of the lower band line
#property indicator_width3 2           // Width of the support/resistance band line
#property indicator_style1 STYLE_SOLID // Line style of the upper band
#property indicator_style2 STYLE_SOLID // Line style of the lower band
#property indicator_style3 STYLE_SOLID // Line style of the support/resistance band
#property indicator_plots 3
// Input parameters
input int    BB_Period = 20;         // Bollinger Bands period
input double BB_Deviation = 2.0;     // Bollinger Bands deviation
input int    ATR_Period = 14;        // ATR period
input double ATR_Multiplier = 1.5;   // ATR multiplier
// Indicator buffers
double Buffer_Upper[];
double Buffer_Lower[];
double Buffer_SR[];  // Support/Resistance band buffer
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, Buffer_Upper);
    SetIndexBuffer(1, Buffer_Lower);
    SetIndexBuffer(2, Buffer_SR);
    // Set buffer properties
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);        // Set line width for upper band
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);        // Set line width for lower band
    PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);        // Set line width for SR band
    PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID); // Set line style for upper band
    PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID); // Set line style for lower band
    PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID); // Set line style for SR band
    PlotIndexSetString(0, PLOT_LABEL, "Upper SR Band"); // Set label for upper band
    PlotIndexSetString(1, PLOT_LABEL, "Lower SR Band"); // Set label for lower band
    PlotIndexSetString(2, PLOT_LABEL, "SR Band"); // Set label for SR band
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
    if (rates_total < MathMax(BB_Period, ATR_Period)) return 0;
    
    // Create and initialize arrays for Bollinger Bands and ATR
    double BB_Middle[];
    double ATR_Values[];
    ArraySetAsSeries(BB_Middle, true);
    ArraySetAsSeries(ATR_Values, true);

    int bb_handle = iBands(NULL, 0, BB_Period, BB_Deviation, 0, PRICE_CLOSE);
    if (bb_handle < 0) {
        Print("Error creating Bollinger Bands handle");
        return 0;
    }
    if (CopyBuffer(bb_handle, 1, 0, rates_total, BB_Middle) <= 0) {
        Print("Error copying Bollinger Bands buffer");
        return 0;
    }
    
    int ATR_Handle = iATR(NULL, 0, ATR_Period);
    if (ATR_Handle < 0) {
        Print("Error creating ATR handle");
        return 0;
    }
    if (CopyBuffer(ATR_Handle, 0, 0, rates_total, ATR_Values) <= 0) {
        Print("Error copying ATR buffer");
        return 0;
    }

    // Ensure buffer arrays are the correct size
    ArrayResize(Buffer_Upper, rates_total);
    ArrayResize(Buffer_Lower, rates_total);
    ArrayResize(Buffer_SR, rates_total);

    // Start loop from previous calculated index
    for (int i = MathMax(prev_calculated - 1, 0); i < rates_total; i++)
    {
        if (i >= ArraySize(BB_Middle) || i >= ArraySize(ATR_Values)) continue; // Check array bounds

        double SMA = BB_Middle[i];
        double ATR = ATR_Values[i];
        // Calculate ATR Bands as reactive support/resistance levels
        Buffer_Upper[i] = SMA + ATR_Multiplier * ATR;  // Upper Band
        Buffer_Lower[i] = SMA - ATR_Multiplier * ATR;  // Lower Band
        // Calculate the difference between the upper and lower bands
        Buffer_SR[i] = Buffer_Upper[i] - Buffer_Lower[i];  // SR Band
        // Debugging: Print values to the Journal for verification
        if (i % 100 == 0) {
            Print("Index: ", i, " SMA: ", SMA, " ATR: ", ATR,
                  " Upper Band: ", Buffer_Upper[i],
                  " Lower Band: ", Buffer_Lower[i],
                  " SR Band: ", Buffer_SR[i]);
        }
    }
    return(rates_total);
}
//+------------------------------------------------------------------+

*/

//====================================================================================================================================================================

/*
//+------------------------------------------------------------------+
//|                                                   SRBands.mq5    |
//|                        Copyright 2024, Shalini Yangala           |
//|                                    https://www.yourwebsite.com   |
//+------------------------------------------------------------------+
#property indicator_chart_window       // Display in a separate window
#property indicator_buffers 3
#property indicator_color1 clrGreen    // Color for the upper band
#property indicator_color2 clrRed      // Color for the lower band
#property indicator_color3 clrBlue     // Color for the support/resistance band
#property indicator_width1 2           // Width of the upper band line
#property indicator_width2 2           // Width of the lower band line
#property indicator_width3 2           // Width of the support/resistance band line
#property indicator_style1 STYLE_SOLID // Line style of the upper band
#property indicator_style2 STYLE_SOLID // Line style of the lower band
#property indicator_style3 STYLE_SOLID // Line style of the support/resistance band
#property indicator_plots 3

// Input parameters
input int    BB_Period = 20;         // Bollinger Bands period
input double BB_Deviation = 2.0;     // Bollinger Bands deviation
input int    ATR_Period = 14;        // ATR period
input double ATR_Multiplier = 1.5;   // ATR multiplier

// Indicator buffers
double Buffer_Upper[];
double Buffer_Lower[];
double Buffer_SR[];  // Support/Resistance band buffer

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set index buffers
    SetIndexBuffer(0, Buffer_Upper);
    SetIndexBuffer(1, Buffer_Lower);
    SetIndexBuffer(2, Buffer_SR);
    
    // Set buffer properties
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);  // Set line width for upper band
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);  // Set line width for lower band
    PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);  // Set line width for SR band
    PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);  // Set line style for upper band
    PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);  // Set line style for lower band
    PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);  // Set line style for SR band
    PlotIndexSetString(0, PLOT_LABEL, "Upper Band");  // Set label for upper band
    PlotIndexSetString(1, PLOT_LABEL, "Lower Band");  // Set label for lower band
    PlotIndexSetString(2, PLOT_LABEL, "SR Band");     // Set label for SR band

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
    // Check if there is enough data
    if (rates_total < MathMax(BB_Period, ATR_Period)) return 0;

    // Initialize arrays for Bollinger Bands and ATR
    double BB_Middle[];
    double ATR_Values[];
    ArraySetAsSeries(BB_Middle, true);
    ArraySetAsSeries(ATR_Values, true);

    // Create handles for indicators
    int bb_handle = iBands(NULL, 0, BB_Period, BB_Deviation, 0, PRICE_CLOSE);
    int atr_handle = iATR(NULL, 0, ATR_Period);
    
    if (bb_handle == INVALID_HANDLE || atr_handle == INVALID_HANDLE) {
        Print("Error creating indicator handles: ", GetLastError());
        return 0;
    }

    // Copy data from handles
    if (CopyBuffer(bb_handle, 1, 0, rates_total, BB_Middle) <= 0) {
        Print("Error copying Bollinger Bands buffer: ", GetLastError());
        return 0;
    }
    if (CopyBuffer(atr_handle, 0, 0, rates_total, ATR_Values) <= 0) {
        Print("Error copying ATR buffer: ", GetLastError());
        return 0;
    }

    // Ensure buffer arrays are the correct size
    ArrayResize(Buffer_Upper, rates_total);
    ArrayResize(Buffer_Lower, rates_total);
    ArrayResize(Buffer_SR, rates_total);

    // Start loop from the beginning
    for (int i = 0; i < rates_total; i++)
    {
        if (i >= ArraySize(BB_Middle) || i >= ArraySize(ATR_Values)) continue; // Check array bounds

        double SMA = BB_Middle[i];
        double ATR = ATR_Values[i];
        Buffer_Upper[i] = SMA + ATR_Multiplier * ATR;  // Upper Band
        Buffer_Lower[i] = SMA - ATR_Multiplier * ATR;  // Lower Band
        Buffer_SR[i] = Buffer_Upper[i] - Buffer_Lower[i];  // SR Band
    }

    return(rates_total);
}
//+------------------------------------------------------------------+

*/
//========================================================================================================================================


//+------------------------------------------------------------------+
//|                                                   SRBands.mq5    |
//|                        Copyright 2024, Shalini Yangala           |
//|                                    https://www.yourwebsite.com   |
//+------------------------------------------------------------------+
#property indicator_chart_window       // Display in the main chart window
#property indicator_buffers 3
#property indicator_color1 clrGreen    // Color for the upper band
#property indicator_color2 clrRed      // Color for the lower band
#property indicator_color3 clrBlue     // Color for the support/resistance band
#property indicator_width1 2           // Width of the upper band line
#property indicator_width2 2           // Width of the lower band line
#property indicator_width3 2           // Width of the support/resistance band line
#property indicator_style1 STYLE_SOLID // Line style of the upper band
#property indicator_style2 STYLE_SOLID // Line style of the lower band
#property indicator_style3 STYLE_SOLID // Line style of the support/resistance band
#property indicator_plots 3
// Input parameters
input int    BB_Period = 20;         // Bollinger Bands period
input double BB_Deviation = 2.0;     // Bollinger Bands deviation
input int    ATR_Period = 14;        // ATR period
input double ATR_Multiplier = 1.5;   // ATR multiplier
// Indicator buffers
double Buffer_Upper[];
double Buffer_Lower[];
double Buffer_SR[];  // Support/Resistance band buffer
int ATR_Handle, bb_handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create handles for Bollinger Bands and ATR
   bb_handle = iBands(NULL, 0, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
   if(bb_handle < 0)
     {
      Print("Error creating Bollinger Bands handle");
      return(INIT_FAILED);
     }

   ATR_Handle = iATR(NULL, 0, ATR_Period);
   if(ATR_Handle < 0)
     {
      Print("Error creating ATR handle");
      return(INIT_FAILED);
     }

   // Set buffer properties
   SetIndexBuffer(0, Buffer_Upper);
   SetIndexBuffer(1, Buffer_Lower);
   SetIndexBuffer(2, Buffer_SR);

   IndicatorSetString(INDICATOR_SHORTNAME, "SR Bands");
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "Upper SR Band");
   PlotIndexSetString(1, PLOT_LABEL, "Lower SR Band");
   PlotIndexSetString(2, PLOT_LABEL, "SR Band");

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
   // Ensure there's enough data
   if(rates_total < MathMax(BB_Period, ATR_Period))
      return(0);

   // Arrays for Bollinger Bands and ATR
   double BB_Middle[];
   ArraySetAsSeries(BB_Middle, true);
   ArrayResize(BB_Middle, rates_total);

   double ATR_Values[];
   ArraySetAsSeries(ATR_Values, true);
   ArrayResize(ATR_Values, rates_total);

   // Copy data
   if(CopyBuffer(bb_handle, 1, 0, rates_total, BB_Middle) <= 0)
     {
      Print("Error copying Bollinger Bands data");
      return(0);
     }

   if(CopyBuffer(ATR_Handle, 0, 0, rates_total, ATR_Values) <= 0)
     {
      Print("Error copying ATR data");
      return(0);
     }

   // Calculate bands
   for(int i = MathMax(prev_calculated - 1, BB_Period); i < rates_total; i++)
     {
      double SMA = BB_Middle[i];
      double ATR = ATR_Values[i];
      Buffer_Upper[i] = SMA + ATR_Multiplier * ATR;  // Upper Band
      Buffer_Lower[i] = SMA - ATR_Multiplier * ATR;  // Lower Band
      Buffer_SR[i] = Buffer_Upper[i] - Buffer_Lower[i];  // SR Band

      // Optional: Debugging
      if(i % 100 == 0)
        {
         Print("Index: ", i, " SMA: ", SMA, " ATR: ", ATR,
               " Upper Band: ", Buffer_Upper[i],
               " Lower Band: ", Buffer_Lower[i],
               " SR Band: ", Buffer_SR[i]);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

//===================================================================================================================================================
//+------------------------------------------------------------------+
//|                                             CustomBands.mq5       |
//|                        Written by Shalini Yangala                 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue         // Upper Bollinger Band
#property indicator_color2 Blue         // Lower Bollinger Band
#property indicator_color3 Red          // Upper ATR Band
#property indicator_color4 Green        // Lower ATR Band
#property indicator_color5 Orange       // Support/Resistance Band
#property indicator_plots 5
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 2

//---- input parameters
input int    BollingerPeriod=20;        // Bollinger Bands period
input double BollingerDeviation=1.0;    // Bollinger Bands deviation
input int    ATRPeriod=10;              // ATR period
input double ATRMultiplier=1.0;         // ATR multiplier
input int    SupportResistancePeriod=50;// Support/Resistance period
input double ScalingFactor=100.0;       // Scaling factor for normalization

//---- indicator buffers
double UpperBollinger[];
double LowerBollinger[];
double UpperATR[];
double LowerATR[];
double SupportResistance[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Set indicator buffers
   SetIndexBuffer(0, UpperBollinger);
   SetIndexBuffer(1, LowerBollinger);
   SetIndexBuffer(2, UpperATR);
   SetIndexBuffer(3, LowerATR);
   SetIndexBuffer(4, SupportResistance);

   // Set buffer properties
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(0, PLOT_LABEL, "Upper Bollinger Band");
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(1, PLOT_LABEL, "Lower Bollinger Band");
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(2, PLOT_LABEL, "Upper ATR Band");
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(3, PLOT_LABEL, "Lower ATR Band");
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(4, PLOT_LABEL, "Support/Resistance Band");

   // Initialize buffer arrays
   ArraySetAsSeries(UpperBollinger, true);
   ArraySetAsSeries(LowerBollinger, true);
   ArraySetAsSeries(UpperATR, true);
   ArraySetAsSeries(LowerATR, true);
   ArraySetAsSeries(SupportResistance, true);

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
   if (rates_total < BollingerPeriod || rates_total < ATRPeriod || rates_total < SupportResistancePeriod)
      return(0);

   int begin = rates_total - prev_calculated;
   if (begin == rates_total) begin -= 1;

   // Calculate Bollinger Bands
   double max_bollinger = -DBL_MAX;
   double min_bollinger = DBL_MAX;

   for (int i = begin; i >= 0; i--)
     {
      double sma = iMA(NULL, 0, BollingerPeriod, 0, MODE_SMA, PRICE_CLOSE);
      double stddev = iStdDev(NULL, 0, BollingerPeriod, 0, MODE_SMA, PRICE_CLOSE);

      UpperBollinger[i] = (sma + BollingerDeviation * stddev) / ScalingFactor;
      LowerBollinger[i] = (sma - BollingerDeviation * stddev) / ScalingFactor;

      if (UpperBollinger[i] > max_bollinger) max_bollinger = UpperBollinger[i];
      if (LowerBollinger[i] < min_bollinger) min_bollinger = LowerBollinger[i];
     }

   // Normalize Bollinger Bands
   double range_bollinger = max_bollinger - min_bollinger;
   if (range_bollinger != 0) {
      for (int i = 0; i < rates_total; i++)
        {
         UpperBollinger[i] = (UpperBollinger[i] - min_bollinger) / range_bollinger;
         LowerBollinger[i] = (LowerBollinger[i] - min_bollinger) / range_bollinger;
        }
   }

   // Calculate ATR Bands
   double max_atr = -DBL_MAX;
   double min_atr = DBL_MAX;

   for (int i = begin; i >= 0; i--)
     {
      double sma = iMA(NULL, 0, BollingerPeriod, 0, MODE_SMA, PRICE_CLOSE);
      double atr = iATR(NULL, 0, ATRPeriod);

      UpperATR[i] = (sma + ATRMultiplier * atr) / ScalingFactor;
      LowerATR[i] = (sma - ATRMultiplier * atr) / ScalingFactor;

      if (UpperATR[i] > max_atr) max_atr = UpperATR[i];
      if (LowerATR[i] < min_atr) min_atr = LowerATR[i];
     }

   // Normalize ATR Bands
   double range_atr = max_atr - min_atr;
   if (range_atr != 0) {
      for (int i = 0; i < rates_total; i++)
        {
         UpperATR[i] = (UpperATR[i] - min_atr) / range_atr;
         LowerATR[i] = (LowerATR[i] - min_atr) / range_atr;
        }
   }

   // Calculate Support/Resistance Band
   double max_sr = -DBL_MAX;
   double min_sr = DBL_MAX;

   for (int i = begin; i >= 0; i--)
     {
      double high_avg = iMA(NULL, 0, SupportResistancePeriod, 0, MODE_SMA, PRICE_HIGH);
      double low_avg = iMA(NULL, 0, SupportResistancePeriod, 0, MODE_SMA, PRICE_LOW);

      SupportResistance[i] = ((high_avg + low_avg) / 2.0) / ScalingFactor;

      if (SupportResistance[i] > max_sr) max_sr = SupportResistance[i];
      if (SupportResistance[i] < min_sr) min_sr = SupportResistance[i];
     }

   // Normalize Support/Resistance Band
   double range_sr = max_sr - min_sr;
   if (range_sr != 0) {
      for (int i = 0; i < rates_total; i++)
        {
         SupportResistance[i] = (SupportResistance[i] - min_sr) / range_sr;
        }
   }

   return(rates_total);
  }

//=========================================================================================================================================
//+------------------------------------------------------------------+
//|                                                      shalband.mq5|
//|                        Custom Indicator for MetaTrader 5         |
//|                                      © 2024 Your Name             |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_plots 3

//--- input parameters
input int    ATR_Period = 14;           // ATR period
input int    BB_Period = 20;            // Bollinger Bands period
input double BB_Deviation = 2.0;        // Bollinger Bands deviation

//--- indicator buffers
double UpperBandBuffer[];
double LowerBandBuffer[];
double SRBandBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, UpperBandBuffer);
   SetIndexBuffer(1, LowerBandBuffer);
   SetIndexBuffer(2, SRBandBuffer);

   //--- indicator properties
   //IndicatorShortName("SRBands Indicator
   IndicatorSetString(INDICATOR_SHORTNAME, "SR Bands");
   PlotIndexSetString(0, PLOT_LABEL, "Upper Band");
   PlotIndexSetString(1, PLOT_LABEL, "Lower Band");
   PlotIndexSetString(2, PLOT_LABEL, "SR Band");

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
   //--- check for sufficient data
   if(rates_total < ATR_Period + BB_Period) return(0);

   //--- Main calculation loop
   int begin = MathMax(ATR_Period, BB_Period);
   for(int i = begin; i < rates_total; i++)
     {
      // Calculate ATR value
      double ATR_Value = iATR(NULL, 0, ATR_Period);

      // Calculate Bollinger Bands values
      double BB_Middle = iMA(NULL, 0, BB_Period, 0, MODE_SMA, PRICE_CLOSE);
      double BB_StdDev = iStdDev(NULL, 0, BB_Period, 0, MODE_SMA, PRICE_CLOSE
      );
      double BB_Upper = BB_Middle + BB_Deviation * BB_StdDev;
      double BB_Lower = BB_Middle - BB_Deviation * BB_StdDev;

      // Calculate the upper and lower ATR bands
      UpperBandBuffer[i] = BB_Upper + ATR_Value;
      LowerBandBuffer[i] = BB_Lower - ATR_Value;

      // Calculate the SR Band as the difference between upper and lower bands
      SRBandBuffer[i] = UpperBandBuffer[i] - LowerBandBuffer[i];
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
