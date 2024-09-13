//+------------------------------------------------------------------+
//|                                                      Heatmap.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

// Indicator buffers
double RedBuffer[];
double GreenBuffer[];

// Input parameters
input int Length = 14;
input double OverSold = 30;
input double OverBought = 70;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffers mapping
   SetIndexBuffer(0, RedBuffer);
   SetIndexBuffer(1, GreenBuffer);
   
   IndicatorShortName("HeatMap");
   
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
   int i, limit;
   
   // Check for sufficient bars
   if(rates_total < Length)
      return(0);
      
   limit = rates_total - prev_calculated;
   
   for(i = 0; i < limit; i++)
     {
      double rsiValue = iRSI(NULL, 0, Length, PRICE_CLOSE, i);
      
      // Clear previous values
      RedBuffer[i] = 0.0;
      GreenBuffer[i] = 0.0;
      
      // Set buffer values based on RSI conditions
      if(rsiValue > OverBought)
         RedBuffer[i] = close[i];
      else if(rsiValue < OverSold)
         GreenBuffer[i] = close[i];
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
