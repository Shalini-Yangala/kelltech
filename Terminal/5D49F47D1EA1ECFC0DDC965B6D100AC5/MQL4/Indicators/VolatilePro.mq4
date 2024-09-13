//+------------------------------------------------------------------+
//|                                                  VolatilePro.mq4 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.01"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

// Input parameters for ATR and EMA periods
input int atrPeriod = 14;
input int shortEmaPeriod = 5;
input int longEmaPeriod = 10;

// Indicator buffers
double atrBuffer[];
double shortEmaBuffer[];
double longEmaBuffer[];
double finalValueBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set indicator buffer
    SetIndexBuffer(0, finalValueBuffer);
    ArraySetAsSeries(finalValueBuffer, true);
    
    // Set indicator properties
    IndicatorShortName("VolatilePro Indicator");
    SetIndexLabel(0, "VolatilePro");
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrBlue);
    
    // Resize buffers
    ArrayResize(atrBuffer, 0);
    ArrayResize(shortEmaBuffer, 0);
    ArrayResize(longEmaBuffer, 0);
    ArrayResize(finalValueBuffer, 0);

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
    // Check for sufficient bars to calculate ATR and EMAs
    if (rates_total < atrPeriod || rates_total < shortEmaPeriod || rates_total < longEmaPeriod)
        return 0;

    // Resize buffers to the current number of bars
    ArrayResize(atrBuffer, rates_total);
    ArrayResize(shortEmaBuffer, rates_total);
    ArrayResize(longEmaBuffer, rates_total);
    ArrayResize(finalValueBuffer, rates_total);

    int begin = atrPeriod + longEmaPeriod - 1;
    if (rates_total < begin)
        return 0;

    // Calculate ATR
    for (int i = 0; i < rates_total; i++) {
        atrBuffer[i] = iATR(NULL, 0, atrPeriod, i);
    }

    // Calculate short-term EMA of ATR
    for (int i = 0; i < rates_total; i++) {
        shortEmaBuffer[i] = iMAOnArray(atrBuffer, rates_total, shortEmaPeriod, 0, MODE_EMA, i);
    }

    // Calculate long-term EMA of ATR
    for (int i = 0; i < rates_total; i++) {
        longEmaBuffer[i] = iMAOnArray(atrBuffer, rates_total, longEmaPeriod, 0, MODE_EMA, i);
    }

    // Calculate final value (oscillator line)
    for (int i = 0; i < rates_total; i++) {
        // Avoid division by zero
        if (longEmaBuffer[i] != 0) {
            double favRatio = shortEmaBuffer[i] / longEmaBuffer[i];
            finalValueBuffer[i] = (favRatio - 1) * 100;
        } else {
            finalValueBuffer[i] = 0; // Handle division by zero
        }
    }

    // Debug: Print values for inspection
    Print("Final Value Buffer: ", finalValueBuffer[0]);

    return rates_total;
}
