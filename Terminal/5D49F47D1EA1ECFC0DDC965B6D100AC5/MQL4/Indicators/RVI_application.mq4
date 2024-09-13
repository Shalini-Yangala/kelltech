

//+------------------------------------------------------------------+
//|                                              RVI_application.mq4 |
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
    // Indicator buffers are not needed for this example
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
    for (int i = 0; i < rates_total; i++)
    {
        double rvi_value = iRVI(NULL, 0, 10, MODE_MAIN, i); // Calculate RVI value for the current bar
        // Check RVI value for buy and sell conditions
        if (rvi_value > 0)
        {
            ObjectCreate(0, "BuyArrow", OBJ_ARROW, 0, time[i], low[i]);
            ObjectSetInteger(0, "BuyArrow", OBJPROP_ARROWCODE, 233);
            ObjectSetInteger(0, "BuyArrow", OBJPROP_COLOR, clrRed);
        }
        else if (rvi_value < 0)
        {
            ObjectCreate(0, "SellArrow", OBJ_ARROW, 0, time[i], high[i]);
            ObjectSetInteger(0, "SellArrow", OBJPROP_ARROWCODE, 234);
            ObjectSetInteger(0, "SellArrow", OBJPROP_COLOR, clrGreen);
        }
    }
    return (rates_total); // Return value of prev_calculated for the next call
}