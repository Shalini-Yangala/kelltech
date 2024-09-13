//+------------------------------------------------------------------+
//|                                                  RSIchannels.mq4 |
//|                             Copyright 2024 , Elite Forex Trades. |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024 , Elite Forex Trades."
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_separate_window // Display in separate window
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
#property indicator_color3 clrGreen
// Indicator parameters
input int RSI_Period = 14;
input int EMA_Period = 20;
input double UpperLevel = 70.0;
input double LowerLevel = 30.0;
input double ChannelWidth = 10.0; // Channel width parameter
// Buffers
double RSIBuffer[];
double UpperEMABuffer[];
double LowerEMABuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0, RSIBuffer);
   SetIndexBuffer(1, UpperEMABuffer);
   SetIndexBuffer(2, LowerEMABuffer);
// Indicator names and colors
   SetIndexLabel(0, "RSI");
   SetIndexLabel(1, "Upper EMA Channel");
   SetIndexLabel(2, "Lower EMA Channel");
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrDodgerBlue);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrRed);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2, clrGreen);
   IndicatorShortName("RSIchannels(" + IntegerToString(RSI_Period) + "," + IntegerToString(EMA_Period) + ")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
   if(rates_total < RSI_Period + EMA_Period)
      return(0);
   int start = prev_calculated - 1;
   if(start < 0)
      start = 0;
// Calculate RSI
   for(int i = start; i < rates_total; i++)
     {
      RSIBuffer[i] = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, i);
     }
// Calculate EMA Channels
   for(int i = start; i < rates_total; i++)
     {
      double emaValue = iMAOnArray(RSIBuffer, rates_total, EMA_Period, 0, MODE_EMA, i);
      UpperEMABuffer[i] = emaValue + ChannelWidth;
      LowerEMABuffer[i] = emaValue - ChannelWidth;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+