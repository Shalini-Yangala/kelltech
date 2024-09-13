
//+------------------------------------------------------------------+
//|                                           Adaptive Log Trend.mq4 |
//|                                                               NA |
//|                                                               NA |
//+------------------------------------------------------------------+
#property copyright   "NA"
#property link        "NA"
#property indicator_chart_window
#property strict

// Input parameters
input int sourceInput = 0;        // 0: close, 1: open, 2: high, 3: low
input int period = 20;            // Period to calculate the channel
input double devMultiplier = 2.0; // Deviation Multiplier
input color colorInput = clrRed;  // Channel color
input int lineWidth = 1;          // Channel Line Width

double logPrice[];
double slope[], intercept[], unStdDev[];

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
   
   IndicatorBuffers(2);
   SetIndexBuffer(0, slope);
   SetIndexBuffer(1, intercept);
   
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
   // Update log prices
   for (int i = 0; i < period; i++) {
      switch (sourceInput) {
         case 0: logPrice[i] = MathLog(close[i]); break;
         case 1: logPrice[i] = MathLog(open[i]); break;
         case 2: logPrice[i] = MathLog(high[i]); break;
         case 3: logPrice[i] = MathLog(low[i]); break;
      }
   }
   
   // Calculate deviations
   calcDev(period);
   
   // Draw the upper and lower channels
   double startPrice = MathExp(intercept[period - 1] + slope[period - 1] * (period - 1));
   double endPrice = MathExp(intercept[period - 1]);
   
   int startAtBar = iBarShift(NULL, 0, Time[period - 1]);
   
   // Example of drawing upper and lower lines
   ObjectCreate(0, "UpperLine", OBJ_CHANNEL, 0, Time[startAtBar], startPrice + unStdDev[period - 1] * devMultiplier, Time[0], endPrice + unStdDev[period - 1] * devMultiplier);
   ObjectCreate(0, "LowerLine", OBJ_CHANNEL, 0, Time[startAtBar], startPrice - unStdDev[period - 1] * devMultiplier, Time[0], endPrice - unStdDev[period - 1] * devMultiplier);
   
   ObjectSetInteger(0, "UpperLine", OBJPROP_COLOR, colorInput);
   ObjectSetInteger(0, "UpperLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "UpperLine", OBJPROP_WIDTH, lineWidth);
   
   ObjectSetInteger(0, "LowerLine", OBJPROP_COLOR, colorInput);
   ObjectSetInteger(0, "LowerLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "LowerLine", OBJPROP_WIDTH, lineWidth);
   
   return (rates_total);
}
