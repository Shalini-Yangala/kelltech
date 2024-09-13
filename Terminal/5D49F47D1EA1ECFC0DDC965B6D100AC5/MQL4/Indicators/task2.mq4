
//+------------------------------------------------------------------+
//|                                                        task2.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
input int condition=10;
color backgroundColor;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
// Draw the dashboard
//drawDashboardRight();
//---
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
//---
// Check your condition here (for example, a simple random condition)
//bool condition = 10;  // Randomly true or false

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
//+------------------------------------------------------------------+

