//+------------------------------------------------------------------+
//|                                           dashboard_leftside.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   drawDashboardLeft();
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
   // Calculate pivot points, support, and resistance levels
   double pivot = (high[1] + low[1] + close[1]) / 3;
   double r1 = 2 * pivot - low[1];
   double s1 = 2 * pivot - high[1];
   double r2 = pivot + (high[1] - low[1]);
   double s2 = pivot - (high[1] - low[1]);
   double support_price = r1;
   double resistance_price = s1;
   double buy_price = 0.0;
   double sell_price = 0.0;
   //Draw the Support and Resistance lines on the chart
  drawHorizontalLine("ResistanceLine",r1, clrRed); // Support 1
  drawHorizontalLine("SupportLine",s1, clrGreen); // Resistance 1
   for(int i = 1; i < rates_total; i++)
     {
      // Determine buy and sell conditions
      bool sellCondition = close[i] > r1 && close[i - 1] <= r1; // Close crosses above R1
      bool buyCondition = close[i] < s1 && close[i - 1] >= s1; // Close crosses below S1
      // Draw arrows on the chart
      if(buyCondition)
        {
         buy_price = low[i];
         ObjectCreate(0, "Buy_Arrow", OBJ_ARROW, 0, time[i], low[i] - Point);
         ObjectSetInteger(0, "Buy_Arrow", OBJPROP_ARROWCODE, 233);
         ObjectSetInteger(0, "Buy_Arrow", OBJPROP_COLOR, clrDodgerBlue);
         ObjectSetInteger(0, "Buy_Arrow", OBJPROP_WIDTH, 1);
        }
      if(sellCondition)
        {
         sell_price = high[i];
         ObjectCreate(0, "Sell_Arrow", OBJ_ARROW, 0, time[i], high[i] + Point);
         ObjectSetInteger(0, "Sell_Arrow", OBJPROP_ARROWCODE, 234);
         ObjectSetInteger( 0, "Sell_Arrow", OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, "Sell_Arrow", OBJPROP_WIDTH, 1);
        }
     }
   // Update dashboard values
   ObjectSetText("resistanceValue", DoubleToStr(support_price, 4), 8, NULL, clrBlack);
   ObjectSetText("supportValue", DoubleToStr(resistance_price, 4), 8, NULL, clrBlack);
   ObjectSetText("buyValue", DoubleToStr(buy_price, 4), 8, NULL, clrBlack);
   ObjectSetText("sellValue", DoubleToStr(sell_price, 4), 8, NULL, clrBlack);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void drawHorizontalLine(string line1,double price, int line_color)
  {
   ObjectCreate(0, line1, OBJ_HLINE, 0,  Time[0], price, Time[1], price);
   ObjectSetInteger(0, line1, OBJPROP_COLOR, line_color);
  }
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
void drawDashboardLeft()
  {
//static//
//---Main Panel
   ObjectCreate(0, "mainPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XSIZE, 420);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YSIZE,100);
   ObjectSetInteger(0, "mainPanel", OBJPROP_XDISTANCE,30);
   ObjectSetInteger(0, "mainPanel", OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BGCOLOR, clrYellow);
   ObjectSetInteger(0, "mainPanel", OBJPROP_BACK, true);
//---Panel-1 BG
   ObjectCreate(0, "leftPanelBG1", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_XSIZE, 210);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_YSIZE,80);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_XDISTANCE,40);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_BGCOLOR, clrLightCyan);
   ObjectSetInteger(0, "leftPanelBG1", OBJPROP_BACK, true);
//---SupportText
   ObjectCreate(0, "supportText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "supportText", OBJPROP_XDISTANCE, 60);
   ObjectSetInteger(0, "supportText", OBJPROP_YDISTANCE, 50);
   ObjectSetText("supportText", "Support Price : ", 8, NULL, clrBlack);
//---ResistanceText
   ObjectCreate(0, "resistanceText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "resistanceText", OBJPROP_XDISTANCE,60);
   ObjectSetInteger(0, "resistanceText", OBJPROP_YDISTANCE,90);
   ObjectSetText("resistanceText", "Resistance Price : ", 8, NULL, clrBlack);
//---Panel2 BG
   ObjectCreate(0, "leftPanelBG2", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_XSIZE, 200);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_YSIZE, 80);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_XDISTANCE,240);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_BGCOLOR,clrLightCyan);
   ObjectSetInteger(0, "leftPanelBG2", OBJPROP_BACK, true);
//---BuyText
   ObjectCreate(0, "buyText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "buyText", OBJPROP_XDISTANCE,265);
   ObjectSetInteger(0, "buyText", OBJPROP_YDISTANCE,50);
   ObjectSetText("buyText", "Buy Price :", 8, NULL, clrBlack);
//---SellText
   ObjectCreate(0, "sellText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "sellText", OBJPROP_XDISTANCE,265);
   ObjectSetInteger(0, "sellText", OBJPROP_YDISTANCE,90);
   ObjectSetText("sellText", "Sell Price :", 8, NULL, clrBlack);
//Dynamic
//---BuyValue
   ObjectCreate(0, "buyValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "buyValue", OBJPROP_XDISTANCE,350);
   ObjectSetInteger(0, "buyValue", OBJPROP_YDISTANCE,50);
//---SellValue
   ObjectCreate(0, "sellValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "sellValue", OBJPROP_XDISTANCE,350);
   ObjectSetInteger(0, "sellValue", OBJPROP_YDISTANCE,90);
//---BalValue
   ObjectCreate(0, "supportValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "supportValue", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "supportValue", OBJPROP_XDISTANCE,165);
   ObjectSetInteger(0, "supportValue", OBJPROP_YDISTANCE,50);
//---EquityValue
   ObjectCreate(0, "resistanceValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "resistanceValue", OBJPROP_XDISTANCE,175);
   ObjectSetInteger(0, "resistanceValue", OBJPROP_YDISTANCE,90);
  }
//+------------------------------------------------------------------+