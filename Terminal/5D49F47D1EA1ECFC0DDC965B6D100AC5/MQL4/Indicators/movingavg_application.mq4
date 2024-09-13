//+------------------------------------------------------------------+
//|                                        movingavg_application.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
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
//---
    for(int i=0; i<rates_total; i++)
     {
      double var1= iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,i);
      double var2=iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i);
      //BUY COndition
      if(var1>var2)
        {
         ObjectCreate(0,"Buy arrow",OBJ_ARROW,0,Time[i],Low[i]);
         ObjectSetInteger(0,"Buy arrow",OBJPROP_ARROWCODE,233);
         ObjectSetInteger(0,"Buy arrow",OBJPROP_COLOR,clrBlue);
        }
      //SELL Condition
      if(var1<var2)
        {
         ObjectCreate(0,"Sell arrow",OBJ_ARROW,0,Time[i],High[i]);
         ObjectSetInteger(0,"Sell arrow",OBJPROP_ARROWCODE,234);
         ObjectSetInteger(0,"Sell arrow",OBJPROP_COLOR,clrRed);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+









