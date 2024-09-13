//+------------------------------------------------------------------+
//|                                                      AutoChart.mq4|
//|                        Copyright 2024, MetaQuotes Software Corp.  |
//|                                             https://www.mql5.com  |
//+------------------------------------------------------------------+
#property strict

// Define input parameters
input int LookbackPeriod = 100; // Period to look back for patterns
input int MinSwingPoints = 3;   // Minimum number of swing points to validate trendline
input double BreakoutPips = 10; // Number of pips for a breakout

// Declare global variables
datetime LastTradeTime;
bool PatternDetected = false;

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
    } else if (DetectHeadAndShouldersPattern()) {
        PatternDetected = true;
        Print("Head & Shoulders Pattern Detected");
        DrawHeadAndShouldersOnChart();
    } else if (DetectPennantPattern()) {
        PatternDetected = true;
        Print("Pennant Pattern Detected");
        DrawPennantOnChart();
    } else if (DetectDoubleTopPattern()) {
        PatternDetected = true;
        Print("Double Top Pattern Detected");
        DrawDoubleTopOnChart();
    } else if (DetectTripleTopPattern()) {
        PatternDetected = true;
        Print("Triple Top Pattern Detected");
        DrawTripleTopOnChart();
    } else if (DetectAscendingTrianglePattern()) {
        PatternDetected = true;
        Print("Ascending Triangle Pattern Detected");
        DrawAscendingTriangleOnChart();
    }

    // Example: Check for breakout after detecting the pattern
    if (PatternDetected) {
        CheckForBreakout();
        CheckForHeadAndShouldersBreakout();
        CheckForPennantBreakout();
        CheckForDoubleTopBreakout();
        CheckForTripleTopBreakout();
        CheckForAscendingTriangleBreakout();
    }
}

//+------------------------------------------------------------------+
//| Function to detect wedge patterns                                |
//+------------------------------------------------------------------+
bool DetectWedgePattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < MinSwingPoints || ArraySize(swingLows) < MinSwingPoints) return false;
    
    // Calculate trendline slopes
    double upperTrendlineSlope = CalculateTrendlineSlope(swingHighs);
    double lowerTrendlineSlope = CalculateTrendlineSlope(swingLows);
    
    // Rising wedge: both trendlines are ascending but converging
    if (upperTrendlineSlope > 0 && lowerTrendlineSlope > 0 && upperTrendlineSlope < lowerTrendlineSlope) return true;
    // Falling wedge: both trendlines are descending but converging
    if (upperTrendlineSlope < 0 && lowerTrendlineSlope < 0 && upperTrendlineSlope > lowerTrendlineSlope) return true;
    
    return false;
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

//+------------------------------------------------------------------+
//| Function to calculate trendline slope                            |
//+------------------------------------------------------------------+
double CalculateTrendlineSlope(int &points[])
{
    int n = ArraySize(points);
    if (n < 2) return 0;
    
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    
    for (int i = 0; i < n; i++) {
        sumX += points[i];
        sumY += Close[points[i]];
        sumXY += points[i] * Close[points[i]];
        sumXX += points[i] * points[i];
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
}

//+------------------------------------------------------------------+
//| Function to draw wedge on chart                                  |
//+------------------------------------------------------------------+
void DrawWedgeOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw trendlines on chart
    if (ArraySize(swingHighs) >= MinSwingPoints && ArraySize(swingLows) >= MinSwingPoints) {
        ObjectCreate(0, "UpperTrendline", OBJ_TREND, 0, Time[swingHighs[0]], High[swingHighs[0]], Time[swingHighs[ArraySize(swingHighs)-1]], High[swingHighs[ArraySize(swingHighs)-1]]);
        ObjectCreate(0, "LowerTrendline", OBJ_TREND, 0, Time[swingLows[0]], Low[swingLows[0]], Time[swingLows[ArraySize(swingLows)-1]], Low[swingLows[ArraySize(swingLows)-1]]);
        
        ObjectSetInteger(0, "UpperTrendline", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "LowerTrendline", OBJPROP_COLOR, clrGreen);
    }
}

