//+------------------------------------------------------------------+
//|                                               WedgesPattern.mq4  |
//|                                                              N/A |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "N/A"
#property link      "N/A"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Ensure the chart is refreshed and wedges are deleted if they exist
   ObjectDelete("RisingWedge");
   ObjectDelete("FallingWedge");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete the wedges when the expert is removed
   ObjectDelete("RisingWedge");
   ObjectDelete("FallingWedge");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Delete existing wedges
   ObjectDelete("RisingWedge");
   ObjectDelete("FallingWedge");

   // Draw rising wedge
   DrawWedge(200, true);

   // Draw falling wedge
   DrawWedge(200, false);
}

//+------------------------------------------------------------------+
//| Function to draw the wedges                                      |
//+------------------------------------------------------------------+
void DrawWedge(int period, bool isRising)
{
   int bars = MathMin(period, iBars(NULL, 0) - 1);
   if (bars <= 0)
      return;

   int upperStart = 0, upperEnd = 0;
   double upperStartPrice = High[upperStart];
   double upperEndPrice = High[upperEnd];
   int lowerStart = 0, lowerEnd = 0;
   double lowerStartPrice = Low[lowerStart];
   double lowerEndPrice = Low[lowerEnd];

   for (int i = 1; i < bars; i++)
   {
      double high = High[i];
      double low = Low[i];

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

   datetime upperStartTime = Time[upperStart];
   datetime upperEndTime = Time[upperEnd];
   datetime lowerStartTime = Time[lowerStart];
   datetime lowerEndTime = Time[lowerEnd];

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
