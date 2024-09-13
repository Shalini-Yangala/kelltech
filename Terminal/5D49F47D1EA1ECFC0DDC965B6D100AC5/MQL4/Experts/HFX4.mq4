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
input string   PairsToMonitor = "EURUSD,GBPUSD,USDJPY,USDCHF,USDCAD,AUDUSD,NZDUSD";
input int      UpdateInterval = 60; // Update every 60 seconds
input double   LotSize = 10.0;

// Global variables
string Pairs[];
int totalPairs;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(Pairs, 0);
   totalPairs = StringSplit(PairsToMonitor, ',', Pairs);
   
   // Create timer for updates
   EventSetTimer(UpdateInterval);
   
   // Draw the table headers
   DrawText("header_symbol", "Symbol", 10, 50, clrYellow);
   DrawText("header_strength", "Strength", 100, 50, clrYellow);
   DrawText("header_bid", "Bid", 200, 50, clrYellow);
   DrawText("header_ask", "Ask", 300, 50, clrYellow);
   DrawText("header_spread", "Spread", 400, 50, clrYellow);
   DrawText("header_chgm5", "CHG M5", 500, 50, clrYellow);
   DrawText("header_chgm15", "CHG M15", 600, 50, clrYellow);
   DrawText("header_chgh1", "CHG H1", 700, 50, clrYellow);
   DrawText("header_chgh4", "CHG H4", 800, 50, clrYellow);
   DrawText("header_status", "Status", 900, 50, clrYellow);
   DrawText("header_adr", "ADR", 1000, 50, clrYellow);
   DrawText("header_trend", "Trend", 1100, 50, clrYellow);
   DrawText("header_time", "Time", 1200, 50, clrYellow);
   
   // Create buttons
   CreateButtons();
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Destroy timer
   EventKillTimer();
   
   // Remove dashboard objects
   for(int i = 0; i < totalPairs; i++)
     {
      string name = "dashboard_" + Pairs[i];
      ObjectDelete(name + "_label");
      ObjectDelete(name + "_strength");
      ObjectDelete(name + "_bid");
      ObjectDelete(name + "_ask");
      ObjectDelete(name + "_spread");
      ObjectDelete(name + "_chgm5");
      ObjectDelete(name + "_chgm15");
      ObjectDelete(name + "_chgh1");
      ObjectDelete(name + "_chgh4");
      ObjectDelete(name + "_status");
      ObjectDelete(name + "_adr");
      ObjectDelete(name + "_trend");
      ObjectDelete(name + "_time");
     }
   
   // Remove headers
   ObjectDelete("header_symbol");
   ObjectDelete("header_strength");
   ObjectDelete("header_bid");
   ObjectDelete("header_ask");
   ObjectDelete("header_spread");
   ObjectDelete("header_chgm5");
   ObjectDelete("header_chgm15");
   ObjectDelete("header_chgh1");
   ObjectDelete("header_chgh4");
   ObjectDelete("header_status");
   ObjectDelete("header_adr");
   ObjectDelete("header_trend");
   ObjectDelete("header_time");
   
   // Delete buttons
   DeleteButtons();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Update dashboard on each tick
   UpdateDashboard();
   
   // Update buttons
   UpdateButtons();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   // Update dashboard on timer event
   UpdateDashboard();
  }
