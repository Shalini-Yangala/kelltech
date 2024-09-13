
//+------------------------------------------------------------------+
//|                                                      ChannelEA.mq5 |
//|                        Copyright 2024, MetaQuotes Ltd.            |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int ChannelPeriod = 50; // Period to calculate the channel
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

   // Draw the channel for the specified period
   DrawChannel(ChannelPeriod);

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
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Redraw the channel on each tick
   DrawChannel(ChannelPeriod);
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

