//+------------------------------------------------------------------+
//|                                                       TrailV.mq4 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict

// Input parameters
extern double TrailingStart = 20;  // Distance to start trailing (pips)
extern double TrailingGap = 15;    // Trailing distance from market price (pips)
extern bool UseVirtualTrailing = true; // Toggle between classic and virtual trailing

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization code
   Print("EA initialized with ClassicTrailing: ", !UseVirtualTrailing);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup code
   Print("EA deinitialized.");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Loop through all open orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         int orderType = OrderType();
         double orderOpenPrice = OrderOpenPrice();
         double orderStopLoss = OrderStopLoss();
         double marketPrice = (orderType == OP_BUY) ? Ask : Bid;
         double currentTrailingStop = (orderType == OP_BUY)
                                      ? marketPrice - TrailingGap * Point
                                      : marketPrice + TrailingGap * Point;

         // Ensure TrailingStart and TrailingGap are valid
         if(TrailingStart <= 0 || TrailingGap <= 0)
           {
            Print("Invalid TrailingStart or TrailingGap values.");
            continue;
           }

         // Determine if trailing should start
         bool shouldStartTrailing = (orderType == OP_BUY
                                     && marketPrice - orderOpenPrice >= TrailingStart * Point)
                                    || (orderType == OP_SELL
                                        && orderOpenPrice - marketPrice >= TrailingStart * Point);

         if(shouldStartTrailing)
           {
            // Classic trailing
            if(!UseVirtualTrailing)
              {
               if((orderType == OP_BUY && currentTrailingStop > orderStopLoss)
                  || (orderType == OP_SELL && currentTrailingStop < orderStopLoss))
                 {
                  if(!OrderModify(OrderTicket(), orderOpenPrice, currentTrailingStop,
                                  OrderTakeProfit(), 0, clrNONE))
                    {
                     Print("OrderModify failed: ", GetLastError());
                    }
                 }
              }
            // Virtual trailing
            else
              {
               if((orderType == OP_BUY && marketPrice <= currentTrailingStop)
                  || (orderType == OP_SELL && marketPrice >= currentTrailingStop))
                 {
                  if(!OrderClose(OrderTicket(), OrderLots(), marketPrice,
                                 3, clrNONE))
                    {
                     Print("OrderClose failed: ", GetLastError());
                    }
                 }
              }

            // Optional: Display trades and modifications on the chart
            // Create or update arrows and lines
            string arrowName = "Arrow" + IntegerToString(OrderTicket());
            if(ObjectFind(0, arrowName) < 0) // If the arrow object doesn't exist
              {
               int arrowCode = (orderType == OP_BUY) ? SYMBOL_ARROWUP : SYMBOL_ARROWDOWN;
               color arrowColor = (orderType == OP_BUY) ? clrGreen : clrRed;
               ObjectCreate(0, arrowName, OBJ_ARROW, 0, OrderOpenTime(), OrderOpenPrice());
               ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, arrowCode);
               ObjectSetInteger(0, arrowName, OBJPROP_COLOR, arrowColor);
               ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
              }

            string lineName = "TrailingLine" + IntegerToString(OrderTicket());
            if(ObjectFind(0, lineName) < 0) // If the line object doesn't exist
              {
               ObjectCreate(0, lineName, OBJ_HLINE, 0, Time[0], currentTrailingStop);
               ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrYellow);
               ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);
              }
            else
              {
               ObjectSetDouble(0, lineName, OBJPROP_PRICE1, currentTrailingStop);
              }
           }
        }
      else
        {
         Print("Failed to select order. Error code: ", GetLastError());
        }
     }
  }
