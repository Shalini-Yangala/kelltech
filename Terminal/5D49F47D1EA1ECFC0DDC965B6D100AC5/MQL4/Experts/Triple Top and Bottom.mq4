/*

//+------------------------------------------------------------------+
//|                                        Triple Top and Bottom.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict

// Define input parameters
input int LookbackPeriod = 100; // Period to look back for patterns
input int MinSwingPoints = 3;   // Minimum number of swing points to validate trendline
input double BreakoutPips = 10; // Number of pips for a breakout

// Declare global variables
datetime LastTradeTime;
bool PatternDetected = false;

// Function declarations for pattern detection and other utility functions
bool DetectWedgePattern();
void DrawWedgeOnChart();
void CheckForBreakout();
bool DetectTripleTopPattern();
void DrawTripleTopOnChart();
void CheckForTripleTopBreakout();
void FindSwingPoints(int period, int &highs[], int &lows[]);
double CalculateTrendlineSlope(int &points[]);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code
    return(INIT_SUCCEEDED);
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
    // Check for different patterns
    if (DetectWedgePattern()) {
        PatternDetected = true;
        Print("Wedge Pattern Detected");
        DrawWedgeOnChart();
    } else if (DetectTripleTopPattern()) {
        PatternDetected = true;
        Print("Triple Top Pattern Detected");
        DrawTripleTopOnChart();
    }
    
    // Example: Check for breakout after detecting the pattern
    if (PatternDetected) {
        CheckForBreakout();
        CheckForTripleTopBreakout();
    }
}

//+------------------------------------------------------------------+
//| Function to detect Wedge pattern                                 |
//+------------------------------------------------------------------+
bool DetectWedgePattern()
{
    // Placeholder for detecting wedge pattern
    return false;
}

//+------------------------------------------------------------------+
//| Function to draw Wedge pattern                                   |
//+------------------------------------------------------------------+
void DrawWedgeOnChart()
{
    // Placeholder for drawing wedge on chart
}

//+------------------------------------------------------------------+
//| Function to check for breakout                                   |
//+------------------------------------------------------------------+
void CheckForBreakout()
{
    // Placeholder for checking breakout
}

//+------------------------------------------------------------------+
//| Function to detect Triple Top pattern                             |
//+------------------------------------------------------------------+
bool DetectTripleTopPattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 5) return false;
    
    // Check for Triple Top pattern
    double firstTop = High[swingHighs[ArraySize(swingHighs) - 5]];
    double secondTop = High[swingHighs[ArraySize(swingHighs) - 3]];
    double thirdTop = High[swingHighs[ArraySize(swingHighs) - 1]];

    if (firstTop == secondTop && secondTop == thirdTop) return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Function to draw Triple Top pattern                               |
//+------------------------------------------------------------------+
void DrawTripleTopOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw pattern on chart
    if (ArraySize(swingHighs) >= 5) {
        ObjectCreate(0, "FirstTop", OBJ_VLINE, 0, Time[swingHighs[ArraySize(swingHighs) - 5]], High[swingHighs[ArraySize(swingHighs) - 5]]);
        ObjectCreate(0, "SecondTop", OBJ_VLINE, 0, Time[swingHighs[ArraySize(swingHighs) - 3]], High[swingHighs[ArraySize(swingHighs) - 3]]);
        ObjectCreate(0, "ThirdTop", OBJ_VLINE, 0, Time[swingHighs[ArraySize(swingHighs) - 1]], High[swingHighs[ArraySize(swingHighs) - 1]]);
        
        ObjectSetInteger(0, "FirstTop", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "SecondTop", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, "ThirdTop", OBJPROP_COLOR, clrBlue);
    }
}

//+------------------------------------------------------------------+
//| Function to check trading conditions for Triple Top               |
//+------------------------------------------------------------------+
void CheckForTripleTopBreakout()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    double neckline = Low[swingLows[ArraySize(swingLows) - 3]];

    // Check for breakout below neckline
    if (Bid < neckline - BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Triple Top Breakout Sell", 0, 0, clrRed);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening sell order: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Function to find swing points                                    |
//+------------------------------------------------------------------+
void FindSwingPoints(int period, int &highs[], int &lows[])
{
    ArrayResize(highs, 0);
    ArrayResize(lows, 0);
    
    for (int i = period; i >= 1; i--) {
        if (High[i] > High[i+1] && High[i] > High[i-1]) {
            ArrayResize(highs, ArraySize(highs) + 1);
            highs[ArraySize(highs) - 1] = i;
        }
        if (Low[i] < Low[i+1] && Low[i] < Low[i-1]) {
            ArrayResize(lows, ArraySize(lows) + 1);
            lows[ArraySize(lows) - 1] = i;
        }
    }
}


*/
//=======================================================================================================================

//+------------------------------------------------------------------+
//|                                          Triple Top and Bottom.mq4|
//|                             Copyright 2024, MetaQuotes Software Corp.|
//|                                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property strict

input int LookbackPeriod = 100; // Period to look back for patterns
input int MinSwingPoints = 3;   // Minimum number of swing points to validate trendline
input double BreakoutPips = 10; // Number of pips for a breakout

// Declare global variables
datetime LastTradeTime;
bool PatternDetected = false;
bool isTripleTop = false; // To differentiate between top and bottom patterns

