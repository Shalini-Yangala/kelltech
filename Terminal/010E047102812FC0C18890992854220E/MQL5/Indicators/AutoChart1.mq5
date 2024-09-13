
//+------------------------------------------------------------------+
//|                                                   AutoChart.mq5 |
//|                                             Elite Forex Trades   |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// Define constants for FVG (Fair Value Gap) rectangles
#define FVGPrefix "FvgRec"
#define clrUp clrLimeGreen
#define clrDn clrRed

// Input parameters for indicator settings
input int WedgePeriod = 30;              // Period for calculating wedge patterns
input int ChannelPeriod = 50;            // Period for calculating channel patterns
input int TrianglePeriod = 30;           // Period for calculating triangle patterns
input bool DetectWedges = true;          // Enable detection of wedge patterns
input bool DetectChannels = true;        // Enable detection of channel patterns
input bool DetectTriangles = true;       // Enable detection of triangle patterns
input bool AutoUpdate = true;            // Enable automatic updating of drawings
input bool DetectFVG = true;             // Enable detection of Fair Value Gaps (FVG)
input int VolumeProfilePeriod = 20;      // Period for calculating volume profile

input ENUM_TIMEFRAMES Timeframe1 = PERIOD_H4; // First higher timeframe for support/resistance
input ENUM_TIMEFRAMES Timeframe2 = PERIOD_D1; // Second higher timeframe for support/resistance
input int LookBackPeriod = 20;           // Number of bars to look back for calculating levels
input color ResistanceColor = clrRed;   // Color for resistance lines
input color SupportColor = clrBlue;     // Color for support lines
input int LineStyle = STYLE_SOLID;      // Style of the lines
input int LineWidth = 2;                // Width of the lines

