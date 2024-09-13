//+------------------------------------------------------------------+
//|                                                        FVGEA.mq5 |
//|                                        Copyright 2024, Fx Empire |
//|                                        https://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Fx Empire"
#property link      "https://www.fxempire.com/"
#property version   "1.01"
#property indicator_chart_window
#define FVGPrefix "Fvg Rec"
#define clrUp clrLimeGreen
#define clrdn clrRed
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // No specific initialization actions needed
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
   // Calculate the total number of bars to evaluate
   int start = MathMax(2, prev_calculated - 1); // Ensure that at least two bars are available
   int limit = rates_total - 3; // Adjusted to avoid array out of range

   for(int i = start; i < limit; i++)
     {
      double low0 = low[i];
      double high2 = high[i + 2];
      double high0 = high[i];
      double low2 = low[i + 2];

      bool FvgUp = low0 > high2;
      bool FvgDown = low2 > high0;

      if(FvgUp || FvgDown)
        {
         datetime time1 = time[i + 1];
         double price1 = FvgUp ? high2 : high0;
         datetime time2 = time[i + 1] + PeriodSeconds(_Period);
         double price2 = FvgUp ? low0 : low2;
         string Fvgname = FVGPrefix + "(" + TimeToString(time1) + ")";
         color fvgclr = FvgUp ? clrUp : clrdn;

         Createrec(Fvgname, time1, price1, time2, price2, fvgclr);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Function to create a rectangle object                            |
//+------------------------------------------------------------------+
void Createrec(string Objname, datetime time1, double price1, datetime time2, double price2, color clr)
  {
   if(ObjectFind(0, Objname) < 0)
     {
      ObjectCreate(0, Objname, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, Objname, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, Objname, OBJPROP_FILL, true);
      ObjectSetInteger(0, Objname, OBJPROP_BACK, false);
     }
  }
//+------------------------------------------------------------------+