//+------------------------------------------------------------------+
//| Function to check for breakout                                   |
//+------------------------------------------------------------------+
void CheckForBreakout()
{
    double upperTrendlineValue = iCustom(NULL, 0, "UpperTrendline", 0, 0);
    double lowerTrendlineValue = iCustom(NULL, 0, "LowerTrendline", 0, 0);
    int ticket;

    // Check for breakout above upper trendline
    if (Ask > upperTrendlineValue + BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Wedge Breakout Buy", 0, 0, clrBlue);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening buy order: ", GetLastError());
            }
        }
    }
    
    // Check for breakout below lower trendline
    if (Bid < lowerTrendlineValue - BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Wedge Breakout Sell", 0, 0, clrRed);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening sell order: ", GetLastError());
            }
        }
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
    if (ArraySize(swingHighs) < 5 || ArraySize(swingLows) < 5) return false;
    
    // Check for Head & Shoulders pattern
    for (int i = 1; i <= ArraySize(swingHighs) - 4; i++) {
        double leftShoulder = High[swingHighs[i]];
        double head = High[swingHighs[i + 1]];
        double rightShoulder = High[swingHighs[i + 2]];

        if (leftShoulder < head && rightShoulder < head && leftShoulder == rightShoulder) {
            return true;
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
    if (ArraySize(swingHighs) >= 5 && ArraySize(swingLows) >= 5) {
        // Draw left shoulder
        ObjectCreate(0, "LeftShoulder", OBJ_VLINE, 0, Time[swingHighs[1]], High[swingHighs[1]]);
        ObjectCreate(0, "Head", OBJ_VLINE, 0, Time[swingHighs[2]], High[swingHighs[2]]);
        ObjectCreate(0, "RightShoulder", OBJ_VLINE, 0, Time[swingHighs[3]], High[swingHighs[3]]);
        
        ObjectSetInteger(0, "LeftShoulder", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "Head", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, "RightShoulder", OBJPROP_COLOR, clrBlue);
    }
}
//+------------------------------------------------------------------+
//| Function to check trading conditions for Head & Shoulders        |
//+------------------------------------------------------------------+
void CheckForHeadAndShouldersBreakout()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    double neckline = (Low[swingLows[1]] + Low[swingLows[2]]) / 2;

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
//| Function to detect Pennant pattern                               |
//+------------------------------------------------------------------+
bool DetectPennantPattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 3 || ArraySize(swingLows) < 3) return false;
    
    // Check for Pennant pattern
    double upperTrendlineSlope = CalculateTrendlineSlope(swingHighs);
    double lowerTrendlineSlope = CalculateTrendlineSlope(swingLows);
    
    if (upperTrendlineSlope < 0 && lowerTrendlineSlope > 0) return true;
    
    return false;
}
//+------------------------------------------------------------------+
//| Function to draw Pennant pattern                                 |
//+------------------------------------------------------------------+
void DrawPennantOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw trendlines on chart
    if (ArraySize(swingHighs) >= 3 && ArraySize(swingLows) >= 3) {
        ObjectCreate(0, "PennantUpperTrendline", OBJ_TREND, 0, Time[swingHighs[0]], High[swingHighs[0]], Time[swingHighs[ArraySize(swingHighs)-1]], High[swingHighs[ArraySize(swingHighs)-1]]);
        ObjectCreate(0, "PennantLowerTrendline", OBJ_TREND, 0, Time[swingLows[0]], Low[swingLows[0]], Time[swingLows[ArraySize(swingLows)-1]], Low[swingLows[ArraySize(swingLows)-1]]);
        
        ObjectSetInteger(0, "PennantUpperTrendline", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "PennantLowerTrendline", OBJPROP_COLOR, clrGreen);
    }
}
//+------------------------------------------------------------------+
//| Function to check trading conditions for Pennant                 |
//+------------------------------------------------------------------+
void CheckForPennantBreakout()
{
    double upperTrendlineValue = iCustom(NULL, 0, "PennantUpperTrendline", 0, 0);
    double lowerTrendlineValue = iCustom(NULL, 0, "PennantLowerTrendline", 0, 0);
    int ticket;

    // Check for breakout above upper trendline
    if (Ask > upperTrendlineValue + BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Pennant Breakout Buy", 0, 0, clrBlue);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening buy order: ", GetLastError());
            }
        }
    }
    
    // Check for breakout below lower trendline
    if (Bid < lowerTrendlineValue - BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Pennant Breakout Sell", 0, 0, clrRed);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening sell order: ", GetLastError());
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Function to detect Double Top pattern                            |
//+------------------------------------------------------------------+
bool DetectDoubleTopPattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 3) return false;
    
    // Check for Double Top pattern
    double firstTop = High[swingHighs[ArraySize(swingHighs) - 3]];
    double secondTop = High[swingHighs[ArraySize(swingHighs) - 1]];

    if (firstTop == secondTop) return true;
    
    return false;
}
//+------------------------------------------------------------------+
//| Function to draw Double Top pattern                              |
//+------------------------------------------------------------------+
void DrawDoubleTopOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw pattern on chart
    if (ArraySize(swingHighs) >= 3) {
        ObjectCreate(0, "FirstTop", OBJ_VLINE, 0, Time[swingHighs[ArraySize(swingHighs) - 3]], High[swingHighs[ArraySize(swingHighs) - 3]]);
        ObjectCreate(0, "SecondTop", OBJ_VLINE, 0, Time[swingHighs[ArraySize(swingHighs) - 1]], High[swingHighs[ArraySize(swingHighs) - 1]]);
        
        ObjectSetInteger(0, "FirstTop", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "SecondTop", OBJPROP_COLOR, clrGreen);
    }
}
//+------------------------------------------------------------------+
//| Function to check trading conditions for Double Top              |
//+------------------------------------------------------------------+
void CheckForDoubleTopBreakout()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    double neckline = Low[swingLows[ArraySize(swingLows) - 2]];

    // Check for breakout below neckline
    if (Bid < neckline - BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Double Top Breakout Sell", 0, 0, clrRed);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening sell order: ", GetLastError());
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Function to detect Triple Top pattern                            |
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
//| Function to draw Triple Top pattern                              |
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
//| Function to check trading conditions for Triple Top              |
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
//| Function to detect Ascending Triangle pattern                    |
//+------------------------------------------------------------------+
bool DetectAscendingTrianglePattern()
{
    int swingHighs[], swingLows[];
    
    // Find swing highs and lows
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    
    // Ensure we have enough points
    if (ArraySize(swingHighs) < 3 || ArraySize(swingLows) < 3) return false;
    
    // Check for Ascending Triangle pattern
    double upperTrendline = High[swingHighs[ArraySize(swingHighs) - 1]];
    double lowerTrendlineSlope = CalculateTrendlineSlope(swingLows);
    
    if (lowerTrendlineSlope > 0 && High[swingHighs[ArraySize(swingHighs) - 3]] == upperTrendline) return true;
    
    return false;
}
//+------------------------------------------------------------------+
//| Function to draw Ascending Triangle pattern                      |
//+------------------------------------------------------------------+
void DrawAscendingTriangleOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw pattern on chart
    if (ArraySize(swingHighs) >= 3 && ArraySize(swingLows) >= 3) {
        ObjectCreate(0, "UpperTrendline", OBJ_TREND, 0, Time[swingHighs[0]], High[swingHighs[0]], Time[swingHighs[ArraySize(swingHighs)-1]], High[swingHighs[ArraySize(swingHighs)-1]]);
        ObjectCreate(0, "LowerTrendline", OBJ_TREND, 0, Time[swingLows[0]], Low[swingLows[0]], Time[swingLows[ArraySize(swingLows)-1]], Low[swingLows[ArraySize(swingLows)-1]]);
        
        ObjectSetInteger(0, "UpperTrendline", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "LowerTrendline", OBJPROP_COLOR, clrGreen);
    }
}
//+------------------------------------------------------------------+
//| Function to check trading conditions for Ascending Triangle      |
//+------------------------------------------------------------------+
void CheckForAscendingTriangleBreakout()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);
    double upperTrendline = High[swingHighs[ArraySize(swingHighs) - 1]];

    // Check for breakout above upper trendline
    if (Ask > upperTrendline + BreakoutPips * Point) {
        if (TimeCurrent() != LastTradeTime) {
            int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Ascending Triangle Breakout Buy", 0, 0, clrBlue);
            if (ticket > 0) {
                LastTradeTime = TimeCurrent();
            } else {
                Print("Error opening buy order: ", GetLastError());
            }
        }
    }
}


