//+------------------------------------------------------------------+
//|                                           dashboard_creation.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
// Global variables for support and resistance values
double r1, r2, s1, s2;
double sell_price, buy_price;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Calculate pivot points, support, and resistance levels
    double pivot = (High[1] + Low[1] + Close[1]) / 3;
    r1 = 2 * pivot - Low[1];
    r2 = pivot + (High[1] - Low[1]);
    s1 = 2 * pivot - High[1];
    s2 = pivot - (High[1] - Low[1]);
    // Draw support and resistance lines
    drawHorizontalLine("ResistanceLine1", r1, clrRed);
    drawHorizontalLine("ResistanceLine2", r2, clrYellow);
    drawHorizontalLine("SupportLine1", s1, clrBlue);
    drawHorizontalLine("SupportLine2", s2, clrPink);
    // Draw the dashboard
    drawDashboardRight();
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
    // Clear the dashboard value
    ObjectDelete(0, "mainPanel");
    // Redraw the dashboard
    drawDashboardRight();
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
    // Return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Function to draw a horizontal line                                |
//+------------------------------------------------------------------+
void drawHorizontalLine(string lineName, double price, color lineColor)
{
    ObjectCreate(0, lineName, OBJ_HLINE, 0, Time[0], price);
    ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
}
//+------------------------------------------------------------------+
//| Function to draw the dashboard on the chart                       |
//+------------------------------------------------------------------+
void drawDashboardRight()
{
   // Create a main dashboard panel
    /*ObjectCreate(0, "mainPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "mainPanel", OBJPROP_XSIZE, 420);
    ObjectSetInteger(0, "mainPanel", OBJPROP_YSIZE, 100);
    ObjectSetInteger(0, "mainPanel", OBJPROP_XDISTANCE,30);
    ObjectSetInteger(0, "mainPanel", OBJPROP_YDISTANCE, 30);
    ObjectSetInteger(0, "mainPanel", OBJPROP_BGCOLOR, clrYellow);
    ObjectSetInteger(0,"mainPanel",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, "mainPanel", OBJPROP_BACK, true);*/
    
 //-----Panel-1 BG
   ObjectCreate(0, "rightPanelBG1", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_XSIZE, 200);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_YSIZE,80);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_XDISTANCE,440);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_BGCOLOR, clrLightCyan);
   ObjectSetInteger(0,"rightPanelBG1",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "rightPanelBG1", OBJPROP_BACK, true);
    // Add text labels to the main panel
    ObjectCreate(0, "ResistanceText", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "ResistanceText", OBJPROP_XDISTANCE, 430);
    ObjectSetInteger(0, "ResistanceText", OBJPROP_YDISTANCE, 50);
    ObjectSetText("ResistanceText", "Resistance Line1: ", 8, NULL, clrBlack);
    ObjectSetInteger(0,"ResistanceText",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
//--------------
    ObjectCreate(0, "ResistanceText1", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "ResistanceText1", OBJPROP_XDISTANCE, 430);
    ObjectSetInteger(0, "ResistanceText1", OBJPROP_YDISTANCE, 65);
    ObjectSetText("ResistanceText1", "Resistance Line2: ", 8, NULL, clrBlack);
    ObjectSetInteger(0,"ResistanceText1",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
    //-------------
    ObjectCreate(0, "SupportText", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "SupportText", OBJPROP_XDISTANCE, 430);
    ObjectSetInteger(0, "SupportText", OBJPROP_YDISTANCE, 85);
    ObjectSetText("SupportText", "Support Line1: ", 8, NULL, clrBlack);
    ObjectSetInteger(0,"SupportText",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
//-----------
    ObjectCreate(0, "SupportText1", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "SupportText1", OBJPROP_XDISTANCE,430 );
    ObjectSetInteger(0, "SupportText1", OBJPROP_YDISTANCE,100);
    ObjectSetText("SupportText1", "Support Line2: ", 8, NULL, clrBlack);
    ObjectSetInteger(0,"SupportText1",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
//-----------------------------------------------+
//-----------------------------------------------+
   //---Panel2 BG
   ObjectCreate(0, "rightPanelBG2", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_XSIZE, 200);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_YSIZE, 80);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_XDISTANCE,240);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_BGCOLOR,clrLightCyan);
   ObjectSetInteger(0,"rightPanelBG2",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "rightPanelBG2", OBJPROP_BACK, true);
//-------------------------------------
    ObjectCreate(0, "buyText", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "buyText", OBJPROP_XDISTANCE, 200);
    ObjectSetInteger(0, "buyText", OBJPROP_YDISTANCE, 50);
    ObjectSetText("buyText", "Buy Price: ", 8, NULL, clrBlack);
    ObjectSetInteger(0,"buyText",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
//-------------------------------------
    ObjectCreate(0, "sellText", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "sellText", OBJPROP_XDISTANCE, 200);
    ObjectSetInteger(0, "sellText", OBJPROP_YDISTANCE, 80);
    ObjectSetText("sellText", "Sell Price: ", 8, NULL, clrBlack);
   ObjectSetInteger(0,"sellText",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
}