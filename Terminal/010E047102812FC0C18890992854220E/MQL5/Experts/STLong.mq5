//+------------------------------------------------------------------+
//|                                                      STLong.mq5  |
//|                                              Copyright 2024, NA  |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA"
#property link      "https://www.yourcompany.com"
#property version   "1.00"

// Input parameters
input int EMA_Fast_Period = 50;
input int EMA_Slow_Period = 200;
input int CCI_Period = 14;
input double CCI_Threshold = 0;
input double CCI_Buy_Threshold_High = 100;
input double CCI_Sell_Threshold_Low = -100;
input double SL_Pips = 10;   // Stop loss in pips
input double TP_Pips = 110;  // Take profit in pips
input double Initial_Lot_Size = 5.0; // Initial lot size
input double AdjustLotSize;

// Global variables
double Lots = Initial_Lot_Size;
int Loss_Streak = 0;

double EMA_Fast, EMA_Slow;
int CCI_Value;

#include <Trade\Trade.mqh>

CTrade trade; // Trading class instance

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Expert Advisor initialized successfully.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("Expert Advisor deinitialized.");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check if the current symbol and period is suitable
   if(!CheckTimeframe())
      return;

// Calculate EMA values
   CalculateEMA();

// Calculate CCI value
   int cci_handle = iCCI(_Symbol, PERIOD_M5, CCI_Period, PRICE_TYPICAL);
   if(cci_handle == INVALID_HANDLE)
     {
      Print("Error creating CCI handle.");
      return;
     }

   double cci_buffer[];
   if(CopyBuffer(cci_handle, 0, 0, 1, cci_buffer) <= 0)
     {
      Print("Error copying CCI buffer.");
      return;
     }
   CCI_Value = (int)cci_buffer[0];

// Check for Buy Signal
   if(EMA_Fast > EMA_Slow && CCI_Value > CCI_Threshold && CCI_Value < CCI_Buy_Threshold_High)
     {
      Print("Buy Signal detected. Attempting to place order...");
      // Adjust lot size based on loss streak
      AdjustLotSize();
      PlaceOrder(ORDER_TYPE_BUY);
     }

// Check for Sell Signal
   if(EMA_Fast < EMA_Slow && CCI_Value <CCI_Threshold && CCI_Value > CCI_Sell_Threshold_Low)
     {
      Print("Sell Signal detected. Attempting to place order...");
      // Adjust lot size based on loss streak
      AdjustLotSize();
      PlaceOrder(ORDER_TYPE_SELL);
     }
  }

//+------------------------------------------------------------------+
//| Function to check if the current timeframe is 5 minutes          |
//+------------------------------------------------------------------+
bool CheckTimeframe()
  {
   if(Period() != PERIOD_M5)
     {
      Print("This EA works only on the 5-minute chart.");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Function to calculate EMA values                                 |
//+------------------------------------------------------------------+
bool CalculateEMA()
  {
   int ema_fast_handle = iMA(_Symbol, PERIOD_M5, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   int ema_slow_handle = iMA(_Symbol, PERIOD_M5, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);

   if(ema_fast_handle == INVALID_HANDLE || ema_slow_handle == INVALID_HANDLE)
     {
      Print("Error creating EMA handles.");
      return false;
     }

   double ema_fast_buffer[];
   double ema_slow_buffer[];

   if(CopyBuffer(ema_fast_handle, 0, 0, 1, ema_fast_buffer) <= 0 ||
      CopyBuffer(ema_slow_handle, 0, 0, 1, ema_slow_buffer) <= 0)
     {
      Print("Error copying EMA buffers.");
      return false;
     }

   EMA_Fast = ema_fast_buffer[0];
   EMA_Slow = ema_slow_buffer[0];

   return true;
  }

//+------------------------------------------------------------------+
//| Function to place buy or sell order                              |
//+------------------------------------------------------------------+
void PlaceOrder(int type)
  {
   MqlTradeRequest request;
   MqlTradeResult result;
   double price = 0, sl = 0, tp = 0;

// Determine price, stop loss, and take profit levels
   if(type == ORDER_TYPE_BUY)
     {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = price - SL_Pips * _Point;
      tp = price + TP_Pips * _Point;
     }
   else
      if(type == ORDER_TYPE_SELL)
        {
         price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         sl = price + SL_Pips * _Point;
         tp = price - TP_Pips * _Point;
        }

// Validate stop loss and take profit levels
   if(sl <= 0 || tp <= 0)
     {
      Print("Invalid SL or TP values. SL: ", sl, " TP: ", tp);
      return;
     }

// Fill the trade request structure
   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = Lots;
    request.type = (ENUM_ORDER_TYPE)type;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10; // Increase deviation to allow for price fluctuations
   request.magic = 0;
   request.comment = "StepMartingale EA";
   request.type_filling = ORDER_FILLING_IOC; // Adjust according to supported filling modes

// Send the trade request
   if(!OrderSend(request, result))
     {
      Print("Error placing order: ", result.retcode);
      Print("Request details - Action: ", request.action, ", Symbol: ", request.symbol, ", Volume: ", request.volume,
            ", Type: ", request.type, ", Price: ", request.price, ", SL: ", request.sl, ", TP: ", request.tp,
            ", Deviation: ", request.deviation, ", Magic: ", request.magic, ", Comment: ", request.comment);
     }
   else
     {
      Print("Order placed successfully: ", result.order);
      // Reset loss streak on a successful trade
      Loss_Streak = 0;
     }
  }


//+------------------------------------------------------------------+
//| Function to adjust lot size based on loss streak                 |
//+------------------------------------------------------------------+
void AdjustLotSize()
  {
   if(Loss_Streak >= 15)
      Lots = 15;  // Lot size set to 15 after 15 consecutive losses
   else
      if(Loss_Streak >= 10)
         Lots = 11;  // Lot size set to 11 after 10 consecutive losses
      else
         if(Loss_Streak >= 5)
            Lots = 8;   // Lot size set to 8 after 5 consecutive losses
         else
            Lots = Initial_Lot_Size; // Reset to initial lot size
  }
//+------------------------------------------------------------------+
