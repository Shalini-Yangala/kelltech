//+------------------------------------------------------------------+
//|                                                  MACDOverlay.mq4 |
//|                               Copyright 2024, Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue // Color for MACD Histogram
#property indicator_width1 2
// Input parameters
input int    inputFastEMA = 12;          // MACD Fast EMA Period
input int    inputSlowEMA = 26;          // MACD Slow EMA Period
input int    inputSignalSMA = 9;         // MACD Signal SMA Period
input color  inputHistogramColor = Blue; // Color of the MACD Histogram
// Indicator buffer
double macdHistBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffer setup
   SetIndexBuffer(0, macdHistBuffer);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexLabel(0, "MACD Histogram");
   // Set indicator properties
   IndicatorShortName("MACD Overlay Histogram");
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
      double macdMain = iMACD(NULL, 0, inputFastEMA, inputSlowEMA, inputSignalSMA, PRICE_CLOSE, MODE_MAIN, i);
      double macdSignal = iMACD(NULL, 0, inputFastEMA, inputSlowEMA, inputSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
      macdHistBuffer[i] = macdMain - macdSignal;
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+