// Function declarations for pattern detection and other utility functions
bool DetectTripleTopBottomPattern();
void DrawTripleTopBottomOnChart();
void CheckForBreakout();
void FindSwingPoints(int period, int &highs[], int &lows[]);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code
    Print("Triple Top and Bottom pattern detection initialized.");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Deinitialization code
    Print("Triple Top and Bottom pattern detection deinitialized.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for different patterns
    if (DetectTripleTopBottomPattern()) {
        PatternDetected = true;
        Print("Triple Top/Bottom Pattern Detected");
        DrawTripleTopBottomOnChart();
    } else {
        PatternDetected = false;
    }
    
    //  Check for breakout after detecting the pattern
    if (PatternDetected) {
        CheckForBreakout();
    }
}

//+------------------------------------------------------------------+
//| Function to detect Triple Top/Bottom pattern                     |
//+------------------------------------------------------------------+
bool DetectTripleTopBottomPattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Debugging
    Print("Swing highs count: ", ArraySize(swingHighs));
    Print("Swing lows count: ", ArraySize(swingLows));
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 3 && ArraySize(swingLows) < 3) return false;
    
    // Check for Triple Top pattern
    for (int i = 0; i <= ArraySize(swingHighs) - 3; i++) {
        if (High[swingHighs[i]] == High[swingHighs[i + 1]] && High[swingHighs[i + 1]] == High[swingHighs[i + 2]]) {
            isTripleTop = true;
            Print("Triple Top found at: ", TimeToString(Time[swingHighs[i]], TIME_DATE|TIME_MINUTES));
            return true;
        }
    }

    // Check for Triple Bottom pattern
    for (int i = 0; i <= ArraySize(swingLows) - 3; i++) {
        if (Low[swingLows[i]] == Low[swingLows[i + 1]] && Low[swingLows[i + 1]] == Low[swingLows[i + 2]]) {
            isTripleTop = false;
            Print("Triple Bottom found at: ", TimeToString(Time[swingLows[i]], TIME_DATE|TIME_MINUTES));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Function to draw Triple Top/Bottom pattern                       |
//+------------------------------------------------------------------+
void DrawTripleTopBottomOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw pattern on chart
    if (ArraySize(swingHighs) >= 3) {
        for (int i = 0; i <= ArraySize(swingHighs) - 3; i++) {
            if (High[swingHighs[i]] == High[swingHighs[i + 1]] && High[swingHighs[i + 1]] == High[swingHighs[i + 2]]) {
                // Draw resistance line
                string objName = "ResistanceLine_" + IntegerToString(Time[swingHighs[i]]);
                ObjectCreate(0, objName, OBJ_TREND, 0, Time[swingHighs[i]], High[swingHighs[i]], Time[swingHighs[i + 2]], High[swingHighs[i + 2]]);
                ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
                break;
            }
        }
    }

    if (ArraySize(swingLows) >= 3) {
        for (int i = 0; i <= ArraySize(swingLows) - 3; i++) {
            if (Low[swingLows[i]] == Low[swingLows[i + 1]] && Low[swingLows[i + 1]] == Low[swingLows[i + 2]]) {
                // Draw support line
                string objName = "SupportLine_" + IntegerToString(Time[swingLows[i]]);
                ObjectCreate(0, objName, OBJ_TREND, 0, Time[swingLows[i]], Low[swingLows[i]], Time[swingLows[i + 2]], Low[swingLows[i + 2]]);
                ObjectSetInteger(0, objName, OBJPROP_COLOR, clrBlue);
                break;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Function to check for breakout                                   |
//+------------------------------------------------------------------+
void CheckForBreakout()
{
    double breakoutLevel;
    if (isTripleTop) {
        // Get the price of the resistance line
        breakoutLevel = ObjectGetDouble(0, "ResistanceLine", OBJPROP_PRICE1);
        // Check if the price has broken out above the resistance line
        if (Close[0] > breakoutLevel + BreakoutPips * Point) {
            Print("Breakout detected above the resistance line at: ", breakoutLevel);
            // Perform any action after breakout, like placing a trade or drawing additional lines
        }
    } else {
        // Get the price of the support line
        breakoutLevel = ObjectGetDouble(0, "SupportLine", OBJPROP_PRICE1);
        // Check if the price has broken out below the support line
        if (Close[0] < breakoutLevel - BreakoutPips * Point) {
            Print("Breakout detected below the support line at: ", breakoutLevel);
            // Perform any action after breakout, like placing a trade or drawing additional lines
        }
    }
}

//+------------------------------------------------------------------+
//| Function to find swing points                                    |
//+------------------------------------------------------------------+
void FindSwingPoints(int period, int &highs[], int &lows[])
{
    ArrayResize(highs, 0);
    ArrayResize(lows, 0);
    
    for (int i = period; i >= 1; i--) {
        if (High[i] > High[i + 1] && High[i] > High[i - 1]) {
            ArrayResize(highs, ArraySize(highs) + 1);
            highs[ArraySize(highs) - 1] = i;
        }
        if (Low[i] < Low[i + 1] && Low[i] < Low[i - 1]) {
            ArrayResize(lows, ArraySize(lows) + 1);
            lows[ArraySize(lows) - 1] = i;
        }
    }
}
