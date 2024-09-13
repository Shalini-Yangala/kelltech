
//+------------------------------------------------------------------+
//|                                                      GannBox.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define SYMBOL_DOT 3

// Input parameters
extern bool reverse = false;
extern bool Future = true;

extern bool showBox = true;
extern bool showLabel = true;

extern double perc1 = 25.0;
extern double perc2 = 38.2;
extern double perc3 = 50.0;
extern double perc4 = 61.8;
extern double perc5 = 75.0;

extern color color1 = clrRed;
extern color color2 = clrGreen;
extern color color3 = clrBlue;
extern color color4 = clrGray;
extern color color5 = clrYellow;
extern color color6 = clrRed;

extern bool showFan = false;
extern color fcol1 = clrOrange;
extern color fcol2 = clrLime;
extern color fcol3 = clrGreen;
extern color fcol4 = clrAqua;
extern color fcol5 = clrCyan;
extern color fcol6 = clrBlue;

extern bool showCurve = false;
extern color ccol1 = clrOrange;
extern color ccol2 = clrLime;
extern color ccol3 = clrGreen;
extern color ccol4 = clrAqua;
extern color ccol5 = clrCyan;
extern color ccol6 = clrBlue;

extern bool showAngles = false;
extern color angleColor = clrOrange;

// Arrays for Fibonacci levels and colors
double percLevels[5];
color boxColors[6];
color fanColors[6];
color curveColors[6];

// Variables for high and low points
double highestHigh;
double lowestLow;
int highBarIndex;
int lowBarIndex;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize percentage levels
    percLevels[0] = perc1 / 100.0;
    percLevels[1] = perc2 / 100.0;
    percLevels[2] = perc3 / 100.0;
    percLevels[3] = perc4 / 100.0;
    percLevels[4] = perc5 / 100.0;

    // Initialize box colors
    boxColors[0] = color1;
    boxColors[1] = color2;
    boxColors[2] = color3;
    boxColors[3] = color4;
    boxColors[4] = color5;
    boxColors[5] = color6;

    // Initialize fan colors
    fanColors[0] = fcol1;
    fanColors[1] = fcol2;
    fanColors[2] = fcol3;
    fanColors[3] = fcol4;
    fanColors[4] = fcol5;
    fanColors[5] = fcol6;

    // Initialize curve colors
    curveColors[0] = ccol1;
    curveColors[1] = ccol2;
    curveColors[2] = ccol3;
    curveColors[3] = ccol4;
    curveColors[4] = ccol5;
    curveColors[5] = ccol6;

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if (rates_total < 2)
        return(0);

    // Determine the highest high and lowest low in the visible range
    int firstVisibleBar = WindowFirstVisibleBar();
    int visibleBars = WindowBarsPerChart();
    int lastVisibleBar = firstVisibleBar + visibleBars - 1;

    highestHigh = -DBL_MAX;
    lowestLow = DBL_MAX;
    highBarIndex = -1;
    lowBarIndex = -1;

    for (int i = firstVisibleBar; i <= lastVisibleBar; i++)
    {
        if (i < 0 || i >= rates_total)
            continue;

        if (high[i] > highestHigh)
        {
            highestHigh = high[i];
            highBarIndex = i;
        }

        if (low[i] < lowestLow)
        {
            lowestLow = low[i];
            lowBarIndex = i;
        }
    }

    // Calculate the Gann Box levels and draw the objects
    if (showBox)
    {
        DrawGannBox(highBarIndex, lowBarIndex, time, high, low, rates_total);
    }

    if (showAngles)
    {
        DrawGannAngles(highBarIndex, lowBarIndex, rates_total, time, high, low);
    }

    if (showFan)
    {
        DrawGannFan(highBarIndex, lowBarIndex, rates_total, time, high, low);
    }

    if (showCurve)
    {
        DrawGannCurves(highBarIndex, lowBarIndex, rates_total, time, high, low);
    }

    return(rates_total);
}

//+------------------------------------------------------------------+
//| Function to draw Gann Box                                        |
//+------------------------------------------------------------------+
void DrawGannBox(int highIndex, int lowIndex, const datetime &time[], const double &high[], const double &low[], int rates_total)
{
    double x0, y0, x6, y6;
    int startBar = MathMin(highIndex, lowIndex);
    int endBar = Future ? MathMin(rates_total - 1, startBar + 500) : MathMax(highIndex, lowIndex);

    x0 = time[startBar];
    y0 = (highIndex < lowIndex) ? low[lowIndex] : high[highIndex];
    x6 = time[endBar];
    y6 = (highIndex < lowIndex) ? high[highIndex] : low[lowIndex];

    for (int i = 0; i < 5; i++)
    {
        double level = y0 + percLevels[i] * (y6 - y0);
        string objName = "GannBox_" + IntegerToString(i);
        if (!ObjectCreate(0, objName, OBJ_RECTANGLE, 0, x0, y0, x6, level))
        {
            Print("Failed to create GannBox object: ", objName);
        }
        else
        {
            ObjectSetInteger(0, objName, OBJPROP_COLOR, boxColors[i]);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        }
    }
}

