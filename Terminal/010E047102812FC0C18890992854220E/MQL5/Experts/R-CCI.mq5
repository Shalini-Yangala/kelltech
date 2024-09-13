//+------------------------------------------------------------------+
//|                                                        R-CCI.mq5 |
//|                                               Copyright 2024, NA |
//|                                                              N/A  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA"
#property link      "N/A"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- indicator plots
// Plot1 for RSI
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
// Plot2 for CCI
#property indicator_label2  "CCI"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

// Indicator buffers
double rsiBuffer[];
double cciBuffer[];

// Global variables to track the last trade
datetime lastTradeTime = 0;
int lastTradeType = -1; // -1 for no trade, 0 for buy, 1 for sell

// Indicator handles
int RSI_Handle;
int CCI_Handle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization of indicator buffers
   SetIndexBuffer(0, rsiBuffer);
   SetIndexBuffer(1, cciBuffer);

   // Initialization of indicators
   RSI_Handle = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   CCI_Handle = iCCI(_Symbol, _Period, 20, PRICE_TYPICAL);
   if(RSI_Handle == INVALID_HANDLE || CCI_Handle == INVALID_HANDLE)
     {
      Print("Error creating indicator handles");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Release indicator handles
   IndicatorRelease(RSI_Handle);
   IndicatorRelease(CCI_Handle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Declare variables
   double rsi[], cci[];
   int rsiCount, cciCount;

   // Get the RSI values
   rsiCount = CopyBuffer(RSI_Handle, 0, 0, 2, rsi);
   // Get the CCI values
   cciCount = CopyBuffer(CCI_Handle, 0, 0, 2, cci);

   // Check if we have received valid data
   if(rsiCount < 2 || cciCount < 2)
     {
      Print("Error retrieving indicator data");
      return;
     }

   // Get the latest RSI and CCI values
   double currentRSI = rsi[0];
   double currentCCI = cci[0];

   // Get current Bid and Ask prices
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // Ensure minimum time interval between trades
   if (TimeCurrent() - lastTradeTime < 60) return; // 1-minute delay between trades

   // Check for buy condition
   if(currentRSI > 30 && currentCCI > currentRSI && lastTradeType != 0)
     {
      // Place a buy order
      if(PlaceTrade(ORDER_TYPE_BUY, ask))
        {
         // Draw buy arrow
         DrawArrow(true, bid);
         Print("Buy order placed at: ", bid);
         lastTradeTime = TimeCurrent();
         lastTradeType = 0;
        }
     }

   // Check for sell condition
   if(currentRSI < 70 && currentCCI < currentRSI && lastTradeType != 1)
     {
      // Place a sell order
      if(PlaceTrade(ORDER_TYPE_SELL, bid))
        {
         // Draw sell arrow
         DrawArrow(false, ask);
         Print("Sell order placed at: ", ask);
         lastTradeTime = TimeCurrent();
         lastTradeType = 1;
        }
     }
  }

//+------------------------------------------------------------------+
//| Function to place trade                                          |
//+------------------------------------------------------------------+
bool PlaceTrade(int type, double price)
  {
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = 0.1;
   request.type = (ENUM_ORDER_TYPE)type;
   request.price = price;
   request.deviation = 3;
   request.magic = 123456;

   // Try ORDER_FILLING_FOK first
   request.type_filling = ORDER_FILLING_FOK;
   if(!OrderSend(request, result))
     {
      // If ORDER_FILLING_FOK fails, try ORDER_FILLING_IOC
      request.type_filling = ORDER_FILLING_IOC;
      if(!OrderSend(request, result))
        {
         Print("OrderSend failed with error #", GetLastError());
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Function to draw arrow                                           |
//+------------------------------------------------------------------+
void DrawArrow(bool isBuy, double price)
  {
   string name = isBuy ? "BuyArrow" + IntegerToString(TimeCurrent()) : "SellArrow" + IntegerToString(TimeCurrent());
   color clr = isBuy ? clrGreen : clrRed;
   int arrowCode = isBuy ? 233 : 234; // Up and down arrow codes
   ObjectCreate(0, name, OBJ_ARROW, 0, TimeCurrent(), price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowCode);
  }
