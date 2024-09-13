#property indicator_chart_window
//---Global Variables
input int lookBackPeriod_recent = 50;
input int lookBackPeriod_global = 50;
// Define the Gann angles (in degrees)
double gannAngles[] = {45, 26.25, 18.75, 12.86, 9, 7.5, 5.625, 4.2857};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
   //---Nothing here
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---Delete objects on deinitialization
   ObjectDelete(0, "Global Resistance");
   ObjectDelete(0, "Global Support");
   ObjectDelete(0, "Trend");
   ObjectDelete(0, "GannBox");
}
//+------------------------------------------------------------------+
//|                                                                  |
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
   // Find global high and low
   double globalHigh = FindHighestFractal(lookBackPeriod_global);
   double globalLow = FindLowestFractal(lookBackPeriod_global);
   datetime cTime = TimeCurrent();  // Current time
   // Draw global support and resistance lines
   DrawHorizontalLine("Global Resistance", globalHigh, 0, cTime, clrAqua);
   DrawHorizontalLine("Global Support", 0, globalLow, cTime, clrAqua);
   // Draw Gann box with Fibonacci levels
   DrawGannBoxWithFibonacci("GannBox", globalHigh, globalLow, cTime, clrBlue);
   // Draw Gann angles within the Gann box
   DrawGannAngles("GannBox", globalHigh, globalLow, cTime, clrBlack);
   // Draw Gann fan
   DrawGannFan(true, clrDodgerBlue, clrMediumSeaGreen, clrDarkOrange, clrMediumSeaGreen, clrSkyBlue, clrRoyalBlue);
   // Draw Gann curves
   DrawGannCurves(true, clrRed, clrGreen, clrYellow, clrCyan);
   return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindHighestFractal(int count)
{
   double highestFractal = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
   {
      double upper = iFractals(NULL, 0, MODE_UPPER, i);
      if(upper != 0.0 && (highestFractal == EMPTY_VALUE || upper > highestFractal))
      {
         highestFractal = upper;
      }
   }
   return highestFractal;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindHighestFractalTime(int count)
{
   double highestFractal = EMPTY_VALUE;
   string timeStamp1 = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
   {
      double upper = iFractals(NULL, 0, MODE_UPPER, i);
      if(upper != 0.0 && (highestFractal == EMPTY_VALUE || upper > highestFractal))
      {
         highestFractal = upper;
         string day = TimeDay(Time[i]);
         string year = TimeYear(Time[i]);
         string month = TimeMonth(Time[i]);
         string hour = TimeHour(Time[i]);
         string minute = TimeMinute(Time[i]);
         string seconds = TimeSeconds(Time[i]);
         timeStamp1 = year + "/" + month + "/" + day + " " + hour + ":" + minute + ":" + seconds;
      }
   }
   return timeStamp1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLowestFractal(int count)
{
   double lowestFractal = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
   {
      double lower = iFractals(NULL, 0, MODE_LOWER, i);
      if(lower != 0.0 && (lowestFractal == EMPTY_VALUE || lower < lowestFractal))
      {
         lowestFractal = lower;
      }
   }
   return lowestFractal;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindLowestFractalTime(int count)
{
   double lowestFractal = EMPTY_VALUE;
   string timeStamp2 = EMPTY_VALUE;
   for(int i = 0; i < count; i++)
   {
      double lower = iFractals(NULL, 0, MODE_LOWER, i);
      if(lower != 0.0 && (lowestFractal == EMPTY_VALUE || lower < lowestFractal))
      {
         lowestFractal = lower;
         string day = TimeDay(Time[i]);
         string year = TimeYear(Time[i]);
         string month = TimeMonth(Time[i]);
         string hour = TimeHour(Time[i]);
         string minute = TimeMinute(Time[i]);
         string seconds = TimeSeconds(Time[i]);
         timeStamp2 = year + "/" + month + "/" + day + " " + hour + ":" + minute + ":" + seconds;
      }
   }
   return timeStamp2;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHorizontalLine(string lineName, double priceHigh, double priceLow, datetime time, color lineColor)
{
   if(priceLow == 0)
   {
      string lineName1 = lineName + DoubleToStr(priceHigh, Digits);
      ObjectCreate(0, lineName1, OBJ_HLINE, 0, time, priceHigh);
      ObjectSetInteger(0, lineName1, OBJPROP_COLOR, lineColor);
   }
   else if(priceHigh == 0)
   {
      string lineName2 = lineName + DoubleToStr(priceLow, Digits);
      ObjectCreate(0, lineName2, OBJ_HLINE, 0, time, priceLow);
      ObjectSetInteger(0, lineName2, OBJPROP_COLOR, lineColor);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGannBoxWithFibonacci(string boxName, double upperPrice, double lowerPrice, datetime time, color boxColor)
{
   // Draw Gann Box
   int candlesToShow = 50; // Number of candles to show
   double x1 = Time[0]; // Start time of the rectangle
   double y1 = upperPrice; // Y-coordinate of the upper edge (resistance)
   double x2 = Time[candlesToShow - 1]; // End time of the rectangle (based on the number of candles)
   double y2 = lowerPrice; // Y-coordinate of the lower edge (support)
   string rectangleName = boxName + "_Rectangle";
   ObjectCreate(0, rectangleName, OBJ_RECTANGLE, 0, x1, y1, x2, y2);
   ObjectSetInteger(0, rectangleName, OBJPROP_COLOR, boxColor);
   // Calculate support and resistance levels
   double midPrice = (upperPrice + lowerPrice) / 2.0;
   double supportLevel = lowerPrice + (midPrice - lowerPrice) / 2.0;
   double resistanceLevel = upperPrice - (upperPrice - midPrice) / 2.0;
   // Draw rectangles to highlight support and resistance zones
   string supportZoneName = boxName + "_SupportZone";
   ObjectCreate(0, supportZoneName, OBJ_RECTANGLE, 0, x1, lowerPrice, x2, supportLevel);
   ObjectSetInteger(0, supportZoneName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, supportZoneName, OBJPROP_BACK, true);
   string resistanceZoneName = boxName + "_ResistanceZone";
   ObjectCreate(0, resistanceZoneName, OBJ_RECTANGLE, 0, x1, resistanceLevel, x2, upperPrice);
   ObjectSetInteger(0, resistanceZoneName, OBJPROP_COLOR, clrLawnGreen);
   ObjectSetInteger(0, resistanceZoneName, OBJPROP_BACK, true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGannAngles(string boxName, double upperPrice, double lowerPrice, datetime time, color angleColor)
{

   int candlesToShow = 50; // Number of candles to show
   double x1 = Time[0]; // Start time of the rectangle
   double x2 = Time[candlesToShow - 1]; // End time of the rectangle (based on the number of candles)
   double distance = upperPrice - lowerPrice;
   // Draw Gann angles
   for(int i = 0; i < ArraySize(gannAngles); i++)
   {
      double angle = gannAngles[i];
      double slope = MathTan(DegreesToRadians(angle));
      double y1 = upperPrice + distance * slope;
      double y2 = lowerPrice - distance * slope;
      string angleName = boxName + "_Angle_" + DoubleToStr(angle, 2);
      ObjectCreate(0, angleName, OBJ_TRENDBYANGLE, 0, x1, y1, x2, y2);
      ObjectSetInteger(0, angleName, OBJPROP_COLOR, angleColor);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGannFan(bool show, color fcol1, color fcol2, color fcol3, color fcol4, color fcol5, color fcol6)
{
   // Draw Gann Fan if show is true
   if(show)
   {
      double x0, y0; // Coordinates for the anchor point
      double x6, y6; // Coordinates for the endpoint
      x0 = Time[10]; // Set anchor point at the 10th candle's time
      y0 = Low[10];  // Set anchor point at the low price of the 10th candle
      x6 = Time[0];  // Set endpoint at the current candle's time
      y6 = High[0];  // Set endpoint at the high price of the current candle
      for(int i = 0; i < 6; i++)
      {
         int line1 = ObjectCreate(0, "", OBJ_TREND, 0, x0, y0, x6, y0 + (y6 - y0) * (i + 1), 0, 0);
         ObjectSetInteger(0, "", OBJPROP_COLOR, fcol1 + i);
         int line2 = ObjectCreate(0, "", OBJ_TREND, 0, x0, y0, x6 + (x6 - x0), y6, 0, 0);
         ObjectSetInteger(0, "", OBJPROP_COLOR, fcol1 + i);
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGannCurves(bool show, color col1, color col2, color col3, color col4)
{
   if(show)
   {
      int bars = 100;  // Number of bars to calculate
      int curves = 4;   // Number of Gann curves to draw
      double step = 0.01;  // Step for drawing curves
      for(int i = 0; i < curves; i++)
      {
         string curveName = "GannCurve_" + IntegerToString(i);
         ObjectCreate(0, curveName, OBJ_TRENDBYANGLE, 0, 0, 0, 0, 0);
         ObjectSetInteger(0, curveName, OBJPROP_COLOR, col1 + i);
         ObjectSetInteger(0, curveName, OBJPROP_RAY_RIGHT, false);
         for(int j = 0; j < bars; j++)
         {
            double angle = (j + 1) * step * (i + 1) * 180.0 / 3.14;
            double y = MathTan(DegreesToRadians(angle)) * (High[0] - Low[0]) + High[0];
            ObjectMove(0, curveName, j, Time[j], y);
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Convert degrees to radians                                       |
//+------------------------------------------------------------------+
double DegreesToRadians(double degrees)
{
   return degrees * 3.14159 / 180.0;
}