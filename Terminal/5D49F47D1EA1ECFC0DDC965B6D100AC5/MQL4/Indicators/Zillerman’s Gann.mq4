/*

//+------------------------------------------------------------------+
//|                                         Zillerman's Gann.mq4     |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "https://www.fpmarkets.com"
#property version   "1.00"
#property indicator_chart_window

// Input parameters
input double Level1 = 0.25;    // First level percentage
input double Level2 = 0.382;   // Second level percentage
input double Level3 = 0.5;     // Third level percentage
input double Level4 = 0.618;   // Fourth level percentage
input double Level5 = 0.75;    // Fifth level percentage
input bool showBox = true;     // Show Gann Box
input bool showLabel = true;   // Show Labels

// Colors for levels
color levelColors[] = {clrRed, clrGreen, clrBlue, clrOrange, clrViolet, clrYellow};

int OnInit()
{
   // Initialize Gann Box if showBox is enabled
   if (showBox) {
      // We need to pass data arrays, so we use the current chart data
      int rates_total = Bars;
      datetime time[];
      double high[], low[];

      ArraySetAsSeries(time, true);
      ArraySetAsSeries(high, true);
      ArraySetAsSeries(low, true);

      CopyTime(NULL, 0, 0, rates_total, time);
      CopyHigh(NULL, 0, 0, rates_total, high);
      CopyLow(NULL, 0, 0, rates_total, low);

      DrawGannBox(rates_total, high, low, time);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // Delete objects upon deinitialization
   for (int i = 0; i <= 6; i++) {
      ObjectDelete(0, "GannBox" + IntegerToString(i));
      ObjectDelete(0, "GannLabel" + IntegerToString(i));
   }
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime& time[], const double& open[],
                const double& high[], const double& low[],
                const double& close[], const long& tick_volume[],
                const long& volume[], const int& spread[])
{
   // Update Gann Box on new calculation
   if (showBox) DrawGannBox(rates_total, high, low, time);
   return(rates_total);
}

void DrawGannBox(int rates_total, const double& high[], const double& low[], const datetime& time[])
{
   // Find the highest high and lowest low
   int highestHighIndex = iHighest(NULL, 0, MODE_HIGH, rates_total, 0);
   int lowestLowIndex = iLowest(NULL, 0, MODE_LOW, rates_total, 0);
   double highestHigh = high[highestHighIndex];
   double lowestLow = low[lowestLowIndex];
   int leftIndex = lowestLowIndex;
   int rightIndex = highestHighIndex;
   
   // Ensure leftIndex is less than rightIndex
   if (leftIndex > rightIndex) {
      int temp = leftIndex;
      leftIndex = rightIndex;
      rightIndex = temp;
   }
   
   // Define the Gann levels
   double levels[7];
   levels[0] = 0;
   levels[1] = Level1;
   levels[2] = Level2;
   levels[3] = Level3;
   levels[4] = Level4;
   levels[5] = Level5;
   levels[6] = 1;
   
   for (int i = 0; i < 6; i++) {
      // Calculate box coordinates
      double topLevel = highestHigh - (highestHigh - lowestLow) * levels[i];
      double bottomLevel = highestHigh - (highestHigh - lowestLow) * levels[i + 1];
      datetime leftTime = time[leftIndex];
      datetime rightTime = time[rightIndex];
      
      // Draw Gann Box
      string boxName = "GannBox" + IntegerToString(i);
      if (!ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, leftTime, topLevel, rightTime, bottomLevel))
         Print("Error creating object: " + boxName);
      ObjectSetInteger(0, boxName, OBJPROP_COLOR, levelColors[i]);
      ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);
      
      // Draw Labels
      if (showLabel) {
         string labelName = "GannLabel" + IntegerToString(i);
         if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, rightTime, bottomLevel))
            Print("Error creating object: " + labelName);
         ObjectSetString(0, labelName, OBJPROP_TEXT, DoubleToString(levels[i + 1] * 100, 1) + "%");
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      }
   }
}


*/

//=====================================================================================================================


