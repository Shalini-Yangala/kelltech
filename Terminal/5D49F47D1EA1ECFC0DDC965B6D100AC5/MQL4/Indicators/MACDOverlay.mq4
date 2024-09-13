//+------------------------------------------------------------------+
//|                                                  MACDOverlay.mq4 |
//|                               Copyright 2024, Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue    // Color for MACD Histogram
#property indicator_width1 2
#property indicator_color2 Red     // Color for MACD Main Line
#property indicator_color3 Yellow  // Color for MACD Signal Line
// Input parameters
input int    inputFastEMA = 12;          // MACD Fast EMA Period
input int    inputSlowEMA = 26;          // MACD Slow EMA Period
input int    inputSignalSMA = 9;         // MACD Signal SMA Period
input color  inputHistogramColor = Blue; // Color of the MACD Histogram
// Indicator buffers
double macdHistBuffer[];
double macdMainBuffer[];
double macdSignalBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffer setup
   SetIndexBuffer(0, macdHistBuffer);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexLabel(0, "MACD Histogram");
   SetIndexBuffer(1, macdMainBuffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, "MACD Main");
   SetIndexBuffer(2, macdSignalBuffer);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexLabel(2, "MACD Signal");
   // Colors for buffers
   SetIndexBuffer(0, macdHistBuffer);
   SetIndexBuffer(1, macdMainBuffer);
   SetIndexBuffer(2, macdSignalBuffer);
   SetIndexDrawBegin(0, inputSlowEMA + inputSignalSMA);
   SetIndexDrawBegin(1, inputSlowEMA + inputSignalSMA);
   SetIndexDrawBegin(2, inputSlowEMA + inputSignalSMA);
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
   // Ensure there are enough bars to calculate MACD
   if (rates_total < inputSlowEMA + inputSignalSMA)
      return (0);
   // Calculate MACD histogram values
   for (int i = 0; i < rates_total; i++)
     {
      // Calculate the MACD values using the built-in iMACD function
      macdMainBuffer[i] = iMACD(NULL, 0, inputFastEMA, inputSlowEMA, inputSignalSMA, PRICE_CLOSE, MODE_MAIN, i);
      macdSignalBuffer[i] = iMACD(NULL, 0, inputFastEMA, inputSlowEMA, inputSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
      macdHistBuffer[i] = macdMainBuffer[i] - macdSignalBuffer[i];
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+