// Indicator buffers for support and resistance levels
double SupportBuffer[];
double ResistanceBuffer[];
// Number of bars in the current chart
int bars1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize indicator buffers
   SetIndexBuffer(0, SupportBuffer);
   SetIndexBuffer(1, ResistanceBuffer);
   bars1 = iBars(_Symbol, PERIOD_CURRENT); // Get the number of bars on the current chart
   
   // Ensure all existing objects are deleted to avoid duplication
   DeleteAllObjects();
   
   // Draw Fair Value Gaps (FVG) if enabled
   if (DetectFVG)
   {
      DrawFVG();
   }
   
   return(INIT_SUCCEEDED); // Initialization successful
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete all chart objects when the indicator is removed
   DeleteAllObjects();
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
   // Calculate support and resistance levels from higher timeframes
   double SupportLevel1 = iLow(NULL, Timeframe1, iLowest(NULL, Timeframe1, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel1 = iHigh(NULL, Timeframe1, iHighest(NULL, Timeframe1, MODE_HIGH, LookBackPeriod, 0));
   double SupportLevel2 = iLow(NULL, Timeframe2, iLowest(NULL, Timeframe2, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel2 = iHigh(NULL, Timeframe2, iHighest(NULL, Timeframe2, MODE_HIGH, LookBackPeriod, 0));

   // Draw support and resistance lines
   DrawLevel("Support1", SupportLevel1, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance1", ResistanceLevel1, ResistanceColor, LineStyle, LineWidth);
   DrawLevel("Support2", SupportLevel2, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance2", ResistanceLevel2, ResistanceColor, LineStyle, LineWidth);
   
   if (AutoUpdate)
   {
      // Remove all previously drawn objects if AutoUpdate is enabled
      DeleteAllObjects();
      
      // Draw wedge patterns if enabled
      if(DetectWedges)
      {
         DrawWedge(WedgePeriod, true);  // Rising wedge
         DrawWedge(WedgePeriod, false); // Falling wedge
      }
      
      // Draw channel patterns if enabled
      if(DetectChannels)
      {
         DrawChannel(ChannelPeriod);
      }
      
      // Draw triangle patterns if enabled
      if(DetectTriangles)
      {
         DrawTriangle(TrianglePeriod, true);  // Ascending triangle
         DrawTriangle(TrianglePeriod, false); // Descending triangle
      }
   }
   
   // Draw Fair Value Gaps (FVG) if enabled
   if(DetectFVG)
   {
      DrawFVG();
   }
   
   // Draw volume profile
   DrawVolumeProfile(VolumeProfilePeriod);
   
   return(rates_total); // Return the total number of rates
}

//+------------------------------------------------------------------+
//| Function to delete all objects                                   |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   // Delete FVG rectangles
   ObjectsDeleteAll(0, FVGPrefix);
   // Delete various chart objects
   ObjectDelete(0, "RisingWedge");
   ObjectDelete(0, "FallingWedge");
   ObjectDelete(0, "UpperChannelLine");
   ObjectDelete(0, "LowerChannelLine");
   ObjectDelete(0, "AscendingTriangle");
   ObjectDelete(0, "DescendingTriangle");
   ObjectsDeleteAll(0, "VolumeProfile");
}

//+------------------------------------------------------------------+
//| Function to draw horizontal lines for support and resistance     |
//+------------------------------------------------------------------+
void DrawLevel(string name, double price, color clr, int style, int width)
{
   // Check if the line already exists
   if(ObjectFind(0, name) != 0)
   {
      // Create a new horizontal line if it does not exist
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   }
   else
   {
      // Update the existing line with new price
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   }
}

//+------------------------------------------------------------------+
//| Function to draw Fair Value Gaps (FVG)                           |
//+------------------------------------------------------------------+
void DrawFVG()
{
   int visibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   
   for(int i = 0; i < visibleBars - 2; i++)
   {
      double low0 = iLow(_Symbol, PERIOD_CURRENT, i);
      double high2 = iHigh(_Symbol, PERIOD_CURRENT, i + 2);
      double high0 = iHigh(_Symbol, PERIOD_CURRENT, i);
      double low2 = iLow(_Symbol, PERIOD_CURRENT, i + 2);
      bool fvgUp = low0 > high2;
      bool fvgDown = low2 > high0;
      
      if(fvgUp || fvgDown)
      {
         datetime time1 = iTime(_Symbol, PERIOD_CURRENT, i + 1);
         double price1 = fvgUp ? high2 : high0;
         datetime time2 = time1 + PeriodSeconds(PERIOD_CURRENT) * 10;
         double price2 = fvgUp ? low0 : low2;
         string fvgName = FVGPrefix + "(" + TimeToString(time1) + ")";
         color fvgClr = fvgUp ? clrUp : clrDn;
         CreateRectangle(fvgName, time1, price1, time2, price2, fvgClr);
      }
   }
}

//+------------------------------------------------------------------+
//| Function to create a rectangle object                            |
//+------------------------------------------------------------------+
void CreateRectangle(string objName, datetime time1, double price1, datetime time2, double price2, color clr)
{
   if(ObjectFind(0, objName) < 0)
   {
      // Create a rectangle for the FVG
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_FILL, true);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   }
}

//+------------------------------------------------------------------+
//| Function to draw wedge patterns                                  |
//+------------------------------------------------------------------+
void DrawWedge(int period, bool isRising)
{
   int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
   if (bars <= 0)
      return;

   int upperStart = 0, upperEnd = 0;
   double upperStartPrice = iHigh(_Symbol, PERIOD_CURRENT, upperStart);
   double upperEndPrice = iHigh(_Symbol, PERIOD_CURRENT, upperEnd);

   int lowerStart = 0, lowerEnd = 0;
   double lowerStartPrice = iLow(_Symbol, PERIOD_CURRENT, lowerStart);
   double lowerEndPrice = iLow(_Symbol, PERIOD_CURRENT, lowerEnd);

   // Find wedge start and end points
   for (int i = 0; i < bars; i++)
   {
      double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
      double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
      if (isRising)
      {
         if (highPrice > upperStartPrice)
         {
            upperStart = i;
            upperStartPrice = highPrice;
         }
         if (lowPrice < lowerEndPrice)
         {
            lowerEnd = i;
            lowerEndPrice = lowPrice;
         }
      }
      else
      {
         if (highPrice < upperStartPrice)
         {
            upperStart = i;
            upperStartPrice = highPrice;
         }
         if (lowPrice > lowerEndPrice)
         {
            lowerEnd = i;
            lowerEndPrice = lowPrice;
         }
      }
   }

   // Draw wedge lines
   if (upperStart >= 0 && lowerEnd >= 0)
   {
      string objName = isRising ? "RisingWedge" : "FallingWedge";
      if (ObjectFind(0, objName) < 0)
      {
         ObjectCreate(0, objName, OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, upperStart), upperStartPrice, iTime(_Symbol, PERIOD_CURRENT, lowerEnd), lowerEndPrice);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clrMaroon);
         ObjectSetInteger(0, objName, OBJPROP_WIDTH, 4);
         
      }
   }
}

//+------------------------------------------------------------------+
//| Function to draw channel patterns                                |
//+------------------------------------------------------------------+
void DrawChannel(int period)
{
   int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
   if (bars <= 0)
      return;

   double highMax = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double lowMin = iLow(_Symbol, PERIOD_CURRENT, 0);

   for (int i = 1; i < bars; i++)
   {
      double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
      double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
      if (highPrice > highMax)
         highMax = highPrice;
      if (lowPrice < lowMin)
         lowMin = lowPrice;
   }

   // Draw channel lines
   if (ObjectFind(0, "UpperChannelLine") < 0)
   {
      ObjectCreate(0, "UpperChannelLine", OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, 0), highMax, iTime(_Symbol, PERIOD_CURRENT, bars - 1), highMax);
      ObjectSetInteger(0, "UpperChannelLine", OBJPROP_COLOR, clrAqua);
   }
   if (ObjectFind(0, "LowerChannelLine") < 0)
   {
      ObjectCreate(0, "LowerChannelLine", OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, 0), lowMin, iTime(_Symbol, PERIOD_CURRENT, bars - 1), lowMin);
      ObjectSetInteger(0, "LowerChannelLine", OBJPROP_COLOR, clrAqua);
   }
}