/*

//+------------------------------------------------------------------+
//|                                         Zillerman's Gann.mq4     |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "https://www.fpmarkets.com"
#property version   "1.00"
#property indicator_chart_window

// Input parameters
input double Level1 = 0.25;    // First level percentage
input double Level2 = 0.382;   // Second level percentage
input double Level3 = 0.5;     // Third level percentage
input double Level4 = 0.618;   // Fourth level percentage
input double Level5 = 0.75;    // Fifth level percentage
input bool showBox = true;     // Show Gann Box
input bool showLabel = true;   // Show Labels

// Colors for levels
color levelColors[] = {clrRed, clrGreen, clrBlue, clrOrange, clrViolet, clrYellow};

int OnInit()
{
   // Initialize Gann Box if showBox is enabled
   if (showBox) {
      DrawGannBox();
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // Delete objects upon deinitialization
   for (int i = 0; i <= 6; i++) {
      ObjectDelete(0, "GannBox" + IntegerToString(i));
      ObjectDelete(0, "GannLabel" + IntegerToString(i));
   }
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime& time[], const double& open[],
                const double& high[], const double& low[],
                const double& close[], const long& tick_volume[],
                const long& volume[], const int& spread[])
{
   return(rates_total);
}

void DrawGannBox()
{
   // Ensure we have at least 100 candles to work with
   int rates_total = iBars(NULL, 0);
   if (rates_total <50) return;

   // Get current chart data for the first 100 candles
   datetime time[50];
   double high[50], low[50];

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   CopyTime(NULL, 0, 0, 50, time);
   CopyHigh(NULL, 0, 0, 50, high);
   CopyLow(NULL, 0, 0, 50, low);

   // Find the highest high and lowest low within the first 100 candles
   int highestHighIndex = iHighest(NULL, 0, MODE_HIGH, 50, 0);
   int lowestLowIndex = iLowest(NULL, 0, MODE_LOW, 50, 0);
   double highestHigh = high[highestHighIndex];
   double lowestLow = low[lowestLowIndex];
   int leftIndex = lowestLowIndex;
   int rightIndex = highestHighIndex;

   // Ensure leftIndex is less than rightIndex
   if (leftIndex > rightIndex) {
      int temp = leftIndex;
      leftIndex = rightIndex;
      rightIndex = temp;
   }

   // Define the Gann levels
   double levels[7];
   levels[0] = 0;
   levels[1] = Level1;
   levels[2] = Level2;
   levels[3] = Level3;
   levels[4] = Level4;
   levels[5] = Level5;
   levels[6] = 1;

   for (int i = 0; i < 6; i++) {
      // Calculate box coordinates
      double topLevel = highestHigh - (highestHigh - lowestLow) * levels[i];
      double bottomLevel = highestHigh - (highestHigh - lowestLow) * levels[i + 1];
      datetime leftTime = time[leftIndex];
      datetime rightTime = time[rightIndex];

      // Draw Gann Box
      string boxName = "GannBox" + IntegerToString(i);
      if (!ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, leftTime, topLevel, rightTime, bottomLevel))
         Print("Error creating object: " + boxName);
      ObjectSetInteger(0, boxName, OBJPROP_COLOR, levelColors[i]);
      ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);

      // Draw Labels
      if (showLabel) {
         string labelName = "GannLabel" + IntegerToString(i);
         if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, rightTime, bottomLevel))
            Print("Error creating object: " + labelName);
         ObjectSetString(0, labelName, OBJPROP_TEXT, DoubleToString(levels[i + 1] * 100, 1) + "%");
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      }
   }
}
*/



//=======================================================================================






//+------------------------------------------------------------------+
//|                                         Zillerman's Gann.mq4     |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "https://www.fpmarkets.com"
#property version   "1.00"
#property indicator_chart_window

// Input parameters
input double Level1 = 0.25;    // First level percentage
input double Level2 = 0.382;   // Second level percentage
input double Level3 = 0.5;     // Third level percentage
input double Level4 = 0.618;   // Fourth level percentage
input double Level5 = 0.75;    // Fifth level percentage
input bool showBox = true;     // Show Gann Box
input bool showLabel = true;   // Show Labels

