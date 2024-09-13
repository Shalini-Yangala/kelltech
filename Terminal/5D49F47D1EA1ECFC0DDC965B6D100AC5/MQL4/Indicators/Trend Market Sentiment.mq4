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

// Indicator buffers
double trend_buffer[];
datetime lastAlertTime;

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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Clean up the objects when the indicator is removed from the chart
   ObjectDelete(0, "mainPanel");
   ObjectDelete(0, "TrendText1");
   ObjectDelete(0, "TrendText");
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
   for(int i=0; i<rates_total; i++)
     {
      double var1 = (i + roc_period < rates_total) ? close[i + roc_period] : 0.0;
      // Initialize trend direction
      int trend_direction = 0;

      // Calculate ATR for the latest candle
      double atr = iATR(NULL, 0, atr_period, i);

      if(var1>0)
        {
         // Calculate ROC for the latest candle
         double roc = (close[i] - var1) / var1 * 100.0;

         // Determine trend direction based on ROC and ATR
         if(roc > roc_threshold && atr > atr_threshold && Time[0] != lastAlertTime)
           {
            // Up trend
            trend_direction = 1;
            trend_buffer[i] = high[i]; // Store the high value for drawing purposes
            drawDashboard("Up Trend", clrGreen); // Draw dashboard for uptrend

            // Raise alert if enabled and not already alerted
            if(enableAlerts)
              {
               Alert("Upward trend detected!");
               lastAlertTime = Time[0];
              }
           }
         else
            if(roc < roc_threshold && atr > atr_threshold && Time[0] != lastAlertTime)
              {
               // Down trend
               trend_direction = -1;
               trend_buffer[i] = low[i]; // Store the low value for drawing purposes
               drawDashboard("Down Trend", clrRed); // Draw dashboard for downtrend

               // Raise alert if enabled and not already alerted
               if(enableAlerts)
                 {
                  Alert("Downward trend detected!");
                  lastAlertTime = Time[0];
                 }
              }
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Function to draw the dashboard on the chart                      |
//+------------------------------------------------------------------+
void drawDashboard(string trendText, color clr1)
  {
// Create the main dashboard panel
   ObjectCreate(0, "mainPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XDISTANCE, 350);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YDISTANCE, 80);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BGCOLOR, clr1);
   ObjectSetInteger(0, "mainPanel", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BACK, true);

// Create the Title of the dashboard
   ObjectCreate(0, "TrendText1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "TrendText1", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
   ObjectSetInteger(0, "TrendText1", OBJPROP_YDISTANCE, 40);  // Adjust Y position inside dashboard
   ObjectSetText("TrendText1", "Trend Meter", 10, "Arial Bold", clrGreen);
   ObjectSetInteger(0, "TrendText1", OBJPROP_CORNER, CORNER_RIGHT_UPPER);

// Create text label inside the dashboard
   ObjectCreate(0, "TrendText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "TrendText", OBJPROP_XDISTANCE, 280); // Adjust X position inside dashboard
   ObjectSetInteger(0, "TrendText", OBJPROP_YDISTANCE, 120);  // Adjust Y position inside dashboard
   ObjectSetText("TrendText", trendText, 10, "Arial Bold", clrWhite);
   ObjectSetInteger(0, "TrendText", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
  }
//+------------------------------------------------------------------+
