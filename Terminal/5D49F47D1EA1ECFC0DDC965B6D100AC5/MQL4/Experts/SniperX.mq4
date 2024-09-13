//+------------------------------------------------------------------+
//|                                                      SniperX.mq4 |
//|                                   Copyright 2024,  Forex & Borsa |
//|                                      www.forexistituzionale.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,  Forex & Borsa"
#property link      "www.forexistituzionale.com/"
#property version   "1.00"
#property strict
input int BB_Period = 20;
input double BB_Deviation = 3.0;
input double VolatalityValue = 10;
input int SuperTrendPeriod = 14;
input int MomentumPeriod = 14;
input double lotSize = 1.0;
input double stopLoss = 50; // in pips
input double takeProfit = 100; // in pips
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialization code
   return(INIT_SUCCEEDED);
  }

//eur,usa,assian
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Deinitialization code
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsTradingHour())
     {
      // Get Bollinger Bands values
      double upperBand = iBands(NULL, 0, BB_Period, 3, 0, PRICE_CLOSE, MODE_UPPER, 0);
      double lowerBand = iBands(NULL, 0, BB_Period, 3, 0, PRICE_CLOSE, MODE_LOWER, 0);
      // Get Super Trend value (custom indicator)
      double superTrend = iCustom(NULL, 0, "Super Trend", SuperTrendPeriod, 3, 0, 0);
      // Get Momentum value
      double momentum = iMomentum(NULL, 0, MomentumPeriod, PRICE_CLOSE, 0);

      // Calculate Bollinger Band width as a measure of volatility
      double bandWidth = upperBand - lowerBand;

      // Set a volatility threshold (example value, adjust as needed)
      double volatilityThreshold = VolatalityValue * Point;

      if(bandWidth < volatilityThreshold)
        {
         // Define momentum thresholds
         double momentumThreshold = 100.0;

         // Get current price
         double price = Close[0];

         // Check for buy signal
         if(superTrend > price && price <= lowerBand && momentum > momentumThreshold)
           {
            // Place a buy order
            double order_ID = OrderSend(_Symbol,OP_BUY,lotSize,Ask,0,Ask-stopLoss*_Point,Ask+takeProfit*_Point,NULL,9999,0,clrGreen);
           }

         // Check for sell signal
         if(superTrend < price && price >= upperBand && momentum < momentumThreshold)
           {
            // Place a sell order
            double order_ID_sell = OrderSend(_Symbol,OP_SELL,lotSize,Bid,0,Bid+stopLoss*_Point,Bid-takeProfit*_Point,NULL,9999,0,clrRed);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Check if the current time is within trading hours                |
//+------------------------------------------------------------------+
bool IsTradingHour()
  {
   datetime currentTime = TimeCurrent();
   int hour = TimeHour(currentTime);
   int minute = TimeMinute(currentTime);

// Asian Session: 05:30 to 14:30 IST (00:00 to 09:00 GMT)
   if((hour == 5 && minute >= 30) || (hour > 5 && hour < 14) || (hour == 14 && minute <= 30))
      return(true);

// European Session: 12:30 to 21:30 IST (07:00 to 16:00 GMT)
   if((hour == 12 && minute >= 30) || (hour > 12 && hour < 21) || (hour == 21 && minute <= 30))
      return(true);

// USA Session: 18:30 to 03:30 IST (13:00 to 22:00 GMT)
   if((hour == 18 && minute >= 30) || (hour > 18) || (hour < 3) || (hour == 3 && minute <= 30))
      return(true);

// Outside trading hours
   return(false);
  }
//+------------------------------------------------------------------+
