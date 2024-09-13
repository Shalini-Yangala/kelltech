//+------------------------------------------------------------------+
//|                                                      Pennant.mq4 |
//|                                                            N/A   |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "N/A"
#property link      "N/A"
#property version   "1.00"
#property strict


input int TrendStartBar = 20;    // Bar to start the trendline
input int TrendEndBar = 10;      // Bar to end the trendline
input int BoxWidth = 7;          // Number of bars for the consolidation box
input double BoxHeight = 50;     // Height of the consolidation box in points

int trendlineHandle;
double trendlineStartPrice, trendlineEndPrice;
datetime trendlineStartTime, trendlineEndTime;
bool boxDrawn = false; // To track if the box is already drawn

int OnInit()
  {
   // Define trendline points
   trendlineStartTime = Time[TrendStartBar];
   trendlineStartPrice = Low[TrendStartBar];
   trendlineEndTime = Time[TrendEndBar];
   trendlineEndPrice = High[TrendEndBar];
   
   // Create trendline
   trendlineHandle = ObjectCreate(0, "Trendline", OBJ_TREND, 0, trendlineStartTime, trendlineStartPrice, trendlineEndTime, trendlineEndPrice);
   ObjectSetInteger(0, "Trendline", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "Trendline", OBJPROP_WIDTH, 2);
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   // Check if there is a breakout
   double currentPrice = Close[0];
   double trendlinePrice = ObjectGetValueByTime(0, "Trendline", Time[0]);
   
   if(currentPrice > trendlinePrice && !boxDrawn)
     {
      DrawConsolidationBox();
     }
  }

void DrawConsolidationBox()
  {
   if(boxDrawn) return;

   // Calculate the consolidation box top and bottom based on the BoxHeight input
   double boxTop = High[0];
   double boxBottom = Low[0];

   // Find the highest high and lowest low within the box width period
   for(int i = 0; i < BoxWidth; i++)
   {
      if(High[i] > boxTop) boxTop = High[i];
      if(Low[i] < boxBottom) boxBottom = Low[i];
   }

   boxTop += BoxHeight * Point;
   boxBottom -= BoxHeight * Point;

   datetime boxStartTime = Time[0];
   datetime boxEndTime = Time[BoxWidth - 1];

   ObjectCreate(0, "ConsolidationBox", OBJ_RECTANGLE, 0, boxStartTime, boxTop, boxEndTime, boxBottom);
   ObjectSetInteger(0, "ConsolidationBox", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "ConsolidationBox", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "ConsolidationBox", OBJPROP_STYLE, STYLE_DASH);
   
   boxDrawn = true;
  }

int OnDeinit(const int reason)
  {
   // Delete objects
   ObjectDelete(0, "Trendline");
   ObjectDelete(0, "ConsolidationBox");
   
   return(0);
  }
