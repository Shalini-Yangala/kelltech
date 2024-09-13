
//+------------------------------------------------------------------+
//|                                               CombinedEA.mq5 |
//|                        Copyright 2024, MetaQuotes Ltd.            |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int ChannelPeriod = 50; // Period to calculate the channel
input int WedgePeriod = 50;   // Period to calculate the wedge
int bars1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   bars1 = iBars(NULL, 0);
   
   // Ensure the objects are deleted in case they already exist
   ObjectDelete(0, "UpperChannelLine");
   ObjectDelete(0, "LowerChannelLine");
   ObjectDelete(0, "UpperRisingWedgeLine");
   ObjectDelete(0, "LowerRisingWedgeLine");
   ObjectDelete(0, "UpperFallingWedgeLine");
   ObjectDelete(0, "LowerFallingWedgeLine");

   // Draw the channel and wedges for the specified periods
   DrawChannel(ChannelPeriod);
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
   ObjectDelete(0, "UpperChannelLine");
   ObjectDelete(0, "LowerChannelLine");
   ObjectDelete(0, "UpperRisingWedgeLine");
   ObjectDelete(0, "LowerRisingWedgeLine");
   ObjectDelete(0, "UpperFallingWedgeLine");
   ObjectDelete(0, "LowerFallingWedgeLine");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Redraw the channel and wedges on each tick
   DrawChannel(ChannelPeriod);
   DrawWedge(WedgePeriod, true);
   DrawWedge(WedgePeriod, false);
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
   datetime startTime = iTime(_Symbol, 0, bars);
   datetime endTime = iTime(_Symbol, 0, 0);

   for (int i = 0; i <= bars; i++)
   {
      double high = iHigh(_Symbol, 0, i);
      double low = iLow(_Symbol, 0, i);
      if (high > highestHigh) highestHigh = high;
      if (low < lowestLow) lowestLow = low;
   }
   
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   Print("high----",highestHigh);
   Print("low----",lowestLow);
   Print("ask----",askPrice);
   Print("bid----",bidPrice);

   // Draw upper channel line
   if (ObjectFind(0, "UpperChannelLine") == INVALID_HANDLE)
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
   if (ObjectFind(0, "LowerChannelLine") == INVALID_HANDLE)
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
