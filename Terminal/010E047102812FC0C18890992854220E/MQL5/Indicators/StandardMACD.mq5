//+------------------------------------------------------------------+
//|                                                 StandardMACD.mq5 |
//|                                                Century Financial |
//|                                        http://www.century.ae/en/ |
//+------------------------------------------------------------------+
#property copyright "Century Financial"
#property link      "http://www.century.ae/en/"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4

//--- plot MACD line
#property indicator_label1  "MACD Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID

//--- plot Signal line
#property indicator_label2  "Signal Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  1
#property indicator_style2  STYLE_SOLID

//--- plot Standard Deviation Bands
#property indicator_label3  "StdDev UpperBand"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGreen
#property indicator_width3  1
#property indicator_style3  STYLE_DOT

#property indicator_label4  "StdDev LowerBand"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMagenta
#property indicator_width4  1
#property indicator_style4  STYLE_DOT

//--- input parameters
input int    FastEMA = 12;      // Fast EMA period
input int    SlowEMA = 26;      // Slow EMA period
input int    SignalSMA = 9;     // Signal SMA period
input int    StdDevPeriod = 20; // Standard Deviation period

//--- indicator buffers
double MACDLine[];
double SignalLine[];
double StdDevUpper[];
double StdDevLower[];

//--- global variables
int    MACD_Handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- indicator buffers mapping
   SetIndexBuffer(0, MACDLine);
   SetIndexBuffer(1, SignalLine);
   SetIndexBuffer(2, StdDevUpper);
   SetIndexBuffer(3, StdDevLower);
   
   //--- initial settings for MACD and Signal line calculations
   MACD_Handle = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);

   if (MACD_Handle == INVALID_HANDLE)
     {
      Print("Error creating MACD handle. Error code = ", GetLastError());
      return (INIT_FAILED);
     }

   //--- initialization done
   return (INIT_SUCCEEDED);
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
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   //--- variables for standard deviation calculation
   double macdValueArray[];
   double signalValueArray[];
   int barsToCopy = rates_total - prev_calculated;

   //--- checking the amount of bars to process
   if (barsToCopy <= 0) return (rates_total);
   
   //--- MACD value copying
   if (CopyBuffer(MACD_Handle, 0, 0, barsToCopy, macdValueArray) <= 0 ||
       CopyBuffer(MACD_Handle, 1, 0, barsToCopy, signalValueArray) <= 0)
     {
      Print("Error copying MACD buffer. Error code = ", GetLastError());
      return (rates_total);
     }

   //--- calculating values for buffers
   for (int i = 0; i < barsToCopy; i++)
     {
      int shift = rates_total - barsToCopy + i;
      MACDLine[shift] = macdValueArray[i];
      SignalLine[shift] = signalValueArray[i];

      //--- calculating standard deviation for MACD
      double StdDevValue = StdDev(macdValueArray, i, StdDevPeriod);
      StdDevUpper[shift] = MACDLine[shift] + StdDevValue;
      StdDevLower[shift] = MACDLine[shift] - StdDevValue;
     }

   return (prev_calculated + barsToCopy);
  }
//+------------------------------------------------------------------+
//| Standard Deviation Calculation Function                          |
//+------------------------------------------------------------------+
double StdDev(const double &data[], int currentIndex, int period)
  {
   double sum = 0.0, mean = 0.0, deviation = 0.0;
   int count = 0;

   //--- checking index range
   if (currentIndex < period - 1) return (0.0);

   //--- calculate mean
   for (int i = currentIndex - period + 1; i <= currentIndex; i++)
     {
      mean += data[i];
      count++;
     }
   mean /= count;

   //--- calculate variance and then standard deviation
   for (int i = currentIndex - period + 1; i <= currentIndex; i++)
     deviation += MathPow(data[i] - mean, 2);

   return (MathSqrt(deviation / count));
  }