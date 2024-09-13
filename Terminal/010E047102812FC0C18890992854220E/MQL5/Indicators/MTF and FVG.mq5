//+------------------------------------------------------------------+
//|                                                MTF_SR_FVG.mq5    |
//|              Multi-Timeframe Support/Resistance and FVGs        |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#define FVGPrefix "FvgRec"
#define clrUp clrLimeGreen
#define clrDown clrRed

//--- Input parameters for Support/Resistance
input ENUM_TIMEFRAMES Timeframe1 = PERIOD_H4;  // First higher timeframe
input ENUM_TIMEFRAMES Timeframe2 = PERIOD_D1;  // Second higher timeframe
input int            LookBackPeriod = 20;      // Number of bars to look back
input color          ResistanceColor = clrRed; // Resistance line color
input color          SupportColor = clrBlue;   // Support line color
input int            LineStyle = STYLE_SOLID;  // Line style
input int            LineWidth = 2;            // Line width

//--- Indicator buffers (if needed for further enhancements)
double SupportBuffer[];
double ResistanceBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize buffers if needed
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
   // Calculate MTF Support/Resistance levels
   double SupportLevel1 = iLow(NULL, Timeframe1, iLowest(NULL, Timeframe1, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel1 = iHigh(NULL, Timeframe1, iHighest(NULL, Timeframe1, MODE_HIGH, LookBackPeriod, 0));
   double SupportLevel2 = iLow(NULL, Timeframe2, iLowest(NULL, Timeframe2, MODE_LOW, LookBackPeriod, 0));
   double ResistanceLevel2 = iHigh(NULL, Timeframe2, iHighest(NULL, Timeframe2, MODE_HIGH, LookBackPeriod, 0));

   // Draw MTF Support/Resistance levels on the chart
   DrawLevel("Support1", SupportLevel1, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance1", ResistanceLevel1, ResistanceColor, LineStyle, LineWidth);
   DrawLevel("Support2", SupportLevel2, SupportColor, LineStyle, LineWidth);
   DrawLevel("Resistance2", ResistanceLevel2, ResistanceColor, LineStyle, LineWidth);

   // Calculate and Draw Relevant Fair Value Gaps (FVGs)
   int start = MathMax(2, prev_calculated - 1); // Ensure that at least two bars are available
   int limit = rates_total - 3; // Adjusted to avoid array out of range

   for(int i = start; i < limit; i++)
     {
      double low0 = low[i];
      double high2 = high[i + 2];
      double high0 = high[i];
      double low2 = low[i + 2];

      bool FvgUp = low0 > high2;   // Upward FVG (bullish)
      bool FvgDown = low2 < high0; // Downward FVG (bearish)

      if(FvgUp || FvgDown)
        {
         datetime time1 = time[i + 1];
         double price1 = FvgUp ? high2 : high0;
         datetime time2 = time[i + 2];
         double price2 = FvgUp ? low0 : low2;
         string Fvgname = FVGPrefix + "(" + TimeToString(time1) + ")";
         color fvgclr = FvgUp ? clrUp : clrDown;

         // Only draw the most relevant FVGs (close to current price and near S/R levels)
         if(IsRelevantFVG(price1, price2, SupportLevel1, ResistanceLevel1, SupportLevel2, ResistanceLevel2))
           {
            if(!IsDuplicateFVG(Fvgname))
              {
               CreateRectangle(Fvgname, time1, price1, time2, price2, fvgclr);
              }
           }
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Function to check if an FVG is relevant based on proximity       |
//| to Support/Resistance levels and current price                   |
//+------------------------------------------------------------------+
bool IsRelevantFVG(double price1, double price2, double Support1, double Resistance1, double Support2, double Resistance2)
  {
   double currentPrice = iClose(NULL, 0, 0);
   // Consider FVGs within a certain range of the current price and support/resistance levels
   double relevanceThreshold = 0.005; // 0.5% range, adjustable

   if((MathAbs(currentPrice - price1) / currentPrice < relevanceThreshold || 
       MathAbs(currentPrice - price2) / currentPrice < relevanceThreshold) &&
      ((price1 > Support1 && price1 < Resistance1) || (price2 > Support2 && price2 < Resistance2)))
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Function to check if a similar FVG already exists                |
//+------------------------------------------------------------------+
bool IsDuplicateFVG(string Fvgname)
  {
   for(int i = ObjectsTotal(OBJ_RECTANGLE); i >= 0; i--)
     {
      string name = ObjectName(i, OBJ_RECTANGLE, 0);
      if(StringFind(name, FVGPrefix) != -1)
        {
         if(name == Fvgname)
           {
            return true; // Duplicate found
           }
        }
     }
   return false; // No duplicate found
  }

//+------------------------------------------------------------------+
//| Function to draw lines on the chart                              |
//+------------------------------------------------------------------+
void DrawLevel(string name, double price, color clr, int style, int width)
  {
   // Check if the line already exists
   if(ObjectFind(0, name) == -1)
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

//+------------------------------------------------------------------+
//| Function to create a rectangle object                            |
//+------------------------------------------------------------------+
void CreateRectangle(string Objname, datetime time1, double price1, datetime time2, double price2, color clr)
  {
   if(ObjectFind(0, Objname) < 0)
     {
      ObjectCreate(0, Objname, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, Objname, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, Objname, OBJPROP_FILL, true);
      ObjectSetInteger(0, Objname, OBJPROP_BORDER_TYPE, BORDER_FLAT); // Set border type
     }
  }
//+------------------------------------------------------------------+