//+------------------------------------------------------------------+
//| Function to draw Wedge pattern                                   |
//+------------------------------------------------------------------+
void DrawWedgeOnChart()
{
    int swingHighs[], swingLows[];
    FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

    // Draw trendlines on chart
    if (ArraySize(swingHighs) >= MinSwingPoints && ArraySize(swingLows) >= MinSwingPoints) {
        // Delete existing objects if necessary
        ObjectDelete(0, "UpperTrendline");
        ObjectDelete(0, "LowerTrendline");

        // Create new trendlines
        int upperStartIndex = swingHighs[0];
        int upperEndIndex = swingHighs[ArraySize(swingHighs) - 1];
        int lowerStartIndex = swingLows[0];
        int lowerEndIndex = swingLows[ArraySize(swingLows) - 1];

        ObjectCreate(0, "UpperTrendline", OBJ_TREND, 0, Time[upperStartIndex], High[upperStartIndex], Time[upperEndIndex], High[upperEndIndex]);
        ObjectCreate(0, "LowerTrendline", OBJ_TREND, 0, Time[lowerStartIndex], Low[lowerStartIndex], Time[lowerEndIndex], Low[lowerEndIndex]);
        
        ObjectSetInteger(0, "UpperTrendline", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "LowerTrendline", OBJPROP_COLOR, clrGreen);

        Print("Wedge pattern trendlines drawn successfully.");
    } else {
        Print("Insufficient swing points to draw Wedge pattern.");
    }
}
