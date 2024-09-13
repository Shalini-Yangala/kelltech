//+------------------------------------------------------------------+
//|                                          Adaptive Log Trend.mq5  |
//|                                                               NA |
//|                                                               NA |
//+------------------------------------------------------------------+
#property copyright   "NA"
#property link        "NA"
#property indicator_chart_window
#property strict

#property indicator_buffers 4  // Number of buffers
#property indicator_color1 clrRed
#property indicator_color2 clrRed
#property indicator_color3 clrBlue // Optional for debugging

// Input parameters
input ENUM_APPLIED_PRICE sourceInput = PRICE_CLOSE; // 0: close, 1: open, 2: high, 3: low
input int period = 20;            // Period to calculate the channel
input double devMultiplier = 2.0; // Deviation Multiplier
input color colorInput = clrRed;  // Channel color
input int lineWidth = 1;          // Channel Line Width

double logPrice[];
double slope[], intercept[], unStdDev[];
double upperLine[], lowerLine[];

// Function to calculate deviations
void calcDev(int length) {
    double sumX_local = 0, sumXX_local = 0, sumYX_local = 0, sumY_local = 0;
    double logSource, lSrc, dxt, dyt;
    int period_1 = length - 1;

    for (int i = 1; i <= length; i++) {
        logSource = logPrice[i - 1];
        sumX_local += i;
        sumXX_local += i * i;
        sumYX_local += i * logSource;
        sumY_local += logSource;
    }

    slope[length - 1] = (length * sumYX_local - sumX_local * sumY_local) / (length * sumXX_local - sumX_local * sumX_local);
    intercept[length - 1] = (sumY_local / length) - (slope[length - 1] * sumX_local / length) + slope[length - 1];
    double sumDev = 0, sumDxx = 0, sumDyy = 0, sumDyx = 0;
    double sumSlp = intercept[length - 1];
    double regres = intercept[length - 1] + slope[length - 1] * period_1 * 0.5;
    double average = sumY_local / length;

    for (int i = 0; i <= period_1; i++) {
        lSrc = logPrice[i];
        dxt = lSrc - average;
        dyt = sumSlp - regres;
        lSrc -= sumSlp;
        sumSlp += slope[length - 1];
        sumDxx += dxt * dxt;
        sumDyy += dyt * dyt;
        sumDyx += dxt * dyt;
        sumDev += lSrc * lSrc;
    }

    unStdDev[length - 1] = MathSqrt(sumDev / period_1);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    ArrayResize(logPrice, period);
    ArrayResize(slope, period);
    ArrayResize(intercept, period);
    ArrayResize(unStdDev, period);
    ArrayResize(upperLine, period);
    ArrayResize(lowerLine, period);

    SetIndexBuffer(0, upperLine, INDICATOR_DATA);
    SetIndexBuffer(1, lowerLine, INDICATOR_DATA);
    SetIndexBuffer(2, slope);
    SetIndexBuffer(3, intercept); // Optional for debugging

    PlotIndexSetInteger(0, PLOT_LINE_COLOR, colorInput);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, colorInput);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, lineWidth);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, lineWidth);

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
    if (rates_total < period) return 0;

    // Get historical data
    double prices[];
    ArrayResize(prices, rates_total);

    switch (sourceInput) {
        case PRICE_CLOSE: CopyClose(_Symbol, PERIOD_CURRENT, 0, rates_total, prices); break;
        case PRICE_OPEN:  CopyOpen(_Symbol, PERIOD_CURRENT, 0, rates_total, prices); break;
        case PRICE_HIGH:  CopyHigh(_Symbol, PERIOD_CURRENT, 0, rates_total, prices); break;
        case PRICE_LOW:   CopyLow(_Symbol, PERIOD_CURRENT, 0, rates_total, prices); break;
    }

    // Update log prices
    for (int i = 0; i < period; i++) {
        logPrice[i] = MathLog(prices[i]);
    }

    // Calculate deviations
    calcDev(period);

    // Draw the upper and lower channels
    double startPrice = MathExp(intercept[period - 1] + slope[period - 1] * (period - 1));
    double endPrice = MathExp(intercept[period - 1]);

    upperLine[0] = startPrice + unStdDev[period - 1] * devMultiplier;
    lowerLine[0] = startPrice - unStdDev[period - 1] * devMultiplier;
    upperLine[1] = endPrice + unStdDev[period - 1] * devMultiplier;
    lowerLine[1] = endPrice - unStdDev[period - 1] * devMultiplier;

    return (rates_total);
}