// Colors for levels
//color levelColors[] = {clrRed, clrGreen, clrBlue, clrOrange, clrViolet, clrYellow};


color levelColors[] = {clrLightCoral, clrLightGreen, clrLightBlue, clrLightSalmon, clrLightPink, clrLightYellow};


int OnInit()
{
   // Initialize Gann Box if showBox is enabled
   if (showBox) {
      DrawGannBox();
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // Delete objects upon deinitialization
   for (int i = 0; i <= 6; i++) {
      ObjectDelete(0, "GannBox" + IntegerToString(i));
      ObjectDelete(0, "GannLabel" + IntegerToString(i));
   }
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime& time[], const double& open[],
                const double& high[], const double& low[],
                const double& close[], const long& tick_volume[],
                const long& volume[], const int& spread[])
{
   if (showBox) DrawGannBox();
   return(rates_total);
}

void DrawGannBox()
{
   // Ensure we have at least 50 candles to work with
   int rates_total = iBars(NULL, 0);
   if (rates_total < 50) return;

   // Get current chart data for the last 50 candles
   datetime time[50];
   double high[50], low[50];

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   CopyTime(NULL, 0, 0, 50, time);
   CopyHigh(NULL, 0, 0, 50, high);
   CopyLow(NULL, 0, 0, 50, low);

   // Find the highest high and lowest low within the last 50 candles
   int highestHighIndex = iHighest(NULL, 0, MODE_HIGH, 50, 0);
   int lowestLowIndex = iLowest(NULL, 0, MODE_LOW, 50, 0);
   double highestHigh = high[highestHighIndex];
   double lowestLow = low[lowestLowIndex];
   int leftIndex = lowestLowIndex;
   int rightIndex = highestHighIndex;

   // Ensure leftIndex is less than rightIndex
   if (leftIndex > rightIndex) {
      int temp = leftIndex;
      leftIndex = rightIndex;
      rightIndex = temp;
   }

   // Define the Gann levels
   double levels[7];
   levels[0] = 0;
   levels[1] = Level1;
   levels[2] = Level2;
   levels[3] = Level3;
   levels[4] = Level4;
   levels[5] = Level5;
   levels[6] = 1;

   for (int i = 0; i < 6; i++) {
      // Calculate box coordinates
      double topLevel = highestHigh - (highestHigh - lowestLow) * levels[i];
      double bottomLevel = highestHigh - (highestHigh - lowestLow) * levels[i + 1];
      datetime leftTime = time[leftIndex];
      datetime rightTime = time[rightIndex];

      // Draw Gann Box
      string boxName = "GannBox" + IntegerToString(i);
      if (!ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, Time[0], topLevel, rightTime, bottomLevel))
         Print("Error creating object: " + boxName);
      ObjectSetInteger(0, boxName, OBJPROP_COLOR, levelColors[i]);
      ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);

      // Draw Labels
      if (showLabel) {
         string labelName = "GannLabel" + IntegerToString(i);
         datetime labelTime = rightTime + (rightTime - leftTime) / 30;  // Move the label slightly to the left
         double lablePrice = topLevel +(topLevel-bottomLevel)/30;
         if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, labelTime, lablePrice))
            Print("Error creating object: " + labelName);
         ObjectSetString(0, labelName, OBJPROP_TEXT, DoubleToString(levels[i + 1], 2));
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      }
   }
}












//=======================================================