//+------------------------------------------------------------------+
//| Function to draw triangle patterns                               |
//+------------------------------------------------------------------+
void DrawTriangle(int period, bool isAscending)
{
   int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
   if (bars <= 0)
      return;

   double highPoint = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double lowPoint = iLow(_Symbol, PERIOD_CURRENT, 0);

   for (int i = 1; i < bars; i++)
   {
      double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
      double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
      if (isAscending && highPrice > highPoint)
         highPoint = highPrice;
      if (!isAscending && lowPrice < lowPoint)
         lowPoint = lowPrice;
   }

   // Draw triangle lines
   if (ObjectFind(0, isAscending ? "AscendingTriangle" : "DescendingTriangle") < 0)
   {
      ObjectCreate(0, isAscending ? "AscendingTriangle" : "DescendingTriangle", OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, 0), highPoint, iTime(_Symbol, PERIOD_CURRENT, bars - 1), lowPoint);
      ObjectSetInteger(0, isAscending ? "AscendingTriangle" : "DescendingTriangle", OBJPROP_COLOR, clrPurple);
   }
}

//+------------------------------------------------------------------+
//| Function to draw volume profile                                  |
//+------------------------------------------------------------------+
void DrawVolumeProfile(int period)
{
    int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
    if (bars <= 0)
        return;

    double highLevel = iHigh(_Symbol, PERIOD_CURRENT, 0);
    double lowLevel = iLow(_Symbol, PERIOD_CURRENT, 0);

    for (int i = 1; i < bars; i++)
    {
        double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
        double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
        if (highPrice > highLevel)
            highLevel = highPrice;
        if (lowPrice < lowLevel)
            lowLevel = lowPrice;
    }

    double range = highLevel - lowLevel;
    int numBars = period / 10; // Example of dividing the period into bins
    double binWidth = range / numBars;

    for (int i = 0; i < numBars; i++)
    {
        double binHigh = lowLevel + i * binWidth;
        double binLow = binHigh + binWidth;

        // Calculate volume for this bin (example: using random values)
        double binVolume = MathRand() % 100;

        // Draw a simple rectangle to represent the volume
        string objName = StringFormat("VolumeBin_%d", i);
        datetime startTime = iTime(_Symbol, PERIOD_CURRENT, 0); // Starting time of the profile
        datetime endTime = iTime(_Symbol, PERIOD_CURRENT, bars); // Ending time of the profile

        if (!ObjectCreate(0, objName, OBJ_RECTANGLE, 0, startTime, binHigh, endTime, binLow))
        {
            Print("Failed to create ", objName, ": ", GetLastError());
            continue;
        }
        
        // Set rectangle properties
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrOrange);
        ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
        
        // Set the rectangle height and width based on bin values
        // Set the rectangle height and width based on bin values
        ObjectSetInteger(0, objName, OBJPROP_YSIZE, (int)(binHigh - binLow));
        ObjectSetInteger(0, objName, OBJPROP_XSIZE, (int)(PeriodSeconds() * binVolume));
    }
}
