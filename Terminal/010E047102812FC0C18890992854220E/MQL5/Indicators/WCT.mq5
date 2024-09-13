//+------------------------------------------------------------------+
//|                                               IntegratedCode.mq5 |
//|                               Copyright 2024, Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// Input parameters
input int WedgePeriod = 30;    // Period for wedge calculation
input int ChannelPeriod = 50;  // Period for channel calculation
input int TrianglePeriod = 30; // Period for triangle calculation
input bool DetectWedges = true;    // Enable wedge detection
input bool DetectChannels = true;  // Enable channel detection
input bool DetectTriangles = true; // Enable triangle detection
input bool AutoUpdate = true;      // Option to enable or disable auto-update

int bars1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   bars1 = iBars(_Symbol, PERIOD_CURRENT);
   // Ensure all objects are deleted in case they already exist
   DeleteAllObjects();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
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
   if (AutoUpdate)
   {
       DeleteAllObjects();
       if (DetectWedges)
       {
           DrawWedge(WedgePeriod, true);  // Rising wedge
           DrawWedge(WedgePeriod, false); // Falling wedge
       }
       if (DetectChannels)
       {
           DrawChannel(ChannelPeriod);
       }
       if (DetectTriangles)
       {
           DrawTriangle(TrianglePeriod, true);  // Ascending triangle
           DrawTriangle(TrianglePeriod, false); // Descending triangle
       }
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Function to delete all objects                                   |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   ObjectDelete(0,"RisingWedge");
   ObjectDelete(0,"FallingWedge");
   ObjectDelete(0,"UpperChannelLine");
   ObjectDelete(0,"LowerChannelLine");
   ObjectDelete(0,"AscendingTriangle");
   ObjectDelete(0,"DescendingTriangle");
}

//+------------------------------------------------------------------+
//| Function to draw the wedges                                      |
//+------------------------------------------------------------------+
void DrawWedge(int period, bool isRising)
{
   int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
   if (bars <= 0)
      return;

   int upperStart = 0, upperEnd = 0;
   double upperStartPrice = iHigh(_Symbol, PERIOD_CURRENT, upperStart);
   double upperEndPrice = upperStartPrice;
   int lowerStart = 0, lowerEnd = 0;
   double lowerStartPrice = iLow(_Symbol, PERIOD_CURRENT, lowerStart);
   double lowerEndPrice = lowerStartPrice;

   for (int i = 1; i < bars; i++)
   {
      double high = iHigh(_Symbol, PERIOD_CURRENT, i);
      double low = iLow(_Symbol, PERIOD_CURRENT, i);

      if (high > upperStartPrice)
      {
         upperEnd = upperStart;
         upperEndPrice = upperStartPrice;
         upperStart = i;
         upperStartPrice = high;
      }
      else if (high > upperEndPrice)
      {
         upperEnd = i;
         upperEndPrice = high;
      }
      if (low < lowerStartPrice)
      {
         lowerEnd = lowerStart;
         lowerEndPrice = lowerStartPrice;
         lowerStart = i;
         lowerStartPrice = low;
      }
      else if (low < lowerEndPrice)
      {
         lowerEnd = i;
         lowerEndPrice = low;
      }
   }

   datetime upperStartTime = iTime(_Symbol, PERIOD_CURRENT, upperStart);
   datetime upperEndTime = iTime(_Symbol, PERIOD_CURRENT, upperEnd);
   datetime lowerStartTime = iTime(_Symbol, PERIOD_CURRENT, lowerStart);
   datetime lowerEndTime = iTime(_Symbol, PERIOD_CURRENT, lowerEnd);
   string wedgeName = isRising ? "RisingWedge" : "FallingWedge";

   // Draw wedge
   if (!ObjectCreate(0, wedgeName, OBJ_TRIANGLE, 0, 
                     upperStartTime, upperStartPrice, 
                     lowerStartTime, lowerStartPrice, 
                     lowerEndTime, lowerEndPrice))
   {
      Print("Failed to create ", wedgeName, ": ", GetLastError());
      return;
   }
   ObjectSetInteger(0, wedgeName, OBJPROP_COLOR, isRising ? clrBlue : clrRed);
   ObjectSetInteger(0, wedgeName, OBJPROP_WIDTH, 2);
}

