//+------------------------------------------------------------------+
//|                                                 Dotted_lines.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property strict

// Define input parameters
input double PriceLevel = 1.2000; // The price level where the line will be drawn
input color LineColor = clrRed; // Color of the dotted line
input ENUM_LINE_STYLE LineStyle = STYLE_DOT; // Style of the line
input int LineWidth = 1; // Width of the line

// Indicator initialization function
int OnInit()
  {
   // Draw the horizontal line
   if (!ObjectCreate(0, "DottedLine", OBJ_HLINE, 0, 0, PriceLevel))
     {
      Print("Failed to create line!");
      return(INIT_FAILED);
     }
   ObjectSetInteger(0, "DottedLine", OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, "DottedLine", OBJPROP_STYLE, LineStyle);
   ObjectSetInteger(0, "DottedLine", OBJPROP_WIDTH, LineWidth);

   // Successful initialization
   return(INIT_SUCCEEDED);
  }

// Indicator deinitialization function
void OnDeinit(const int reason)
  {
   // Delete the line object when the indicator is removed
   ObjectDelete(0, "DottedLine");
  }

// Indicator calculation function
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
   // Nothing needs to be calculated for this indicator
   return(rates_total);
  }
//+------------------------------------------------------------------+
