//+------------------------------------------------------------------+
//|                                 standard_deviation_indicator.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
// Define inputs
input int period = 14; // Period for standard deviation calculation
input double deviationMultiplier = 2.0; // Multiplier for standard deviation

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Calculate standard deviation
   double deviation = iStdDev(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, 0);
   double upperBand = iClose(NULL, 0, 0) + deviationMultiplier * deviation;
   double lowerBand = iClose(NULL, 0, 0) - deviationMultiplier * deviation;
   
   double mvg1 = iMA(NULL,0,15,0,MODE_EMA,PRICE_CLOSE,0);
   double mvg2 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,0);
   
   bool buy_condition=mvg1>mvg2;
   bool sell_condition=mvg1<mvg2;

// Check for buy condition
   if((Close[1] < lowerBand && Close[0] > lowerBand)&&(buy_condition))
     {
      // Place buy trade
      double buy_id = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 2, 0, 0, "Buy Signal", 0, 0, clrGreen);
      ObjectCreate(0, "Buy arrow", OBJ_ARROW_BUY, 0,Time[0],Low[0]);
      ObjectSetInteger(0,"Buy arrow", OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0, "Buy arrow",OBJPROP_COLOR,clrDodgerBlue);
     }

// Check for sell condition
   if((Close[1] > upperBand && Close[0] < upperBand)&&(sell_condition))
     {
      // Place sell trade
      double sell_id = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 2, 0, 0, "Sell Signal", 0, 0, clrRed);
      ObjectCreate(0, "Sell arrow", OBJ_ARROW_BUY, 0,Time[0],High[0]);
      ObjectSetInteger(0,"Sell arrow", OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0, "Sell arrow",OBJPROP_COLOR,clrRed);
     }
  }
//+------------------------------------------------------------------+