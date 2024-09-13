//+------------------------------------------------------------------+
//|                                                   WedgeEA.mq5 |
//|                        Copyright 2024, MetaQuotes Ltd.            |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int WedgePeriod = 50; // Period to calculate the wedge
int bars1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
bars1=iBars(NULL,0);
   // Draw a rising and falling wedge for the specified period
   DrawWedge(WedgePeriod, true);
   DrawWedge(WedgePeriod, false);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Remove graphical objects
   ObjectDelete(0, "UpperWedgeLine");
   ObjectDelete(0, "LowerWedgeLine");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Redraw the wedges on each tick
   DrawWedge(WedgePeriod, true);
   DrawWedge(WedgePeriod, false);
}

//+------------------------------------------------------------------+
//| Function to draw the wedges                                      |
//+------------------------------------------------------------------+
void DrawWedge(int period, bool isRising)
{
   int bars = MathMin(period, bars1 - 1);
   if (bars <= 0) return;

   int upperStart = 0, upperEnd = 0;
   double upperStartPrice = iHigh(_Symbol, 0, upperStart);
   double upperEndPrice = iHigh(_Symbol, 0, upperEnd);

   int lowerStart = 0, lowerEnd = 0;
   double lowerStartPrice = iLow(_Symbol, 0, lowerStart);
   double lowerEndPrice = iLow(_Symbol, 0, lowerEnd);

   for (int i = 1; i < bars; i++)
   {
      double high = iHigh(_Symbol, 0, i);
      double low = iLow(_Symbol, 0, i);

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

   datetime upperStartTime = iTime(_Symbol, 0, upperStart);
   datetime upperEndTime = iTime(_Symbol, 0, upperEnd);
   datetime lowerStartTime = iTime(_Symbol, 0, lowerStart);
   datetime lowerEndTime = iTime(_Symbol, 0, lowerEnd);

   string upperWedgeName = isRising ? "UpperRisingWedgeLine" : "UpperFallingWedgeLine";
   string lowerWedgeName = isRising ? "LowerRisingWedgeLine" : "LowerFallingWedgeLine";

   // Draw upper wedge line
   if (ObjectFind(0, upperWedgeName) == INVALID_HANDLE)
   {
      if (!ObjectCreate(0, upperWedgeName, OBJ_TREND, 0, upperStartTime, upperStartPrice, upperEndTime, upperEndPrice))
      {
         Print("Failed to create ", upperWedgeName, ": ", GetLastError());
      }
   }
   else
   {
      ObjectMove(0, upperWedgeName, 0, upperStartTime, upperStartPrice);
      ObjectMove(0, upperWedgeName, 1, upperEndTime, upperEndPrice);
   }
   ObjectSetInteger(0, upperWedgeName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, upperWedgeName, OBJPROP_WIDTH, 2);

   // Draw lower wedge line
   if (ObjectFind(0, lowerWedgeName) == INVALID_HANDLE)
   {
      if (!ObjectCreate(0, lowerWedgeName, OBJ_TREND, 0, lowerStartTime, lowerStartPrice, lowerEndTime, lowerEndPrice))
      {
         Print("Failed to create ", lowerWedgeName, ": ", GetLastError());
      }
   }
   else
   {
      ObjectMove(0, lowerWedgeName, 0, lowerStartTime, lowerStartPrice);
      ObjectMove(0, lowerWedgeName, 1, lowerEndTime, lowerEndPrice);
   }
   ObjectSetInteger(0, lowerWedgeName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, lowerWedgeName, OBJPROP_WIDTH, 2);
}