//+------------------------------------------------------------------+
//| Update dashboard                                                 |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   for(int i = 0; i < totalPairs; i++)
     {
      string symbol = Pairs[i];
      double bid = MarketInfo(symbol, MODE_BID);
      double ask = MarketInfo(symbol, MODE_ASK);
      double spread = (ask - bid) / MarketInfo(symbol, MODE_POINT);
      double chgm5 = iCustom(symbol, 0, "PriceChange", 5, 0, 0); // M5
      double chgm15 = iCustom(symbol, 0, "PriceChange", 15, 0, 0); // M15
      double chgh1 = iCustom(symbol, 0, "PriceChange", 60, 0, 0); // H1
      double chgh4 = iCustom(symbol, 0, "PriceChange", 240, 0, 0); // H4
      double adr = CalculateADR(symbol);
      string status = CalculateStatus(symbol); // Custom function to calculate BUY/SELL status
      string trend = CalculateTrend(symbol); // Custom function to calculate trend
      string time = TimeToStr(TimeCurrent(), TIME_MINUTES);
      string name = "dashboard_" + symbol;
      DrawText(name + "_label", symbol, 10, 70 + 20 * i, clrGreen);
      DrawText(name + "_strength", DoubleToString(CalculateStrength(symbol), 2), 100, 70 + 20 * i, clrGreen);
      DrawText(name + "_bid", DoubleToString(bid, 5), 200, 70 + 20 * i, clrGreen);
      DrawText(name + "_ask", DoubleToString(ask, 5), 300, 70 + 20 * i, clrGreen);
      DrawText(name + "_spread", DoubleToString(spread, 1), 400, 70 + 20 * i, clrGreen);
      DrawText(name + "_chgm5", DoubleToString(chgm5, 2), 500, 70 + 20 * i, clrGreen);
      DrawText(name + "_chgm15", DoubleToString(chgm15, 2), 600, 70 + 20 * i, clrGreen);
      DrawText(name + "_chgh1", DoubleToString(chgh1, 2), 700, 70 + 20 * i, clrGreen);
      DrawText(name + "_chgh4", DoubleToString(chgh4, 2), 800, 70 + 20 * i, clrGreen);
      DrawText(name + "_status", status, 900, 70 + 20 * i, clrGreen);
      DrawText(name + "_adr", DoubleToString(adr, 2) + "%", 1000, 70 + 20 * i, clrGreen);
      DrawText(name + "_trend", trend, 1100, 70 + 20 * i, clrGreen);
      DrawText(name + "_time", time, 1200, 70 + 20 * i, clrGreen);
     }
  }
//+------------------------------------------------------------------+
//| Draw text function                                               |
//+------------------------------------------------------------------+
void DrawText(string name, string text, int x, int y, color clr)
  {
   if(ObjectFind(0, name) == -1)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }
//+------------------------------------------------------------------+
//| Calculate ADR                                                    |
//+------------------------------------------------------------------+
double CalculateADR(string symbol)
  {
   double adr = 0;
   // Calculate ADR logic here
   return adr;
  }
//+------------------------------------------------------------------+
//| Calculate Strength                                               |
//+------------------------------------------------------------------+
double CalculateStrength(string symbol)
  {
   double strength = 0;
   // Calculate strength logic here
   return strength;
  }
//+------------------------------------------------------------------+
//| Calculate Status                                                 |
//+------------------------------------------------------------------+
string CalculateStatus(string symbol)
  {
   string status = "NEUTRAL";
   // Calculate BUY/SELL status logic here
   return status;
  }
//+------------------------------------------------------------------+
//| Calculate Trend                                                  |
//+------------------------------------------------------------------+
string CalculateTrend(string symbol)
  {
   string trend = "FLAT";
   // Calculate trend logic here
   return trend;
  }
//+------------------------------------------------------------------+
//| Create Buttons                                                   |
//+------------------------------------------------------------------+
void CreateButtons()
{
   // Create Buy Button
   ObjectCreate(0, "BuyButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BuyButton", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, 100);
   ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "Buy");
   ObjectSetInteger(0, "BuyButton", OBJPROP_COLOR, clrGreen);
   
   // Create Sell Button
   ObjectCreate(0, "SellButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "SellButton", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "SellButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "SellButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "SellButton", OBJPROP_XDISTANCE, 130);
   ObjectSetInteger(0, "SellButton", OBJPROP_YDISTANCE, 100);
   ObjectSetString(0, "SellButton", OBJPROP_TEXT, "Sell");
   ObjectSetInteger(0, "SellButton", OBJPROP_COLOR, clrRed);
   
   // Create Emergency Exit Button
   ObjectCreate(0, "ExitButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ExitButton", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "ExitButton", OBJPROP_XDISTANCE, 240);
   ObjectSetInteger(0, "ExitButton", OBJPROP_YDISTANCE, 100);
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
