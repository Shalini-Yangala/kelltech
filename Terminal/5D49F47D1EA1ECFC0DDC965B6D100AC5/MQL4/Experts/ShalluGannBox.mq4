//+------------------------------------------------------------------+
//|                                                ShalluGannBox.mq4 |
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
    // Calculate the number for the visible candles
    int CandlesOnChart = WindowFirstVisibleBar();
    // Find the highest candle on the chart
    int HighestCandle = iHighest(_Symbol, _Period, MODE_HIGH, CandlesOnChart, 0);

    // Calculate Fibonacci levels
    double fib38_2 = (High[HighestCandle] - Low[HighestCandle]) * 0.382 + Low[HighestCandle];
    double fib50_0 = (High[HighestCandle] - Low[HighestCandle]) * 0.5 + Low[HighestCandle];
    double fib61_8 = (High[HighestCandle] - Low[HighestCandle]) * 0.618 + Low[HighestCandle];
    
    // Draw Fibonacci level lines
    ObjectCreate(0, "Fib38.2", OBJ_TREND, 0, Time[HighestCandle], fib38_2, Time[0], fib38_2);
    ObjectSetInteger(0, "Fib38.2", OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, "Fib38.2", OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, "Fib38.2", OBJPROP_WIDTH, 1);
    
    ObjectCreate(0, "Fib50.0", OBJ_TREND, 0, Time[HighestCandle], fib50_0, Time[0], fib50_0);
    ObjectSetInteger(0, "Fib50.0", OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, "Fib50.0", OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, "Fib50.0", OBJPROP_WIDTH, 1);
    
    ObjectCreate(0, "Fib61.8", OBJ_TREND, 0, Time[HighestCandle], fib61_8, Time[0], fib61_8);
    ObjectSetInteger(0, "Fib61.8", OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, "Fib61.8", OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, "Fib61.8", OBJPROP_WIDTH, 1);

    // Draw Gann Box
    double gannBoxStartX = Time[HighestCandle];
    double gannBoxStartY = High[HighestCandle];
    double gannBoxEndX = Time[0];
    double gannBoxEndY = Low[0];

    ObjectCreate(0, "GannBox", OBJ_RECTANGLE, 0, gannBoxStartX, gannBoxStartY, gannBoxEndX, gannBoxEndY);
    ObjectSetInteger(0, "GannBox", OBJPROP_COLOR, clrGray);
    ObjectSetInteger(0, "GannBox", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, "GannBox", OBJPROP_WIDTH, 1);

    // Add label for Gann Box
    ObjectCreate(0, "GannBoxLabel", OBJ_LABEL, 0, 0, 0);
    ObjectSetText(0, "Gann Box", 10, "Arial", clrWhite);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Remove objects
    ObjectDelete("Fib38.2");
    ObjectDelete("Fib50.0");
    ObjectDelete("Fib61.8");
    ObjectDelete("GannBox");
    ObjectDelete("GannBoxLabel");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Calculate the number for the visible candles
    int CandlesOnChart = WindowFirstVisibleBar();
    // Find the highest candle on the chart
    int HighestCandle = iHighest(_Symbol, _Period, MODE_HIGH, CandlesOnChart, 0);
   
    // Delete the object
    ObjectDelete("SimpleHighGannFan");
   
    // Create Object
    ObjectCreate(
        0,                   // for the current chart
        "SimpleHighGannFan",  // object name
        OBJ_GANNFAN,         // Object type
        0,                   // In the Main chart
        Time[HighestCandle], // from the highest candle
        High[HighestCandle], // from the highest price
        Time[0],             // to the current candle
        High[0]              // for the highest price
    );
   
    // Set the object color
    ObjectSetInteger(0, "SimpleHighGannFan", OBJPROP_COLOR, Orange);
   
    // Set the object prediction
    ObjectSetInteger(0, "SimpleHighGannFan", OBJPROP_RAY, true);
}
