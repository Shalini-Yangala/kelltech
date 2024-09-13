//+------------------------------------------------------------------+
//|                                             DoubleTopBottom.mq4  |
//|                                                              N/A |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "N/A"
#property link      "N/A"
#property version   "1.00"
#property strict

input int LookbackPeriod = 100; // Period to look back for patterns
input double BreakoutPips = 10; // Number of pips for a breakout

// Function declarations for pattern detection and other utility functions
bool DetectDoubleTopPattern(int &top1, int &top2, int &bottom);
bool DetectDoubleBottomPattern(int &bottom1, int &bottom2, int &top);
void DrawDoubleTopOnChart(int top1, int top2, int bottom);
void DrawDoubleBottomOnChart(int bottom1, int bottom2, int top);
void FindSwingPoints(int period, int &highs[], int &lows[]);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialization code
   Print("Double Top and Bottom pattern detection initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Deinitialization code
   Print("Double Top and Bottom pattern detection deinitialized.");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check for double top and double bottom patterns
   int top1, top2, bottom1, bottom2, bottom, top;
   if(DetectDoubleTopPattern(top1, top2, bottom))
     {
      Print("Double Top Pattern Detected");
      DrawDoubleTopOnChart(top1, top2, bottom);
     }
   if(DetectDoubleBottomPattern(bottom1, bottom2, top))
     {
      Print("Double Bottom Pattern Detected");
      DrawDoubleBottomOnChart(bottom1, bottom2, top);
     }
  }

//+------------------------------------------------------------------+
//| Function to detect Double Top pattern                            |
//+------------------------------------------------------------------+
bool DetectDoubleTopPattern(int &top1, int &top2, int &bottom)
  {
   int swingHighs[], swingLows[];

// Find swing highs and lows
   FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

// Ensure we have enough points
   if(ArraySize(swingHighs) < 2 || ArraySize(swingLows) < 1)
      return false;

// Check for Double Top pattern
   for(int i = 1; i < ArraySize(swingHighs); i++)
     {
      for(int j = i + 1; j < ArraySize(swingHighs); j++)
        {
         if(High[swingHighs[i]] == High[swingHighs[j]])
           {
            for(int k = 0; k < ArraySize(swingLows); k++)
              {
               if(Low[swingLows[k]] < High[swingHighs[i]])
                 {
                  top1 = swingHighs[i];
                  top2 = swingHighs[j];
                  bottom = swingLows[k];
                  return true;
                 }
              }
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Function to detect Double Bottom pattern                         |
//+------------------------------------------------------------------+
bool DetectDoubleBottomPattern(int &bottom1, int &bottom2, int &top)
  {
   int swingHighs[], swingLows[];

// Find swing highs and lows
   FindSwingPoints(LookbackPeriod, swingHighs, swingLows);

// Ensure we have enough points
   if(ArraySize(swingLows) < 2 || ArraySize(swingHighs) < 1)
      return false;

// Check for Double Bottom pattern
   for(int i = 1; i < ArraySize(swingLows); i++)
     {
      for(int j = i + 1; j < ArraySize(swingLows); j++)
        {
         if(Low[swingLows[i]] == Low[swingLows[j]])
           {
            for(int k = 0; k < ArraySize(swingHighs); k++)
              {
               if(High[swingHighs[k]] > Low[swingLows[i]])
                 {
                  bottom1 = swingLows[i];
                  bottom2 = swingLows[j];
                  top = swingHighs[k];
                  return true;
                 }
              }
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Function to draw Double Top pattern                              |
//+------------------------------------------------------------------+
void DrawDoubleTopOnChart(int top1, int top2, int bottom)
  {
// Draw lines to form the double top pattern
   ObjectCreate(0, "DoubleTop1", OBJ_TREND, 0, Time[top1], High[top1], Time[bottom], Low[bottom]);
   ObjectSetInteger(0, "DoubleTop1", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "DoubleTop1", OBJPROP_WIDTH, 2);

   ObjectCreate(0, "DoubleTop2", OBJ_TREND, 0, Time[top2], High[top2], Time[bottom], Low[bottom]);
   ObjectSetInteger(0, "DoubleTop2", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "DoubleTop2", OBJPROP_WIDTH, 2);

// Draw support line
   ObjectCreate(0, "SupportLine", OBJ_TREND, 0, Time[bottom], Low[bottom], Time[top1], Low[bottom]);
   ObjectSetInteger(0, "SupportLine", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "SupportLine", OBJPROP_WIDTH, 2);
  }

//+------------------------------------------------------------------+
//| Function to draw Double Bottom pattern                           |
//+------------------------------------------------------------------+
void DrawDoubleBottomOnChart(int bottom1, int bottom2, int top)
  {
// Draw lines to form the double bottom pattern
   ObjectCreate(0, "DoubleBottom1", OBJ_TREND, 0, Time[bottom1], Low[bottom1], Time[top], High[top]);
   ObjectSetInteger(0, "DoubleBottom1", OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, "DoubleBottom1", OBJPROP_WIDTH, 2);

   ObjectCreate(0, "DoubleBottom2 ", OBJ_TREND, 0, Time[bottom2], Low[bottom2], Time[top], High[top]);
   ObjectSetInteger(0, "DoubleBottom2", OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, "DoubleBottom2", OBJPROP_WIDTH, 2);

// Draw resistance line
   ObjectCreate(0, "ResistanceLine", OBJ_TREND, 0, Time[top], High[top], Time[bottom1], High[top]);
   ObjectSetInteger(0, "ResistanceLine", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "ResistanceLine", OBJPROP_WIDTH, 2);
  }

//+------------------------------------------------------------------+
//| Function to find swing points                                    |
//+------------------------------------------------------------------+
void FindSwingPoints(int period, int &highs[], int &lows[])
  {
   ArrayResize(highs, 0);
   ArrayResize(lows, 0);

   for(int i = period; i >= 1; i--)
     {
      if(High[i] > High[i + 1] && High[i] > High[i - 1])
        {
         ArrayResize(highs, ArraySize(highs) + 1);
         highs[ArraySize(highs) - 1] = i;
        }
      if(Low[i] < Low[i + 1] && Low[i] < Low[i - 1])
        {
         ArrayResize(lows, ArraySize(lows) + 1);
         lows[ArraySize(lows) - 1] = i;
        }
     }
  }


//+------------------------------------------------------------------+


