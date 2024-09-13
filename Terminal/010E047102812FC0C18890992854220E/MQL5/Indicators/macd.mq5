//+------------------------------------------------------------------+
//|                                                   RMacDivergence |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Blue
#property indicator_color6 Blue

// Indicator inputs
input int RSIPeriod = 14;
input int MACDFastEMA = 12;
input int MACDSlowEMA = 26;
input int MACDSignalSMA = 9;
input bool UseDoubleDivergence = true;
input bool UseTripleDivergence = true;
input bool EnableAlerts = true;

// Indicator buffers
double RSIBuffer[];
double MACDBuffer[];
double SignalBuffer[];
double DivergenceUpBuffer[];
double DivergenceDownBuffer[];
double ArrowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Define indicator buffers
   SetIndexBuffer(0, RSIBuffer);
   SetIndexBuffer(1, MACDBuffer);
   SetIndexBuffer(2, SignalBuffer);
   SetIndexBuffer(3, DivergenceUpBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, DivergenceDownBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, ArrowBuffer, INDICATOR_DATA);

   // Set buffer properties
   ArraySetAsSeries(RSIBuffer, true);
   ArraySetAsSeries(MACDBuffer, true);
   ArraySetAsSeries(SignalBuffer, true);
   ArraySetAsSeries(DivergenceUpBuffer, true);
   ArraySetAsSeries(DivergenceDownBuffer, true);
   ArraySetAsSeries(ArrowBuffer, true);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int start = 0;
   if(prev_calculated > 0)
      start = prev_calculated - 1;

   // Calculate RSI
   int rsi_handle = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE);
   if(rsi_handle == INVALID_HANDLE)
      return 0;

   if(CopyBuffer(rsi_handle, 0, 0, rates_total, RSIBuffer) <= 0)
      return 0;

   // Calculate MACD
   int macd_handle = iMACD(NULL, 0, MACDFastEMA, MACDSlowEMA, MACDSignalSMA,PRICE_CLOSE);
   if(macd_handle == INVALID_HANDLE)
      return 0;

   if(CopyBuffer(macd_handle, 0, 0, rates_total, MACDBuffer) <= 0)
      return 0;
   if(CopyBuffer(macd_handle, 1, 0, rates_total, SignalBuffer) <= 0)
      return 0;

   // Detect divergences
   for(int i = start; i < rates_total - 1; i++)
   {
      // Detect regular divergences
      DetectDivergences(i, RSIBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);
      DetectDivergences(i, MACDBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);

      // Detect double and triple divergences if enabled
      if(UseDoubleDivergence)
      {
         DetectDoubleDivergences(i, RSIBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);
         DetectDoubleDivergences(i, MACDBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);
      }
      if(UseTripleDivergence)
      {
         DetectTripleDivergences(i, RSIBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);
         DetectTripleDivergences(i, MACDBuffer, close, DivergenceUpBuffer, DivergenceDownBuffer, time);
      }
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Detect Divergences                                               |
//+------------------------------------------------------------------+
void DetectDivergences(int i, double &indicatorBuffer[], const double &price[], double &upBuffer[], double &downBuffer[], const datetime &time[])
{
   if((indicatorBuffer[i] < indicatorBuffer[i+1] && price[i] > price[i+1]) || 
      (indicatorBuffer[i] > indicatorBuffer[i+1] && price[i] < price[i+1]))
   {
      // Regular divergence detected
      if(indicatorBuffer[i] < indicatorBuffer[i+1])
         upBuffer[i] = price[i];
      else
         downBuffer[i] = price[i];
      
      // Alert if enabled
      if(EnableAlerts)
      {
         string alertMessage = "Divergence detected at " + TimeToString(time[i]);
         Alert(alertMessage);
      }
   }
}

//+------------------------------------------------------------------+
//| Detect Double Divergences                                        |
//+------------------------------------------------------------------+
void DetectDoubleDivergences(int i, double &indicatorBuffer[], const double &price[], double &upBuffer[], double &downBuffer[], const datetime &time[])
{
   // Check for bullish double divergence (two consecutive lows in the indicator and two consecutive highs in price)
   if((indicatorBuffer[i] < indicatorBuffer[i+1] && indicatorBuffer[i+1] < indicatorBuffer[i+2] && 
       price[i] > price[i+1] && price[i+1] > price[i+2]) ||
      (indicatorBuffer[i] > indicatorBuffer[i+1] && indicatorBuffer[i+1] > indicatorBuffer[i+2] &&
       price[i] < price[i+1] && price[i+1] < price[i+2]))
   {
      // Double divergence detected
      if(indicatorBuffer[i] < indicatorBuffer[i+1])
         upBuffer[i] = price[i];
      else
         downBuffer[i] = price[i];

      // Alert if enabled
      if(EnableAlerts)
      {
         string alertMessage = "Double divergence detected at " + TimeToString(time[i]);
         Alert(alertMessage);
      }
   }
}

//+------------------------------------------------------------------+
//| Detect Triple Divergences                                        |
//+------------------------------------------------------------------+
void DetectTripleDivergences(int i, double &indicatorBuffer[], const double &price[], double &upBuffer[], double &downBuffer[], const datetime &time[])
{
   // Check for bullish triple divergence (three consecutive lows in the indicator and three consecutive highs in price)
   if((indicatorBuffer[i] < indicatorBuffer[i+1] && indicatorBuffer[i+1] < indicatorBuffer[i+2] && indicatorBuffer[i+2] < indicatorBuffer[i+3] &&
       price[i] > price[i+1] && price[i+1] > price[i+2] && price[i+2] > price[i+3]) ||
      (indicatorBuffer[i] > indicatorBuffer[i+1] && indicatorBuffer[i+1] > indicatorBuffer[i+2] && indicatorBuffer[i+2] > indicatorBuffer[i+3] &&
       price[i] < price[i+1] && price[i+1] < price[i+2] && price[i+2] < price[i+3]))
   {
      // Triple divergence detected
      if(indicatorBuffer[i] < indicatorBuffer[i+1])
         upBuffer[i] = price[i];
      else
         downBuffer[i] = price[i];

      // Alert if enabled
      if(EnableAlerts)
      {
         string alertMessage = "Triple divergence detected at " + TimeToString(time[i]);
         Alert(alertMessage);
      }
   }
}
