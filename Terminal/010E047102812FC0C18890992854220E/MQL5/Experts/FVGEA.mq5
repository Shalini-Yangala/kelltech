//+------------------------------------------------------------------+
//|                                                        FVGEA.mq5 |
//|                                        Copyright 2024, Fx Empire |
//|                                        https://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Fx Empire"
#property link      "https://www.fxempire.com/"
#property version   "1.00"
#property indicator_chart_window
#define FVGPrefix "Fvg Rec"
#define clrUp clrLimeGreen
#define clrdn clrRed
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Calculate the total number of visible candles
   int VisibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   // Print("Total Visible bars : ",VisibleBars);
   for(int i = 0; i < VisibleBars; i++)
     {
      // Print("bars calculated for : ",i);
      double low0 = iLow(_Symbol, _Period, i);
      double high2 = iHigh(_Symbol, _Period, i + 2);
      double Gaplh = NormalizeDouble((low0 - high2) / _Point, _Digits);
      double high0 = iHigh(_Symbol, _Period, i);
      double low2 = iLow(_Symbol, _Period, i + 2);
      double Gaphl = NormalizeDouble((low2 - high0) / _Point, _Digits);
      bool FvgUp = low0 > high2;
      bool FvgDown = low2 > high0;
      if(FvgUp || FvgDown)
        {
         Print("Bar index with Fvg : ", i + 1);
         datetime time1 = iTime(_Symbol, _Period, i + 1);
         double price1 = FvgUp ? high2 : high0;
         datetime time2 = time1 + PeriodSeconds(_Period) * 10;
         double price2 = FvgUp ? low0 : low2;
         string Fvgname = FVGPrefix "(" + TimeToString(time1) + ")";
         color fvgclr = FvgUp ? clrUp : clrdn;
         Createrec(Fvgname, time1, price1, time2, price2, fvgclr);
        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // No specific deinitialization actions needed
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // No specific actions needed on each tick
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