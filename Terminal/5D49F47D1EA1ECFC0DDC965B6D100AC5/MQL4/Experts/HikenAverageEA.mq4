//+------------------------------------------------------------------+
//|                                                 HikenAverageEA.mq4|
//|                                               Elite Forex Trades  |
//|                                     https://eliteforextrades.com  |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
//--- input parameters
input double Lots = 0.1;           // Lot size
input double StopLoss = 100;       // Stop Loss in pips
input double TakeProfit = 200;     // Take Profit in pips
input int Slippage = 3;            // Slippage in pips
input color BuyColor = Blue;       // Buy arrow color
input color SellColor = Red;       // Sell arrow color
//--- indicator buffers
double haOpenBuffer[];
double haCloseBuffer[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize indicator buffers
   ArraySetAsSeries(haOpenBuffer, true);
   ArraySetAsSeries(haCloseBuffer, true);
   // Set up indicator buffers
   SetIndexBuffer(0, haOpenBuffer);
   SetIndexBuffer(1, haCloseBuffer);
   // Setting the style for the indicator lines
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, clrRed);   // Heikin-Ashi Open as dotted line
   SetIndexLabel(0, "Heikin-Ashi Open");
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, clrBlue); // Heikin-Ashi Close as solid line
   SetIndexLabel(1, "Heikin-Ashi Close");
   // Set indicator properties
   IndicatorShortName("HikenAverage (Heikin-Ashi Open & Close Lines)");
   // Initialization done
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Calculate Heikin-Ashi values
   CalculateHeikinAshi();
   // Determine the current and previous Heikin-Ashi values
   double haOpenCurrent = haOpenBuffer[0];
   double haCloseCurrent = haCloseBuffer[0];
   double haOpenPrevious = haOpenBuffer[1];
   double haClosePrevious = haCloseBuffer[1];
   // Check if there's an existing order
   bool buyOrderExists = false;
   bool sellOrderExists = false;
   int totalOrders = OrdersTotal();
   for (int i = 0; i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderType() == OP_BUY) buyOrderExists = true;
         if (OrderType() == OP_SELL) sellOrderExists = true;
      }
   }
   // Trading logic: Buy if HA Close > HA Open, Sell if HA Close < HA Open
   if (haCloseCurrent > haOpenCurrent && !buyOrderExists)
   {
      int order_send_buy =OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, Ask - StopLoss * Point, Ask + TakeProfit * Point, "Buy Order", 0, 0, BuyColor);
   }
   else if (haCloseCurrent < haOpenCurrent && !sellOrderExists)
   {
      int order_send_sell = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, Bid + StopLoss * Point, Bid - TakeProfit * Point, "Sell Order", 0, 0, SellColor);
   }
}
//+------------------------------------------------------------------+
//| Calculate Heikin-Ashi values                                     |
//+------------------------------------------------------------------+
void CalculateHeikinAshi()
{
   int rates_total = Bars;
   if (rates_total < 2) return;
   // Ensure buffers are resized to match the number of bars
   ArrayResize(haOpenBuffer, rates_total);
   ArrayResize(haCloseBuffer, rates_total);
   // Calculate Heikin-Ashi values for all bars
   for (int i = rates_total - 1; i >= 0; i--)
   {
      double haClose = (Open[i] + High[i] + Low[i] + Close[i]) / 4;
      double haOpen;
      if (i == rates_total - 1)
         haOpen = (Open[i] + Close[i]) / 2; // Initial value
      else
         haOpen = (haOpenBuffer[i + 1] + haCloseBuffer[i + 1]) / 2;
      haOpenBuffer[i] = haOpen;
      haCloseBuffer[i] = haClose;
   }
}

//----------------------------------------------------------------------------