/*
//+------------------------------------------------------------------+
//|                                         Zillerman's Gann.mq4     |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "https://www.fpmarkets.com"
#property version   "1.00"
#property indicator_chart_window

// Input parameters
input double Level1 = 0.25;    // First level percentage
input double Level2 = 0.382;   // Second level percentage
input double Level3 = 0.5;     // Third level percentage
input double Level4 = 0.618;   // Fourth level percentage
input double Level5 = 0.75;    // Fifth level percentage
input bool showBox = true;     // Show Gann Box
input bool showFan = true;     // Show Gann Fan
input bool showLabel = true;   // Show Labels

// Colors for levels
color levelColors[] = {clrLightCoral, clrLightGreen, clrLightBlue, clrLightSalmon, clrLightPink, clrLightYellow};
color fanColor = clrRoyalBlue; // Color for the Gann Fan lines

int OnInit()
{
   // Initialize Gann Box and Fan if showBox and showFan are enabled
   if (showBox || showFan) {
      DrawGannBoxAndFan();
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // Delete objects upon deinitialization
   for (int i = 0; i <= 6; i++) {
      ObjectDelete(0, "GannBox" + IntegerToString(i));
      ObjectDelete(0, "GannLabel" + IntegerToString(i));
      ObjectDelete(0, "GannFan" + IntegerToString(i));
   }
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime& time[], const double& open[],
                const double& high[], const double& low[],
                const double& close[], const long& tick_volume[],
                const long& volume[], const int& spread[])
{
   if (showBox || showFan) DrawGannBoxAndFan();
   return(rates_total);
}

void DrawGannBoxAndFan()
{
   // Ensure we have at least 50 candles to work with
   int rates_total = iBars(NULL, 0);
   if (rates_total < 50) return;

   // Get current chart data for the last 50 candles
   datetime time[50];
   double high[50], low[50];

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   CopyTime(NULL, 0, 0, 50, time);
   CopyHigh(NULL, 0, 0, 50, high);
   CopyLow(NULL, 0, 0, 50, low);

   // Find the highest high and lowest low within the last 50 candles
   int highestHighIndex = iHighest(NULL, 0, MODE_HIGH, 50, 0);
   int lowestLowIndex = iLowest(NULL, 0, MODE_LOW, 50, 0);
   double highestHigh = high[highestHighIndex];
   double lowestLow = low[lowestLowIndex];
   int leftIndex = lowestLowIndex;
   int rightIndex = highestHighIndex;

   // Ensure leftIndex is less than rightIndex
   if (leftIndex > rightIndex) {
      int temp = leftIndex;
      leftIndex = rightIndex;
      rightIndex = temp;
   }

   // Define the Gann levels
   double levels[7];
   levels[0] = 0;
   levels[1] = Level1;
   levels[2] = Level2;
   levels[3] = Level3;
   levels[4] = Level4;
   levels[5] = Level5;
   levels[6] = 1;

   for (int i = 0; i < 6; i++) {
      // Calculate box coordinates
      double topLevel = highestHigh - (highestHigh - lowestLow) * levels[i];
      double bottomLevel = highestHigh - (highestHigh - lowestLow) * levels[i + 1];
      datetime leftTime = time[leftIndex];
      datetime rightTime = time[rightIndex];

      // Draw Gann Box
      string boxName = "GannBox" + IntegerToString(i);
      if (!ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, Time[0], topLevel, rightTime, bottomLevel))
         Print("Error creating object: " + boxName);
      ObjectSetInteger(0, boxName, OBJPROP_COLOR, levelColors[i]);
      ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);
      //ObjectSetInteger(0, boxName,OBJPROP_BACK,true);

      // Draw Labels
      if (showLabel) {
         string labelName = "GannLabel" + IntegerToString(i);
         if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, rightTime, bottomLevel))
            Print("Error creating object: " + labelName);
         ObjectSetString(0, labelName, OBJPROP_TEXT, DoubleToString(levels[i + 1] * 100, 1) + "%");
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      }
   }

   // Draw Gann Fan if enabled
   if (showFan) {
      double fanAngles[] = {1.0 / 8.0, 1.0 / 4.0, 1.0 / 3.0, 1.0 / 2.0, 1.0, 2.0, 3.0, 4.0, 8.0};
      for (int j = 0; j < ArraySize(fanAngles); j++) {
         double angle = fanAngles[j];
         string fanName = "GannFan" + IntegerToString(i);

         if (!ObjectCreate(0, fanName, OBJ_TREND, 0, time[leftIndex], lowestLow, time[leftIndex] + PeriodSeconds() * 50, lowestLow + (highestHigh - lowestLow) * angle))
            Print("Error creating object: " + fanName);

         ObjectSetInteger(0, fanName, OBJPROP_COLOR, fanColor);
         ObjectSetInteger(0, fanName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, fanName, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, fanName,OBJPROP_BACK,false);
      }
   }
}
*/


//========================================================================



