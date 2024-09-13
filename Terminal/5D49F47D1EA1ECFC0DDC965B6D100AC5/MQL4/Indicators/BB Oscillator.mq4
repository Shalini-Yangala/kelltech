
//+------------------------------------------------------------------+
//|                                               BB Oscillator.mq4 |
//|                                               Copyright 2024,NA. |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,NA."
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
// Input parameters
extern int Period = 20;               // Period for Bollinger Bands calculation
extern int Deviation = 2;             // Standard deviation multiplier for Bollinger Bands
// Arrays to store Bollinger Bands data
double middle_band[];
double upper_band[];
double lower_band[];
// Variable to track the last Arrow
int lastArrow = 0; // 0 - no Arrow, 1 - buy Arrow, 2 - sell Arrow
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Assign indicator buffers
    SetIndexBuffer(0, upper_band);
    SetIndexBuffer(1, lower_band);
    SetIndexBuffer(2, middle_band);
    // Set indicator labels
    IndicatorSetString(INDICATOR_SHORTNAME, "Bollinger Bands"); // Indicator name
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
    // Calculate Bollinger Bands and plot arrows
    for(int i = rates_total - 1; i >= 0; i--)
    {
        double ma = iMA(NULL, 0, Period, 0, MODE_SMA, PRICE_CLOSE, i); // Calculate moving average
        double stdDev = Deviation * iStdDev(NULL, 0, Period, 0, MODE_SMA, PRICE_CLOSE, i); // Calculate standard deviation
        middle_band[i] = ma; // Middle band value
        upper_band[i] = ma + stdDev; // Upper band value
        lower_band[i] = ma - stdDev; // Lower band value
        // Buy condition: close below lower band or touches lower band --OverSold Condition
        if(close[i] < lower_band[i] || (low[i] <= lower_band[i] && close[i] > lower_band[i]))
        {
            if(lastArrow != 1)
            {
                // Plot buy arrow
                ObjectCreate("Buy_Arrow"+IntegerToString(i), OBJ_ARROW, 1, time[i], high[i] - 10 * Point);
                ObjectSetInteger(0, "Buy_Arrow"+IntegerToString(i), OBJPROP_ARROWCODE, 233); // Plot buy arrow
                ObjectSetInteger(0, "Buy_Arrow"+IntegerToString(i), OBJPROP_COLOR, clrBlue); // Set arrow color
                lastArrow = 1; // Update last Arrow to buy
            }
        }
        // Sell condition: close above upper band or touches upper band--OverBought Condition
        else if(close[i] > upper_band[i] || (high[i] >= upper_band[i] && close[i] < upper_band[i]))
        {
            if(lastArrow != 2)
            {
                // Plot sell arrow
                ObjectCreate("Sell_Arrow"+IntegerToString(i), OBJ_ARROW, 1, time[i], low[i] - 10 * Point);
                ObjectSetInteger(0, "Sell_Arrow"+IntegerToString(i), OBJPROP_ARROWCODE, 234); // Plot sell arrow
                ObjectSetInteger(0, "Sell_Arrow"+IntegerToString(i), OBJPROP_COLOR, clrRed); // Set arrow color
                lastArrow = 2; // Update last Arrow to sell
            }
        }
    }
    return rates_total;
}
//+--------------------------------------------------------------------------------------------------------+









