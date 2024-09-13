
/*

//+------------------------------------------------------------------+
//|                                                   TW pattern.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Ensure the chart is refreshed and the patterns are deleted if they exist
    ObjectDelete("DescendingTriangle");
    ObjectDelete("AscendingTriangle");
    ObjectDelete("UpperWedgeTriangle");
    ObjectDelete("LowerWedgeTriangle");

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Delete the pattern objects when the expert is removed
    ObjectDelete("DescendingTriangle");
    ObjectDelete("AscendingTriangle");
    ObjectDelete("UpperWedgeTriangle");
    ObjectDelete("LowerWedgeTriangle");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Find the highest and lowest points in the last 30 candles
    int highestCandle = iHighest(_Symbol, _Period, MODE_HIGH, 30, 0);
    int lowestCandle = iLowest(_Symbol, _Period, MODE_LOW, 30, 0);

    // Delete existing pattern objects
    ObjectDelete("DescendingTriangle");
    ObjectDelete("AscendingTriangle");
    ObjectDelete("UpperWedgeTriangle");
    ObjectDelete("LowerWedgeTriangle");

    // Create the descending triangle object
    if(ObjectCreate(0, "DescendingTriangle", OBJ_TRIANGLE, 0,
                    Time[30], Close[30],
                    Time[lowestCandle], Low[lowestCandle],
                    Time[highestCandle], High[highestCandle]))
    {
        // Set the descending triangle properties
        ObjectSetInteger(0, "DescendingTriangle", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "DescendingTriangle", OBJPROP_WIDTH, 2);
    }
    else
    {
        Print("Failed to create descending triangle");
    }

    // Create the ascending triangle object
    if(ObjectCreate(0, "AscendingTriangle", OBJ_TRIANGLE, 0,
                    Time[30], Close[30],
                    Time[highestCandle], High[highestCandle],
                    Time[lowestCandle], Low[lowestCandle]))
    {
        // Set the ascending triangle properties
        ObjectSetInteger(0, "AscendingTriangle", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(0, "AscendingTriangle", OBJPROP_WIDTH, 2);
    }
    else
    {
        Print("Failed to create ascending triangle");
    }

    // Draw the upper wedge triangle (connecting higher highs)
    if(ObjectCreate(0, "UpperWedgeTriangle", OBJ_TRIANGLE, 0,
                   Time[highestCandle], High[highestCandle],
                   Time[0], High[0],
                   Time[30], Close[30]))
    {
        ObjectSetInteger(0, "UpperWedgeTriangle", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, "UpperWedgeTriangle", OBJPROP_WIDTH, 2);
    }
    else
    {
        Print("Failed to create upper wedge triangle");
    }

    // Draw the lower wedge triangle (connecting lower lows)
    if(ObjectCreate(0, "LowerWedgeTriangle", OBJ_TRIANGLE, 0,
                   Time[lowestCandle], Low[lowestCandle],
                   Time[0], Low[0],
                   Time[30], Close[30]))
    {
        ObjectSetInteger(0, "LowerWedgeTriangle", OBJPROP_COLOR, clrOrange);
        ObjectSetInteger(0, "LowerWedgeTriangle", OBJPROP_WIDTH, 2);
    }
    else
    {
        Print("Failed to create lower wedge triangle");
    }
}
//+------------------------------------------------------------------+
*/
//=========================================================================================================================


