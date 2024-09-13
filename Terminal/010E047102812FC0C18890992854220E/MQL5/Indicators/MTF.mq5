//+------------------------------------------------------------------+
//|                                                    MTF_SR.mq5    |
//|                        Custom Indicator Template                  |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

//--- Input parameters
input ENUM_TIMEFRAMES Timeframe1 = PERIOD_H4; // First higher timeframe
input ENUM_TIMEFRAMES Timeframe2 = PERIOD_D1; // Second higher timeframe
input int            LookBackPeriod = 20;      // Number of bars to look back
input color          ResistanceColor = clrRed; // Resistance line color
input color          SupportColor = clrBlue;   // Support line color
input int            LineStyle = STYLE_SOLID;  // Line style
input int            LineWidth = 2;            // Line width

//--- Indicator buffers
double SupportBuffer[];
double ResistanceBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator initialization
   SetIndexBuffer(0, SupportBuffer);
   SetIndexBuffer(1, ResistanceBuffer);
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
   // Get support and resistance levels from the specified higher timeframes
   double SupportLevel1 = iLow(NULL, Timeframe1, iLowest(NULL, Timeframe1, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel1 = iHigh(NULL, Timeframe1, iHighest(NULL, Timeframe1, MODE_HIGH, LookBackPeriod, 0));
   double SupportLevel2 = iLow(NULL, Timeframe2, iLowest(NULL, Timeframe2, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel2 = iHigh(NULL, Timeframe2, iHighest(NULL, Timeframe2, MODE_HIGH, LookBackPeriod, 0));

   // Draw the lines on the chart
   DrawLevel("Support1", SupportLevel1, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance1", ResistanceLevel1, ResistanceColor, LineStyle, LineWidth);
   DrawLevel("Support2", SupportLevel2, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance2", ResistanceLevel2, ResistanceColor, LineStyle, LineWidth);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Function to draw lines on the chart                              |
//+------------------------------------------------------------------+
void DrawLevel(string name, double price, color clr, int style, int width)
  {
   // Check if the line already exists
   if(ObjectFind(0, name) != 0)
     {
      // Create a new line
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
     }
   else
     {
      // Update the existing line
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
     }
  }