//+------------------------------------------------------------------+
//| Function to draw the channel                                     |
//+------------------------------------------------------------------+
void DrawChannel(int period)
{
   int bars = MathMin(period, bars1 - 1);
   if (bars <= 0) return;

   double highestHigh = -DBL_MAX;
   double lowestLow = DBL_MAX;
   datetime startTime = iTime(_Symbol, PERIOD_CURRENT, bars);
   datetime endTime = iTime(_Symbol, PERIOD_CURRENT, 0);

   for (int i = 0; i <= bars; i++)
   {
      double high = iHigh(_Symbol, PERIOD_CURRENT, i);
      double low = iLow(_Symbol, PERIOD_CURRENT, i);
      if (high > highestHigh) highestHigh = high;
      if (low < lowestLow) lowestLow = low;
   }

   // Draw upper channel line
   if (ObjectFind(0, "UpperChannelLine") == -1)
   {
      if (!ObjectCreate(0, "UpperChannelLine", OBJ_TREND, 0, startTime, highestHigh, endTime, highestHigh))
      {
         Print("Failed to create UpperChannelLine: ", GetLastError());
      }
   }
   else
   {
      ObjectMove(0, "UpperChannelLine", 0, startTime, highestHigh);
      ObjectMove(0, "UpperChannelLine", 1, endTime, highestHigh);
   }
   ObjectSetInteger(0, "UpperChannelLine", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "UpperChannelLine", OBJPROP_WIDTH, 2);

   // Draw lower channel line
   if (ObjectFind(0, "LowerChannelLine") == -1)
   {
      if (!ObjectCreate(0, "LowerChannelLine", OBJ_TREND, 0, startTime, lowestLow, endTime, lowestLow))
      {
         Print("Failed to create LowerChannelLine: ", GetLastError());
      }
   }
   else
   {
      ObjectMove(0, "LowerChannelLine", 0, startTime, lowestLow);
      ObjectMove(0, "LowerChannelLine", 1, endTime, lowestLow);
   }
   ObjectSetInteger(0, "LowerChannelLine", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "LowerChannelLine", OBJPROP_WIDTH, 2);
}

//+------------------------------------------------------------------+
//| Function to draw the triangles                                   |
//+------------------------------------------------------------------+
void DrawTriangle(int period, bool isAscending)
{
   int bars = MathMin(period, Bars(_Symbol, PERIOD_CURRENT) - 1);
   if (bars <= 0) return;

   int start = 0, end1 = 0, end2 = 0;
   double startPrice = isAscending ? iLow(_Symbol, PERIOD_CURRENT, start) : iHigh(_Symbol, PERIOD_CURRENT, start);
   double endPrice1 = isAscending ? iHigh(_Symbol, PERIOD_CURRENT, end1) : iLow(_Symbol, PERIOD_CURRENT, end1);
   double endPrice2 = isAscending ? iHigh(_Symbol, PERIOD_CURRENT, end2) : iLow(_Symbol, PERIOD_CURRENT, end2);

   for (int i = 1; i < bars; i++)
   {
      double high = iHigh(_Symbol, PERIOD_CURRENT, i);
      double low = iLow(_Symbol, PERIOD_CURRENT, i);

      if (isAscending)
      {
         if (high > startPrice)
         {
            end2 = end1;
            endPrice2 = endPrice1;
            end1 = start;
            endPrice1 = startPrice;
            start = i;
            startPrice = high;
         }
         else if (high > endPrice1)
         {
            end2 = end1;
            endPrice2 = endPrice1;
            end1 = i;
            endPrice1 = high;
         }
      }
      else // Descending Triangle
      {
         if (low < startPrice)
         {
            end2 = end1;
            endPrice2 = endPrice1;
            end1 = start;
            endPrice1 = startPrice;
            start = i;
            startPrice = low;
         }
         else if (low < endPrice1)
         {
            end2 = end1;
            endPrice2 = endPrice1;
            end1 = i;
            endPrice1 = low;
         }
      }
   }

   string triangleName = isAscending ? "AscendingTriangle" : "DescendingTriangle";
   datetime startTime = iTime(_Symbol, PERIOD_CURRENT, start);
   datetime end1Time = iTime(_Symbol, PERIOD_CURRENT, end1);
   datetime end2Time = iTime(_Symbol, PERIOD_CURRENT, end2);

   // Draw triangle
   if (!ObjectCreate(0, triangleName, OBJ_TRIANGLE, 0, 
                     startTime, startPrice, 
                     end1Time, endPrice1, 
                     end2Time, endPrice2))
   {
      Print("Failed to create ", triangleName, ": ", GetLastError());
      return;
   }
   ObjectSetInteger(0, triangleName, OBJPROP_COLOR, isAscending ? clrGreen : clrRed);
   ObjectSetInteger(0, triangleName, OBJPROP_WIDTH, 2);
}