//+------------------------------------------------------------------+
//| Function to draw Gann Curves                                     |
//+------------------------------------------------------------------+
void DrawGannCurves(int highIndex, int lowIndex, int rates_total, const datetime &time[], const double &high[], const double &low[])
{
    double x0, y0, x6, y6;
    int startBar = MathMin(highIndex, lowIndex);
    int endBar = Future ? MathMin(rates_total - 1, startBar + 500) : MathMax(highIndex, lowIndex);

    x0 = time[startBar];
    y0 = (highIndex < lowIndex) ? low[lowIndex] : high[highIndex];
    x6 = time[endBar];
    y6 = (highIndex < lowIndex) ? high[highIndex] : low[lowIndex];

    for (int i = 1; i <= 5; i++)
    {
        for (int j = 0; j <= 90; j++)
        {
            double xx = x0 - (x0 - x6) * MathSin(j * M_PI / 180);
            double yy = y0 + MathCos(j * M_PI / 180) * (y6 - y0);
            string curvePoint = "Curve_" + IntegerToString(i) + "_" + IntegerToString(j);
            if (ObjectFind(0, curvePoint) >= 0)
            {
                ObjectDelete(0, curvePoint);
            }
            if (!ObjectCreate(0, curvePoint, OBJ_ARROW, 0, xx, yy))
            {
                Print("Failed to create GannCurve point: ", curvePoint);
            }
            else
            {
                ObjectSetInteger(0, curvePoint, OBJPROP_COLOR, curveColors[i - 1]);
                ObjectSetInteger(0, curvePoint, OBJPROP_WIDTH, 2);
                ObjectSetInteger(0, curvePoint, OBJPROP_ARROWCODE, SYMBOL_DOT);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Function to draw Gann Angles                                     |
//+------------------------------------------------------------------+
void DrawGannAngles(int highIndex, int lowIndex, int rates_total, const datetime &time[], const double &high[], const double &low[])
{
    double x0, y0, x6, y6;
    int startBar = MathMin(highIndex, lowIndex);
    int endBar = Future ? MathMin(rates_total - 1, startBar + 500) : MathMax(highIndex, lowIndex);

    x0 = time[startBar];
    y0 = (highIndex < lowIndex) ? low[lowIndex] : high[highIndex];
    x6 = time[endBar];
    y6 = (highIndex < lowIndex) ? high[highIndex] : low[lowIndex];

    if (ObjectFind(0, "GannAngle_1x1") >= 0)
    {
        ObjectDelete(0, "GannAngle_1x1");
    }
    if (showAngles)
    {
        if (!ObjectCreate(0, "GannAngle_1x1", OBJ_TREND, 0, x0, y0, x6, y6))
        {
            Print("Failed to create GannAngle 1x1");
        }
        else
        {
            ObjectSetInteger(0, "GannAngle_1x1", OBJPROP_COLOR, angleColor);
            ObjectSetInteger(0, "GannAngle_1x1", OBJPROP_WIDTH, 2);
        }
    }
}

//+------------------------------------------------------------------+
//| Function to draw Gann Fan                                        |
//+------------------------------------------------------------------+
void DrawGannFan(int highIndex, int lowIndex, int rates_total, const datetime &time[], const double &high[], const double &low[])
{
    double x0, y0, x6, y6;
    int startBar = MathMin(highIndex, lowIndex);
    int endBar = Future ? MathMin(rates_total - 1, startBar + 500) : MathMax(highIndex, lowIndex);

    x0 = time[startBar];
    y0 = (highIndex < lowIndex) ? low[lowIndex] : high[highIndex];
    x6 = time[endBar];
    y6 = (highIndex < lowIndex) ? high[highIndex] : low[lowIndex];

    for (int i = 0; i < 5; i++)
    {
        if (ObjectFind(0, "GannFan_" + IntegerToString(i)) >= 0)
        {
            ObjectDelete(0, "GannFan_" + IntegerToString(i));
        }
        if (showFan)
        {
            double angle = atan((y6 - y0) / (x6 - x0));
            double fanX = x0 + (x6 - x0) * MathCos(angle * percLevels[i]);
            double fanY = y0 + (y6 - y0) * MathSin(angle * percLevels[i]);

            if (!ObjectCreate(0, "GannFan_" + IntegerToString(i), OBJ_TREND, 0, x0, y0, fanX, fanY))
            {
                Print("Failed to create GannFan object: ", "GannFan_" + IntegerToString(i));
            }
            else
            {
                ObjectSetInteger(0, "GannFan_" + IntegerToString(i), OBJPROP_COLOR, fanColors[i]);
                ObjectSetInteger(0, "GannFan_" + IntegerToString(i), OBJPROP_WIDTH, 2);
            }
        }
    }
}
//+------------------------------------------------------------------+



