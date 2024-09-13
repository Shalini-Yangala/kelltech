//+------------------------------------------------------------------+
//|                                                   EMA Ribbon.mq4 |
//|                                     Copyright 2024, Merchant Fx. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Merchant Fx."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1 clrGreen  // EMA 6
#property indicator_color2 clrRed    // EMA 14
#property indicator_color3 clrRed    // EMA 21
#property indicator_color4 clrRed    // EMA 30
#property indicator_color5 clrRed    // EMA 50
#property indicator_color6 clrRed    // EMA 100
#property indicator_color7 clrGreen  // EMA 200
#property indicator_color8 clrGreen  // Buy Arrows
#property indicator_color9 clrRed    // Sell Arrows
//--- input parameters
input int EMA1_Period = 6;
input int EMA2_Period = 14;
input int EMA3_Period = 21;
input int EMA4_Period = 30;
input int EMA5_Period = 50;
input int EMA6_Period = 100;
input int EMA7_Period = 200;
input bool AlertsOn = false;
//--- indicator buffers
double EMA1_Buffer[];
double EMA2_Buffer[];
double EMA3_Buffer[];
double EMA4_Buffer[];
double EMA5_Buffer[];
double EMA6_Buffer[];
double EMA7_Buffer[];
double BuyArrow_Buffer[];
double SellArrow_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    // Indicator buffers mapping
    SetIndexBuffer(0, EMA1_Buffer);
    SetIndexBuffer(1, EMA2_Buffer);
    SetIndexBuffer(2, EMA3_Buffer);
    SetIndexBuffer(3, EMA4_Buffer);
    SetIndexBuffer(4, EMA5_Buffer);
    SetIndexBuffer(5, EMA6_Buffer);
    SetIndexBuffer(6, EMA7_Buffer);
    SetIndexBuffer(7, BuyArrow_Buffer);
    SetIndexBuffer(8, SellArrow_Buffer);
    // Indicator styles
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrGreen);  // EMA 6
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrRed);    // EMA 14
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrRed);    // EMA 21
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, clrRed);    // EMA 30
    SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, clrRed);    // EMA 50
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, clrRed);    // EMA 100
    SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 2, clrGreen);  // EMA 200
    // Arrows styles
    SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, 2, clrGreen);
    SetIndexArrow(7, 233);  // Arrow code for buy
    SetIndexStyle(8, DRAW_ARROW, STYLE_SOLID, 2, clrRed);
    SetIndexArrow(8, 234);  // Arrow code for sell
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
    // Calculate EMAs
    for (int i = 0; i < rates_total; i++)
    {
        EMA1_Buffer[i] = iMA(NULL, 0, EMA1_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA2_Buffer[i] = iMA(NULL, 0, EMA2_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA3_Buffer[i] = iMA(NULL, 0, EMA3_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA4_Buffer[i] = iMA(NULL, 0, EMA4_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA5_Buffer[i] = iMA(NULL, 0, EMA5_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA6_Buffer[i] = iMA(NULL, 0, EMA6_Period, 0, MODE_EMA, PRICE_CLOSE, i);
        EMA7_Buffer[i] = iMA(NULL, 0, EMA7_Period, 0, MODE_EMA, PRICE_CLOSE, i);
    }
    // Detect crossovers and generate arrows
    for (int i = 1; i < rates_total; i++)
    {
        // Check for buy crossover
        if (EMA1_Buffer[i] > EMA7_Buffer[i] && EMA1_Buffer[i - 1] <= EMA7_Buffer[i - 1])
        {
            BuyArrow_Buffer[i] = Low[i] - (Point * 10);
            if (AlertsOn)
                Alert("Buy Signal at ", TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
        }
        // Check for sell crossover
        else if (EMA1_Buffer[i] < EMA7_Buffer[i] && EMA1_Buffer[i - 1] >= EMA7_Buffer[i - 1])
        {
            SellArrow_Buffer[i] = High[i] + (Point * 10);
            if (AlertsOn)
                Alert("Sell Signal at ", TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
        }
    }
    return(rates_total);
  }