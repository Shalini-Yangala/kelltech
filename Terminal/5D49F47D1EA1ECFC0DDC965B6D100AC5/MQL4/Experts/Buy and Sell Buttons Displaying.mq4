
/*

//+------------------------------------------------------------------+
//|                                                         HFX4.mq4 |
//|                                                               NA |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "NA"
#property link      "N/A"
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 10; // Default lot size
input string Symbol1 = "EURUSD";
input string Symbol2 = "GBPUSD";
input string Symbol3 = "USDJPY";
input int MA_Period = 14;
input int RSI_Period = 14;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create dashboard objects
   CreateDashboard();
   // Event handling
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete dashboard objects
   DeleteDashboard();
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateDashboard();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateDashboard();
}
//+------------------------------------------------------------------+
//| Create Dashboard                                                 |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   // Create background
   ObjectCreate(0, "DashboardBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_XSIZE, 300);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_YSIZE, 200);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_XDISTANCE, 500);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_YDISTANCE, 50);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "DashboardBG", OBJPROP_BACK, true);
   // Create Buy Button
   ObjectCreate(0, "BuyButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BuyButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, 50);
   ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "Buy");
   ObjectSetInteger(0, "BuyButton", OBJPROP_COLOR, clrGreen);
   // Create Sell Button
   ObjectCreate(0, "SellButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "SellButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "SellButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "SellButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "SellButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "SellButton", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "SellButton", OBJPROP_TEXT, "Sell");
   ObjectSetInteger(0, "SellButton", OBJPROP_COLOR, clrRed);
   // Create Emergency Exit Button
   ObjectCreate(0, "ExitButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ExitButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YDISTANCE, 130);
   ObjectSetString(0, "ExitButton", OBJPROP_TEXT, "Exit All");
   ObjectSetInteger(0, "ExitButton", OBJPROP_COLOR, clrBlue);
}
//+------------------------------------------------------------------+
//| Update Dashboard                                                 |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   // Check for button clicks
   if (ObjectGetInteger(0, "BuyButton", OBJPROP_STATE) == 1)
   {
      ExecuteTrade(OP_BUY);
      ObjectSetInteger(0, "BuyButton", OBJPROP_STATE, 0);
   }
   if (ObjectGetInteger(0, "SellButton", OBJPROP_STATE) == 1)
   {
      ExecuteTrade(OP_SELL);
      ObjectSetInteger(0, "SellButton", OBJPROP_STATE, 0);
   }
   if (ObjectGetInteger(0, "ExitButton", OBJPROP_STATE) == 1)
   {
      CloseAllTrades();
      ObjectSetInteger(0, "ExitButton", OBJPROP_STATE, 0);
   }
   // Update price and indicator values on the dashboard
   // Here you can add the code to fetch and display current prices, indicators, P/L, etc.
}
//+------------------------------------------------------------------+
//| Execute Trade                                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(int tradeType)
{
   int ticket = OrderSend(Symbol(), tradeType, LotSize, Ask, 3, 0, 0, "ForexDashboard Trade", 0, 0, clrBlue);
   if (ticket < 0)
   {
      Print("Error opening order: ", GetLastError());
   }
}
//+------------------------------------------------------------------+
//| Close All Trades                                                 |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol())
         {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrRed);
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Delete Dashboard                                                 |
//+------------------------------------------------------------------+
void DeleteDashboard()
{
   ObjectDelete(0, "DashboardBG");
   ObjectDelete(0, "BuyButton");
   ObjectDelete(0, "SellButton");
   ObjectDelete(0, "ExitButton");
}


*/
//==========================================================================================================

//+------------------------------------------------------------------+
//|                                                         HFX4.mq4 |
//|                                                               NA |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "NA"
#property link      "N/A"
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 10; // Default lot size

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create buttons
   CreateButtons();
   // Event handling
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete buttons
   DeleteButtons();
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateButtons();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateButtons();
}
//+------------------------------------------------------------------+
//| Create Buttons                                                   |
//+------------------------------------------------------------------+
void CreateButtons()
{
   // Create Buy Button
   ObjectCreate(0, "BuyButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BuyButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, 50);
   ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "Buy");
   ObjectSetInteger(0, "BuyButton", OBJPROP_COLOR, clrGreen);
   // Create Sell Button
   ObjectCreate(0, "SellButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "SellButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "SellButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "SellButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "SellButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "SellButton", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "SellButton", OBJPROP_TEXT, "Sell");
   ObjectSetInteger(0, "SellButton", OBJPROP_COLOR, clrRed);
   // Create Emergency Exit Button
   ObjectCreate(0, "ExitButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ExitButton", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XDISTANCE, 110);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YDISTANCE, 130);
   ObjectSetString(0, "ExitButton", OBJPROP_TEXT, "Exit All");
   ObjectSetInteger(0, "ExitButton", OBJPROP_COLOR, clrBlue);
}
//+------------------------------------------------------------------+
//| Update Buttons                                                   |
//+------------------------------------------------------------------+
void UpdateButtons()
{
   // Check for button clicks
   if (ObjectGetInteger(0, "BuyButton", OBJPROP_STATE) == 1)
   {
      ExecuteTrade(OP_BUY);
      ObjectSetInteger(0, "BuyButton", OBJPROP_STATE, 0);
   }
   if (ObjectGetInteger(0, "SellButton", OBJPROP_STATE) == 1)
   {
      ExecuteTrade(OP_SELL);
      ObjectSetInteger(0, "SellButton", OBJPROP_STATE, 0);
   }
   if (ObjectGetInteger(0, "ExitButton", OBJPROP_STATE) == 1)
   {
      CloseAllTrades();
      ObjectSetInteger(0, "ExitButton", OBJPROP_STATE, 0);
   }
}
//+------------------------------------------------------------------+
//| Execute Trade                                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(int tradeType)
{
   int ticket = OrderSend(Symbol(), tradeType, LotSize, Ask, 3, 0, 0, "ForexDashboard Trade", 0, 0, clrBlue);
   if (ticket < 0)
   {
      Print("Error opening order: ", GetLastError());
   }
}
//+------------------------------------------------------------------+
//| Close All Trades                                                 |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol())
         {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrRed);
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Delete Buttons                                                   |
//+------------------------------------------------------------------+
void DeleteButtons()
{
   ObjectDelete(0, "BuyButton");
   ObjectDelete(0, "SellButton");
   ObjectDelete(0, "ExitButton");
}
