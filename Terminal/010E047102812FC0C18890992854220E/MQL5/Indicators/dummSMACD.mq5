/*//+------------------------------------------------------------------+
//|                                             MACD StdDev.mq5       |
//|                        Copyright 2024, Your Name                  |
//|                                       Your Website/Contact        |
//+------------------------------------------------------------------+
#property copyright "2024, Your Name"
#property link      "Your Website/Contact"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue   // MACD line
#property indicator_color2 Red    // Signal line
#property indicator_color3 Lime   // Upper StdDev
#property indicator_color4 Lime   // Lower StdDev
#property indicator_plots   4

//--- input parameters
input int FastEMA = 12;           // Fast EMA period
input int SlowEMA = 26;           // Slow EMA period
input int SignalSMA = 9;          // Signal line period
input int StdDevPeriod = 10;      // Standard Deviation period

//--- indicator buffers
double MACDBuffer[];
double SignalBuffer[];
double UpperStdDevBuffer[];
double LowerStdDevBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, MACDBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, UpperStdDevBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, LowerStdDevBuffer, INDICATOR_DATA);

   //--- indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "MACD with StdDev");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   //--- plot properties
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Lime);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, Lime);

   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_DASH);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DASH);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // number of bars
                const int prev_calculated,  // bars calculated at previous call
                const int begin,            // where the significant data begins
                const double &price[])
  {
   int start = prev_calculated;
   if (start < SlowEMA) start = SlowEMA;

   for (int i = start; i < rates_total; i++)
     {
      //--- Calculate EMA values
      double FastEMAValue = iMA(NULL, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
      double SlowEMAValue = iMA(NULL, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
      
      //--- Calculate MACD
      MACDBuffer[i] = FastEMAValue - SlowEMAValue;
      Print(MACDBuffer[i]);
     }

   //--- Calculate Signal line using SMA on the MACD buffer
   for (int i = start; i < rates_total; i++)
     {
      double sum = 0;
      for (int j = 0; j < SignalSMA; j++)
        {
         if (i - j >= 0)
            sum += MACDBuffer[i - j];
        }
      SignalBuffer[i] = sum / SignalSMA;
     }

   //--- Calculate Standard Deviation
   for (int i = start; i < rates_total; i++)
     {
      double sum = 0, std_dev = 0;
      int count = 0;

      // Calculate sum and mean of the last StdDevPeriod values
      for (int j = i; j > i - StdDevPeriod && j >= 0; j--)
        {
         sum += MACDBuffer[j];
         count++;
        }
      double mean = sum / count;

      // Calculate standard deviation
      for (int j = i; j > i - StdDevPeriod && j >= 0; j--)
        {
         std_dev += MathPow(MACDBuffer[j] - mean, 2);
        }
      std_dev = MathSqrt(std_dev / count);

      //--- Calculate upper and lower standard deviations
      UpperStdDevBuffer[i] = mean + std_dev;
      LowerStdDevBuffer[i] = mean - std_dev;
     }

   return(rates_total);
  }*/
  
//+------------------------------------------------------------------+
//|                                             MACD StdDev.mq5       |
//|                        Copyright 2024, Your Name                  |
//|                                       Your Website/Contact        |
//+------------------------------------------------------------------+
#property copyright "2024, Your Name"
#property link      "Your Website/Contact"
#property version   "1.01"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue   // MACD line
#property indicator_color2 Red    // Signal line
#property indicator_color3 Lime   // Upper StdDev
#property indicator_color4 Lime   // Lower StdDev
#property indicator_plots   4

//--- input parameters
input int FastEMA = 12;           // Fast EMA period
input int SlowEMA = 26;           // Slow EMA period
input int SignalSMA = 9;          // Signal line period
input int StdDevPeriod = 10;      // Standard Deviation period

//--- indicator buffers
double MACDBuffer[];
double SignalBuffer[];
double UpperStdDevBuffer[];
double LowerStdDevBuffer[];

//--- handle for MACD indicator
int MACD_Handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, MACDBuffer);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexBuffer(2, UpperStdDevBuffer);
   SetIndexBuffer(3, LowerStdDevBuffer);

   //--- indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "MACD with StdDev");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   //--- plot properties
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Lime);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, Lime);

   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_DASH);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DASH);

   //--- Create MACD indicator handle
   MACD_Handle = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);

   if (MACD_Handle == INVALID_HANDLE)
     {
      Print("Failed to create MACD indicator handle!");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Release the MACD handle
   if (MACD_Handle != INVALID_HANDLE)
      IndicatorRelease(MACD_Handle);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // number of bars
                const int prev_calculated,  // bars calculated at previous call
                const int begin,            // where the significant data begins
                const double &price[])
  {
   //--- Calculate number of bars needed for calculation
   int calculated = prev_calculated;
   if (calculated == 0)
      calculated = 1;

   int start = SlowEMA + SignalSMA - 1;
   if (rates_total < start)
      return(0);

   //--- Copy MACD values
   if (CopyBuffer(MACD_Handle, 0, 0, rates_total, MACDBuffer) <= 0 ||
       CopyBuffer(MACD_Handle, 1, 0, rates_total, SignalBuffer) <= 0)
     {
      Print("Failed to copy data from MACD indicator!");
      return(0);
     }

   //--- Calculate Standard Deviation
   for (int i = start; i < rates_total; i++)
     {
      double sum = 0, std_dev = 0;
      int count = 0;

      // Calculate sum and mean of the last StdDevPeriod values
      for (int j = i; j > i - StdDevPeriod && j >= 0; j--)
        {
         sum += MACDBuffer[j];
         count++;
        }
      double mean = sum / count;

      // Calculate standard deviation
      for (int j = i; j > i - StdDevPeriod && j >= 0; j--)
        {
         std_dev += MathPow(MACDBuffer[j] - mean, 2);
        }
      std_dev = MathSqrt(std_dev / count);

      //--- Calculate upper and lower standard deviations
      UpperStdDevBuffer[i] = MACDBuffer[i] + std_dev;
      LowerStdDevBuffer[i] = MACDBuffer[i] - std_dev;
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