//+------------------------------------------------------------------+
//|                                        WedgePatternEA.mq4        |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Delete existing wedge patterns on initialization
    ObjectDelete("RisingWedge");
    ObjectDelete("FallingWedge");

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Delete the wedge patterns when the expert is removed
    ObjectDelete("RisingWedge");
    ObjectDelete("FallingWedge");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Define the period range for the wedge patterns
    int period = 30; // You can adjust this to any value between 10 and 50

    // Find the highest and lowest points in the specified period
    int highestCandle = iHighest(_Symbol, _Period, MODE_HIGH, period, 0);
    int lowestCandle = iLowest(_Symbol, _Period, MODE_LOW, period, 0);

    // Delete existing wedge pattern objects
    ObjectDelete("RisingWedge");
    ObjectDelete("FallingWedge");

    // Draw the rising wedge pattern
    DrawRisingWedgePattern(highestCandle, lowestCandle, period);
    // Draw the falling wedge pattern
    DrawFallingWedgePattern(highestCandle, lowestCandle, period);
}
//+------------------------------------------------------------------+
//| Function to draw rising wedge pattern                            |
//+------------------------------------------------------------------+
void DrawRisingWedgePattern(int highestCandle, int lowestCandle, int period)
{
    double upperTrendLineStart, upperTrendLineEnd, lowerTrendLineStart, lowerTrendLineEnd;
    datetime upperTrendLineStartTime, upperTrendLineEndTime, lowerTrendLineStartTime, lowerTrendLineEndTime;

    // Rising wedge: upper trend line from highest high to a lower high
    upperTrendLineStart = High[highestCandle];
    upperTrendLineEnd = High[highestCandle + period / 2]; // An arbitrary point for simplicity
    upperTrendLineStartTime = Time[highestCandle];
    upperTrendLineEndTime = Time[highestCandle + period / 2];

    // Rising wedge: lower trend line from a lower low to the lowest low
    lowerTrendLineStart = Low[highestCandle + period / 2]; // An arbitrary point for simplicity
    lowerTrendLineEnd = Low[lowestCandle];
    lowerTrendLineStartTime = Time[highestCandle + period / 2];
    lowerTrendLineEndTime = Time[lowestCandle];

    // Create the upper trend line
    ObjectCreate(0, "RisingWedge", OBJ_TREND, 0, upperTrendLineStartTime, upperTrendLineStart, upperTrendLineEndTime, upperTrendLineEnd);
    ObjectSetInteger(0, "RisingWedge", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, "RisingWedge", OBJPROP_WIDTH, 2);

    // Create the lower trend line
    ObjectCreate(0, "RisingWedgeLower", OBJ_TREND, 0, lowerTrendLineStartTime, lowerTrendLineStart, lowerTrendLineEndTime, lowerTrendLineEnd);
    ObjectSetInteger(0, "RisingWedgeLower", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, "RisingWedgeLower", OBJPROP_WIDTH, 2);
}
//+------------------------------------------------------------------+
//| Function to draw falling wedge pattern                           |
//+------------------------------------------------------------------+
void DrawFallingWedgePattern(int highestCandle, int lowestCandle, int period)
{
    double upperTrendLineStart, upperTrendLineEnd, lowerTrendLineStart, lowerTrendLineEnd;
    datetime upperTrendLineStartTime, upperTrendLineEndTime, lowerTrendLineStartTime, lowerTrendLineEndTime;

    // Falling wedge: upper trend line from highest high to a higher high
    upperTrendLineStart = High[highestCandle];
    upperTrendLineEnd = High[lowestCandle - period / 2]; // An arbitrary point for simplicity
    upperTrendLineStartTime = Time[highestCandle];
    upperTrendLineEndTime = Time[lowestCandle - period / 2];

    // Falling wedge: lower trend line from a higher low to the lowest low
    lowerTrendLineStart = Low[lowestCandle - period / 2]; // An arbitrary point for simplicity
    lowerTrendLineEnd = Low[lowestCandle];
    lowerTrendLineStartTime = Time[lowestCandle - period / 2];
    lowerTrendLineEndTime = Time[lowestCandle];

    // Create the upper trend line
    ObjectCreate(0, "FallingWedge", OBJ_TREND, 0, upperTrendLineStartTime, upperTrendLineStart, upperTrendLineEndTime, upperTrendLineEnd);
    ObjectSetInteger(0, "FallingWedge", OBJPROP_COLOR, clrBlue);
    ObjectSetInteger(0, "FallingWedge", OBJPROP_WIDTH, 2);

    // Create the lower trend line
    ObjectCreate(0, "FallingWedgeLower", OBJ_TREND, 0, lowerTrendLineStartTime, lowerTrendLineStart, lowerTrendLineEndTime, lowerTrendLineEnd);
    ObjectSetInteger(0, "FallingWedgeLower", OBJPROP_COLOR, clrBlue);
    ObjectSetInteger(0, "FallingWedgeLower", OBJPROP_WIDTH, 2);
}
//+------------------------------------------------------------------+
