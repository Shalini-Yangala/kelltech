//+------------------------------------------------------------------+
//|                                                        Task1.mq4 |
//|                                       Copyright 2024, Individual |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
input int rocPeriod = 14; // ROC Period
input int atrPeriod = 14; // ATR Period
input int sensitivity = 50; // Sensitivity level to change color (0-100)
input bool enableAlerts = true; // Enable/disable alerts
double rocBuffer[];
double atrBuffer[];
color backgroundColor;
input int condition=10;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Define indicator buffers
    SetIndexBuffer(0, rocBuffer);
    // Indicator label
    IndicatorShortName("Trend Sentiment");
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
    // Calculate Rate of Change (ROC)
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(rocBuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    int startIdx = rocPeriod;
    for (int i = startIdx; i < rates_total; i++)
    {
        double roc = (close[i] - close[i - rocPeriod]) / close[i - rocPeriod] * 100.0;
        rocBuffer[i] = roc;
    }
    // Calculate Average True Range (ATR)
    double prevATR = 0;
    for (int j = 1; j < rates_total; j++)
    {
        double trueRange = MathMax(high[j] - low[j],  MathMax(MathAbs(high[j] - close[j - 1]), MathAbs(low[j] - close[j - 1])));
        double atr = (prevATR * (atrPeriod - 1) + trueRange) / atrPeriod;
        atrBuffer[j] = atr;
        prevATR = atr;
    }
    // Determine market sentiment based on ROC and ATR
    if (rocBuffer[rates_total - 1] > 0 && atrBuffer[rates_total - 1] > sensitivity)
    {
        PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrGreen);
    }
    else
    {
        PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrRed);
    }
    // Alert logic
    if (enableAlerts && rocBuffer[rates_total - 1] > 0 && atrBuffer[rates_total - 1] > sensitivity)
    {
        // Trigger alert (e.g., send notification)
        Alert("Up Trend Detected");
    }
   // return(rates_total);
//}
// Determine the color based on the condition
   if(condition==10)
     {
      // True condition (display green)
      backgroundColor = clrGreen;
      drawDashboard("Up Trend");
     }
   else
      if(condition==20)
        {
         // False condition (display red)
         backgroundColor = clrRed;
         drawDashboard("Down Trend");
        }
      else
        {
         backgroundColor = clrCyan;
         drawDashboard("");
        }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Function to draw the dashboard on the chart                       |
//+------------------------------------------------------------------+
void drawDashboard(string trendText)
  {
// Remove the existing dashboard if it exists
   if(ObjectFind("mainPanel") != -1)
     {
      ObjectDelete(0, "mainPanel");
     }
// Create the main dashboard panel
   ObjectCreate(0, "mainPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XDISTANCE, 350);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YDISTANCE, 80);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BGCOLOR, backgroundColor);
   ObjectSetInteger(0, "mainPanel", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BACK, true);
   ObjectCreate(0, "TrendText1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "TrendText1", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
   ObjectSetInteger(0, "TrendText1", OBJPROP_YDISTANCE, 40);  // Adjust Y position inside dashboard
   ObjectSetText("TrendText1", "Trend Meter", 10, "Arial Bold", clrYellow);
   ObjectSetInteger(0, "TrendText1", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
// Create text label inside the dashboard if trendText is not empty
   if(trendText != "")
     {
      ObjectCreate(0, "TrendText", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "TrendText", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
      ObjectSetInteger(0, "TrendText", OBJPROP_YDISTANCE, 120);  // Adjust Y position inside dashboard
      ObjectSetText("TrendText", trendText, 10, "Arial Bold", clrWhite);
      ObjectSetInteger(0, "TrendText", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
     }
  }
//+--------------------------------------------------------------
