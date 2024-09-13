//+------------------------------------------------------------------+
//|                                           Adaptive Log Trend.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrGray
#property indicator_color2 clrBlue
#property indicator_color3 clrRed
#property indicator_color4 clrGreen

// Indicator input parameters
input int UseLongTermChannel = 0;
input double DeviationMultiplier = 2.0;
input color ChannelColor = clrGray;
input int ChannelLineStyle = 0; // 0-Solid, 1-Dotted, 2-Dashed
input int ExtendStyle = 0; // 0-Extend Right, 1-Extend Both, 2-Extend None, 3-Extend Left
input int FillTransparency = 93;
input int LineTransparency = 40;
input color MidlineColor = clrBlue;
input int MidlineTransp = 100;
input int MidlineWidth = 1;
input int MidlineLineStyle = 2; // 0-Dotted, 1-Solid, 2-Dashed

// Buffers for storing values
double UpperBuffer[];
double MidlineBuffer[];
double LowerBuffer[];

// Declarations
double detectedSlope, detectedIntercept, detectedStdDev;
int detectedPeriod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    // Indicator buffers
    SetIndexBuffer(0, UpperBuffer);
    SetIndexBuffer(1, MidlineBuffer);
    SetIndexBuffer(2, LowerBuffer);
    
    // Set line properties
    SetIndexStyle(0, DRAW_LINE, ChannelLineStyle, 1, ChannelColor);
    SetIndexStyle(1, DRAW_LINE, MidlineLineStyle, MidlineWidth, MidlineColor);
    SetIndexStyle(2, DRAW_LINE, ChannelLineStyle, 1, ChannelColor);
    
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
                const int &spread[]) {
    
    // Define period array based on UseLongTermChannel
    int periods[];
    if (UseLongTermChannel) {
        ArrayResize(periods, 19);
        for (int i = 0; i < 19; i++) periods[i] = 300 + i * 50;
    } else {
        ArrayResize(periods, 19);
        for (int i = 0; i < 19; i++) periods[i] = 20 + i * 10;
    }
    
    double highestPearsonR = -1.0;
    for (int i = 0; i < ArraySize(periods); i++) {
        int period = periods[i];
        if (period >= rates_total) continue;
        
        double stdDev, pearsonR, slope, intercept;
        if (!calcDev(close, period, stdDev, pearsonR, slope, intercept)) continue;
        
        if (pearsonR > highestPearsonR) {
            highestPearsonR = pearsonR;
            detectedPeriod = period;
            detectedSlope = slope;
            detectedIntercept = intercept;
            detectedStdDev = stdDev;
        }
    }

    if (highestPearsonR < 0) return(0); // No valid Pearson's R found
    
    int startAtBar = rates_total - detectedPeriod;
    double startPrice = MathExp(detectedIntercept + detectedSlope * (detectedPeriod - 1));
    double endPrice = MathExp(detectedIntercept);

    double upperStartPrice = startPrice * MathExp(DeviationMultiplier * detectedStdDev);
    double upperEndPrice = endPrice * MathExp(DeviationMultiplier * detectedStdDev);

    double lowerStartPrice = startPrice / MathExp(DeviationMultiplier * detectedStdDev);
    double lowerEndPrice = endPrice / MathExp(DeviationMultiplier * detectedStdDev);

    for (int i = startAtBar; i < rates_total; i++) {
        double slopePrice = MathExp(detectedIntercept + detectedSlope * (i - startAtBar));
        UpperBuffer[i] = slopePrice * MathExp(DeviationMultiplier * detectedStdDev);
        MidlineBuffer[i] = slopePrice;
        LowerBuffer[i] = slopePrice / MathExp(DeviationMultiplier * detectedStdDev);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Function to calculate deviations, correlation, slope, and intercepts |
//+------------------------------------------------------------------+
bool calcDev(const double &source[], int length, double &stdDev, double &pearsonR, double &slope, double &intercept) {
    double sumX = 0.0, sumXX = 0.0, sumYX = 0.0, sumY = 0.0;
    for (int i = 1; i <= length; i++) {
        double logSrc = MathLog(source[length - i]);
        sumX += i;
        sumXX += i * i;
        sumYX += i * logSrc;
        sumY += logSrc;
    }
    
    double lengthSumXX = length * sumXX;
    double sumXsumX = sumX * sumX;
    double lengthSumYX = length * sumYX;
    double sumXsumY = sumX * sumY;
    double denom = lengthSumXX - sumXsumX;
    if (denom == 0.0) return(false); // Avoid division by zero
    
    slope = (lengthSumYX - sumXsumY) / denom;
    double average = sumY / length;
    intercept = average - (slope * sumX / length) + slope;
    
    double sumDev = 0.0, sumDxx = 0.0, sumDyy = 0.0, sumDyx = 0.0;
    double regres = intercept + slope * (length - 1) * 0.5;
    double sumSlp = intercept;
    
    for (int i = 0; i < length; i++) {
        double logSrc = MathLog(source[length - 1 - i]);
        double dxt = logSrc - average;
        double dyt = sumSlp - regres;
        logSrc -= sumSlp;
        sumSlp += slope;
        sumDxx += dxt * dxt;
        sumDyy += dyt * dyt;
        sumDyx += dxt * dyt;
        sumDev += logSrc * logSrc;
    }
    
    if (length > 1) stdDev = MathSqrt(sumDev / (length - 1)); // unbiased stdDev
    double divisor = sumDxx * sumDyy;
    if (divisor == 0.0) return(false); // Avoid division by zero
    
    pearsonR = sumDyx / MathSqrt(divisor);
    return(true);
}
