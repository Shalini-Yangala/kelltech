
//+------------------------------------------------------------------+
//|                                       Trend Market Sentiment.mq4 |
//|                                       Copyright 2024, Individual |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Individual"
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrBlue
// Input parameters
input int roc_period = 14; // Period for ROC calculation
input int atr_period = 14; // Period for ATR calculation
input int atr_threshold = 0; //ATR threshold value
input int roc_threshold = 0; //ROC threshold value
input bool enableAlerts = true; // Enable/disable alerts
color backgroundColor;
// Indicator buffers
double trend_buffer[];
// Previous trend direction
int prevTrendDirection = 0;
bool alertRaised = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Indicator buffers mapping
   SetIndexBuffer(0, trend_buffer);
// Set up indicator labels
   IndicatorShortName("Trend Meter");
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
   for(int i = 0; i < rates_total; i++)
     {
      if(i >= roc_period)
        {
         double var1 = close[i - roc_period];
         if(var1 > 0)
           {
            // Calculate ROC
            double roc = (close[i] - var1) / var1 * 100.0;
            // Calculate ATR
            double atr = iATR(NULL, 0, atr_period, i);
            /*double var1 = close[i - roc_period];
            if(var1 > 0)
              {
               // Calculate ROC
               double roc = (close[i] - close[i - roc_period]) / var1 * 100.0;
               // Calculate ATR
               double atr = iATR(NULL, 0, atr_period, i);*/
            // Determine trend direction based on ROC and ATR
            int trend_direction = 0; // 0: Neutral, 1: Up, -1: Down
            if(roc > roc_threshold && atr > atr_threshold)
              {
               trend_direction = 1; // Up trend
              }
            else
               if(roc < roc_threshold && atr > atr_threshold)
                 {
                  trend_direction = -1; // Down trend
                 }
            // Set trend buffer value based on trend direction
            if(trend_direction == 1)
              {
               trend_buffer[i] = High[i]; // High value for green color
               backgroundColor = clrGreen;
               drawDashboard("Up Trend");
              }
            else
               if(trend_direction == -1)
                 {
                  trend_buffer[i] = Low[i]; // Low value for red color
                  backgroundColor = clrRed;
                  drawDashboard("Down Trend");
                 }
               else
                 {
                  trend_buffer[i] = Close[i]; // Close value for neutral color
                  backgroundColor = clrRed;
                  drawDashboard("Down Trend");
                 }
            // Raise one-time alert if trend direction changes
            if(enableAlerts && trend_direction != prevTrendDirection && !alertRaised)
              {
               if(trend_direction == 1)
                 {
                  Alert("Upward trend detected!");
                 }
               else
                  if(trend_direction == -1)
                    {
                     Alert("Downward trend detected!");
                    }
               prevTrendDirection = trend_direction;
               alertRaised = true; // Set alert flag
              }
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
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
// Create the Title of the dashboard
   ObjectCreate(0, "TrendText1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "TrendText1", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
   ObjectSetInteger(0, "TrendText1", OBJPROP_YDISTANCE, 40);  // Adjust Y position inside dashboard
   ObjectSetText("TrendText1", "Trend Meter", 10, "Arial Bold", clrGreen);
   ObjectSetInteger(0, "TrendText1", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
// Create text label inside the dashboard
   if(trendText != "")
     {
      ObjectCreate(0, "TrendText", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "TrendText", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
      ObjectSetInteger(0, "TrendText", OBJPROP_YDISTANCE, 120);  // Adjust Y position inside dashboard
      ObjectSetText("TrendText", trendText, 10, "Arial Bold", clrWhite);
      ObjectSetInteger(0, "TrendText", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
     }
  }
//+------------------------------------------------------------------+











