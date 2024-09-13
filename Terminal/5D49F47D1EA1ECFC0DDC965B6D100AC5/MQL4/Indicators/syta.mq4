//+------------------------------------------------------------------+
//|                                                      anusha2.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
// Define criteria for identifying order blocks
double minVolume = 2000;  // Minimum volume threshold
double minRange = 0.00320; // Minimum price range for an order block
datetime lastAlertTime = 0;
// Define global variables for current order block support and resistance levels
double currentSupportLevel = 0;
double currentResistanceLevel = 0;
input int BarsCount=3;
double buyOrdersBuffer[];
double sellOrdersBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorBuffers(2); // 2 buffers for buy and sell orders
    SetIndexBuffer(0, buyOrdersBuffer);
    SetIndexBuffer(1, sellOrdersBuffer);
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexLabel(0, "Buy Orders");
    SetIndexLabel(1, "Sell Orders");
    return INIT_SUCCEEDED;
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
    // Detect order blocks
    FindOrderBlocks(rates_total, open, high, low, close, volume);
    // Calculate trend direction based on the proximity to support and resistance levels
    for(int i = rates_total - 1; i >= 0; i--)
    {
        if(close[i] > currentResistanceLevel)
        {
            // Implement your uptrend strategy here
            // For example, place a buy trade
            // You can also set alerts or update UI elements accordingly
            break;
        }
        else if(close[i] < currentSupportLevel)
        {
            // Implement your downtrend strategy here
            // For example, place a sell trade
            // You can also set alerts or update UI elements accordingly
            break;
        }
    }
    return rates_total;
}
//+------------------------------------------------------------------+
//| Search for potential order blocks                                |
//+------------------------------------------------------------------+
void FindOrderBlocks(const int rates_total,
                     const double &open[],
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     const long &volume[])
{
    // Reset support and resistance levels for each new order block
    currentSupportLevel = 0;
    currentResistanceLevel = 0;
    for(int i = 0; i < rates_total; i++)
    {
        double range = high[i] - low[i];
        long candleVolume = iVolume(NULL,0,i);
        if(range >= minRange && candleVolume >= minVolume)
        {
            // Draw the order block
            ObjectCreate("OrderBlock_" + IntegerToString(i), OBJ_RECTANGLE, 0, Time[i], close[i], Time[i-5], close[i-5]);
            ObjectSetInteger(0, "OrderBlock_" + IntegerToString(i), OBJPROP_COLOR, clrBlue);
            ObjectSetInteger(0, "OrderBlock_" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
            // Set support and resistance levels for the current order block
            currentSupportLevel = low[i];
            currentResistanceLevel = high[i];
            // Draw support and resistance lines for the current order block
            ObjectCreate("SupportZone_" + IntegerToString(i), OBJ_HLINE, 0, Time[i], currentSupportLevel);
            ObjectSetInteger(0, "SupportZone_" + IntegerToString(i), OBJPROP_COLOR, clrGreen);
            ObjectSetInteger(0, "SupportZone_" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
            ObjectCreate("ResistanceZone_" + IntegerToString(i), OBJ_HLINE, 0, Time[i], currentResistanceLevel);
            ObjectSetInteger(0, "ResistanceZone_" + IntegerToString(i), OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, "ResistanceZone_" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
            break; // Exit loop after finding the first order block
        }
    }
}
//+------------------------------------------------------------------+
//| Function to detect fair value gaps                               |
//+------------------------------------------------------------------+
void FindFairValueGaps(const int rates_total,
                       const double &open[],
                       const double &high[],
                       const double &low[],
                       const double &close[],
                       const long &volume[])
{
    // Your existing code for fair value gaps detection goes here
    for(int i = BarsCount - 1; i < rates_total; i++)
    {
        bool isGreenCandle3 = close[i] > open[i];
        bool isGreenCandle2 = close[i - 1] > open[i - 1];
        bool isGreenCandle1 = close[i - 2] > open[i - 2];
        bool isRedCandle3 = close[i] < open[i];
        bool isRedCandle2 = close[i - 1] < open[i - 1];
        bool isRedCandle1 = close[i - 2] < open[i - 2];
        if(isGreenCandle1 && isGreenCandle2 && isGreenCandle3)
        {
            ObjectCreate(0, "GreenRectangle" + IntegerToString(i), OBJ_RECTANGLE, 0, Time[i - 1], Close[i - 1], Time[i+10], Close[i]);
            ObjectSetInteger(0, "GreenRectangle" + IntegerToString(i), OBJPROP_COLOR, clrOrange);
            ObjectSetInteger(0, "GreenRectangle" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
            break;
        }
        if(isRedCandle1 && isRedCandle2 && isRedCandle3)
        {
            ObjectCreate(0, "RedRectangle" + IntegerToString(i), OBJ_RECTANGLE, 0, Time[i - 1], Close[i - 1], Time[i+10], Close[i]);
            ObjectSetInteger(0, "RedRectangle" + IntegerToString(i), OBJPROP_COLOR, clrPurple);
            ObjectSetInteger(0, "RedRectangle" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
            break;
        }
    }
    int buyTrades = 0;
    int sellTrades = 0;
    for(int j = 0; j < OrdersTotal(); j++)
    {
        if(OrderSelect(j, SELECT_BY_POS) && OrderSymbol() == _Symbol)
        {
            if(OrderType() == OP_BUY)
                buyTrades++;
            if(OrderType() == OP_SELL)
                sellTrades++;
        }
    }
    buyOrdersBuffer[rates_total - 1] = buyTrades;
    sellOrdersBuffer[rates_total - 1] = sellTrades;
}
//+------------------------------------------------------------------+
//| Function to plot trend meter                                      |
//+------------------------------------------------------------------+
void PlotTrendMeter(const double &close[])
{
    int currentBar = Bars - 1;
    bool uptrend = close[currentBar] > currentResistanceLevel;
    bool downtrend = close[currentBar] < currentSupportLevel;
    // Draw trend meter
    if(uptrend)
    {
        // Draw trend meter in green color
        ObjectCreate("TrendMeter", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_XDISTANCE, 1200);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_YDISTANCE, 20);
        ObjectSetText("TrendMeter", "Uptrend", 10, "Arial", clrGreen);
    }
    else if(downtrend)
    {
        // Draw trend meter in red color
        ObjectCreate("TrendMeter", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_XDISTANCE, 1200);
        ObjectSetInteger(0, "TrendMeter", OBJPROP_YDISTANCE, 20);
        ObjectSetText("TrendMeter", "Downtrend", 10, "Arial", clrRed);
    }
}