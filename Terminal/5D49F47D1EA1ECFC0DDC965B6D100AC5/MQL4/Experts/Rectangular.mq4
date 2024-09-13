/*
//=====================================RECTANGLE BOX==================================================
//+------------------------------------------------------------------+
//|                                                  Rectangular.mq4 |
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
    // Initialization code
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Deinitialization code
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Example: Draw a rectangle from the highest high to the lowest low of the last 30 bars

    // Find highest and lowest prices in the last 30 bars
    int highestIndex = iHighest(NULL, 0, MODE_HIGH, 30, 0);
    int lowestIndex = iLowest(NULL, 0, MODE_LOW, 30, 0);

    double highestPrice = High[highestIndex];
    double lowestPrice = Low[lowestIndex];

    // Delete existing rectangle if it exists
    ObjectDelete("MyRectangle");

    // Create a new rectangle
    if (ObjectCreate("MyRectangle", OBJ_RECTANGLE, 0,
                     Time[lowestIndex], lowestPrice,
                     Time[highestIndex], highestPrice))
    {
        // Set rectangle properties
        ObjectSetInteger(0, "MyRectangle", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(0, "MyRectangle", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, "MyRectangle", OBJPROP_WIDTH, 1);
    }
    else
    {
        Print("Failed to create rectangle");
    }
}


*/
//===========================================RECTANGLE WITH TRENDLINE===========================================================================



//+------------------------------------------------------------------+
//|                                              RectangleExample.mq4 |
//|                       Copyright 2024, Your Company Name           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Company Name"
#property link      "https://www.yourcompany.com"
#property version   "1.00"
#property strict

// Global variables for trendline
int Trendline;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Deinitialization code
    ObjectDelete("MyRectangle"); // Delete rectangle object
    ObjectDelete("MyTrendline"); // Delete trendline object
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Example: Draw a rectangle from the highest high to the lowest low of the last 30 bars

    // Find highest and lowest prices in the last 30 bars
    int highestIndex = iHighest(NULL, 0, MODE_HIGH, 30, 0);
    int lowestIndex = iLowest(NULL, 0, MODE_LOW, 30, 0);

    double highestPrice = High[highestIndex];
    double lowestPrice = Low[lowestIndex];

    // Delete existing rectangle and trendline if they exist
    ObjectDelete("MyRectangle");
    ObjectDelete("MyTrendline");

    // Create a new rectangle
    if (ObjectCreate("MyRectangle", OBJ_RECTANGLE, 0,
                     Time[lowestIndex], lowestPrice,
                     Time[highestIndex], highestPrice))
    {
        // Set rectangle properties
        ObjectSetInteger(0, "MyRectangle", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(0, "MyRectangle", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, "MyRectangle", OBJPROP_WIDTH, 1);
    }
    else
    {
        Print("Failed to create rectangle");
    }

    // Calculate trendline points based on desired slope (angle in degrees)
    double startX = Time[lowestIndex];
    double startY = Low[lowestIndex]; // Corrected to Low
    double angle = 45.0; // Example slope angle in degrees
    double endX = Time[highestIndex]; // Change endX to desired time
    double endY = startY + (endX - startX) * MathTan(angle * 3.14 / 180.0); // Calculate endY based on slope

    // Create a trendline from the lower left corner of the rectangle
    Trendline = ObjectCreate("MyTrendline", OBJ_TRENDBYANGLE, 0, 
                             Time[lowestIndex], Low[lowestIndex], // Corrected to Low
                             angle);
    
    if (Trendline != 0)
    {
        ObjectSetInteger(0, "MyTrendline", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "MyTrendline", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, "MyTrendline", OBJPROP_WIDTH, 1);
    }
    else
    {
        Print("Failed to create trendline");
    }
}


//======================================================================================================================


