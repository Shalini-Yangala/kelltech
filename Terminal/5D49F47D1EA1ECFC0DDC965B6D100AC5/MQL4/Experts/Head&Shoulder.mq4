//+------------------------------------------------------------------+
//|                                                Head&Shoulder.mq4 |
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
bool DetectHeadAndShouldersPattern();
void DrawHeadAndShouldersOnChart();
void CheckForHeadAndShouldersBreakout();
void FindSwingPoints(int period, int &highs[], int &lows[]);

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
    // Check for Head & Shoulders pattern
    if (DetectHeadAndShouldersPattern()) {
        PatternDetected = true;
        Print("Head & Shoulders Pattern Detected");
        DrawHeadAndShouldersOnChart();
    }
    
    // Check for breakout after detecting the pattern
    if (PatternDetected) {
        CheckForHeadAndShouldersBreakout();
    }
}

//+------------------------------------------------------------------+
//| Function to detect Head & Shoulders pattern                      |
//+------------------------------------------------------------------+
bool DetectHeadAndShouldersPattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 5 || ArraySize(swingLows) < 4) return false;
    
    // Check for Head & Shoulders pattern
    for (int i = 1; i <= ArraySize(swingHighs) - 4; i++) {
        double leftShoulder = High[swingHighs[i]];
        double head = High[swingHighs[i + 1]];
        double rightShoulder = High[swingHighs[i + 2]];
        double neckline1 = Low[swingLows[i]];
        double neckline2 = Low[swingLows[i + 2]];

        if (leftShoulder < head && rightShoulder < head && leftShoulder == rightShoulder) {
            if (neckline1 == neckline2 || MathAbs(neckline1 - neckline2) <= BreakoutPips * Point) {
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Function to draw Head & Shoulders pattern                        |
//+------------------------------------------------------------------+
void DrawHeadAndShouldersOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw pattern on chart
    if (ArraySize(swingHighs) >= 5 && ArraySize(swingLows) >= 4) {
        // Draw left shoulder
        ObjectCreate(0, "LeftShoulder", OBJ_VLINE, 0, Time[swingHighs[1]], High[swingHighs[1]]);
        ObjectCreate(0, "Head", OBJ_VLINE, 0, Time[swingHighs[2]], High[swingHighs[2]]);
        ObjectCreate(0, "RightShoulder", OBJ_VLINE, 0, Time[swingHighs[3]], High[swingHighs[3]]);
        
        ObjectSetInteger(0, "LeftShoulder", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "Head", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, "RightShoulder", OBJPROP_COLOR, clrBlue);
        
        // Draw neckline
        ObjectCreate(0, "Neckline", OBJ_TREND, 0, Time[swingLows[1]], Low[swingLows[1]], Time[swingLows[3]], Low[swingLows[3]]);
        ObjectSetInteger(0, "Neckline", OBJPROP_COLOR, clrYellow);
        ObjectSetInteger(0, "Neckline", OBJPROP_WIDTH, 2);
    }
}

//+------------------------------------------------------------------+
//| Function to check trading conditions for Head & Shoulders        |
//+------------------------------------------------------------------+
void CheckForHeadAndShouldersBreakout()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    double neckline = (Low[swingLows[1]] + Low[swingLows[3]]) / 2;

    // Check for breakout below neckline
    if (Bid < neckline - BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Head & Shoulders Breakout Sell", 0, 0, clrRed);
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
