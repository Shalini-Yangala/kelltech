//+------------------------------------------------------------------+
//|                                             TrianglePattern.mq4  |
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
   // Ensure the chart is refreshed and triangles are deleted if they exist
   ObjectDelete("DescendingTriangle");
   ObjectDelete("AscendingTriangle");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete the triangle objects when the expert is removed
   ObjectDelete("DescendingTriangle");
   ObjectDelete("AscendingTriangle");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Find the highest and lowest points in the last 30 candles
   int highestCandle = iHighest(_Symbol, _Period, MODE_HIGH, 30, 0);
   int lowestCandle = iLowest(_Symbol, _Period, MODE_LOW, 30, 0);

   // Delete existing triangles
   ObjectDelete("DescendingTriangle");
   ObjectDelete("AscendingTriangle");

   // Draw descending triangle
   DrawTriangle(highestCandle, lowestCandle, false);

   // Draw ascending triangle
   DrawTriangle(highestCandle, lowestCandle, true);
}

//+------------------------------------------------------------------+
//| Function to draw the triangles                                   |
//+------------------------------------------------------------------+
void DrawTriangle(int highestCandle, int lowestCandle, bool isAscending)
{
   int bars = MathMin(30, iBars(NULL, 0) - 1);
   if (bars <= 0)
      return;

   int start = 0, end1 = 0, end2 = 0;
   double startPrice = isAscending ? Low[start] : High[start];
   double endPrice1 = isAscending ? High[end1] : Low[end1];
   double endPrice2 = isAscending ? High[end2] : Low[end2];

   for (int i = 1; i < bars; i++)
   {
      double high = High[i];
      double low = Low[i];

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

   datetime startTime = Time[start];
   datetime endTime1 = Time[end1];
   datetime endTime2 = Time[end2];
   double price1 = isAscending ? High[end1] : Low[end1];
   double price2 = isAscending ? High[end2] : Low[end2];

   string triangleName = isAscending ? "AscendingTriangle" : "DescendingTriangle";

   // Draw triangle
   if (!ObjectCreate(0, triangleName, OBJ_TRIANGLE, 0,
                    startTime, startPrice,
                    endTime1, price1,
                    endTime2, price2))
   {
      Print("Failed to create ", triangleName, ": ", GetLastError());
      return;
   }

   ObjectSetInteger(0, triangleName, OBJPROP_COLOR, isAscending ? clrBlue : clrRed);
   ObjectSetInteger(0, triangleName, OBJPROP_WIDTH, 2);
}



