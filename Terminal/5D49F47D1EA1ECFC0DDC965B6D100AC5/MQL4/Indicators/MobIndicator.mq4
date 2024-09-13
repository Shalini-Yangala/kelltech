//+------------------------------------------------------------------+
//|                                                 MobIndicator.mq4 |
//|                                                   Walker Capital |
//|                                      http://walkercapital.com.au |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://walkercapital.com.au"
#property version   "1.00"
#property strict
#property indicator_separate_window
// Indicator parameters
input int BullsPeriod = 13;      // Period for Bulls Power
input int BearsPeriod = 20;      // Period for Bears Power
input int MomPeriod = 14;        // Period for Momentum
input bool AlertsEnabled = true; // Enable alerts
datetime lastAlertTime = 0;
double momBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(momBuffer,true);
   IndicatorBuffers(1);
   SetIndexBuffer(0,momBuffer);
// Set styles and colors for the buffers
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrBlue); // Momentum line in yellow
   SetIndexLabel(0, "Momentum");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   int limit = rates_total - prev_calculated;

   if(limit > 1)
      limit = rates_total - 1;

   for(int j=0; j<rates_total; j++)
     {
      momBuffer[j] = iMomentum(NULL,0,MomPeriod,PRICE_CLOSE,j);
     }
   for(int i = 0; i < limit; i++)
     {
      // Calculate Bulls Power
      double bulls1 = iBullsPower(NULL, 0, BullsPeriod, 0, i);
      double bulls_pre1 = iBullsPower(NULL, 0, BullsPeriod, 0, i+1);
      // Calculate Bears Power
      double bears1 = iBearsPower(NULL, 0, BearsPeriod, 0, i);
      double bears_pre1 = iBearsPower(NULL, 0, BearsPeriod, 0, i+1);
      // Calculate Momentum
      double momentum = iMomentum(NULL, 0, MomPeriod, PRICE_CLOSE, i);
      double momentum_pre = iMomentum(NULL, 0, MomPeriod, PRICE_CLOSE, i+1);
      // Generate unique arrow names based on time and buffer indices
      string buyArrowName = "BuyArrow_" + TimeToString(time[i], TIME_MINUTES) + "_" + IntegerToString(i);
      string sellArrowName = "SellArrow_" + TimeToString(time[i], TIME_MINUTES) + "_" + IntegerToString(i);
      // Generate Buy Signal
      if(bulls1 > 0 && bears1 < 0 && momentum > 100 &&
         !(bulls_pre1 > 0 && bears_pre1 < 0 && momentum_pre > 100)) // Ensure condition not met on previous candle
        {
         if(ObjectFind(0, buyArrowName) != 0)   // Ensure we do not recreate the same arrow
           {
            ObjectCreate(0, buyArrowName, OBJ_ARROW, 0, time[i], low[i] - 10 * Point);
            ObjectSetInteger(0, buyArrowName, OBJPROP_ARROWCODE, 233);
            ObjectSetInteger(0, buyArrowName, OBJPROP_COLOR, clrBlue);
            if(AlertsEnabled && Time[0] != lastAlertTime)
              {
               Alert("Buy Signal: ", TimeToString(time[i]), " Bulls: ", bulls1, " Bears: ", bears1, " Momentum: ", momentum);
               lastAlertTime = Time[0];
              }
           }
        }
      else
        {
         if(ObjectFind(0, buyArrowName) == 0)   // Remove the arrow if conditions are no longer met
            ObjectDelete(0, buyArrowName);
        }
      // Generate Sell Signal
      if(bears1 > 0 && bulls1 < 0 && momentum < 100 &&
         !(bears_pre1 > 0 && bulls_pre1 < 0 && momentum_pre < 100)) // Ensure condition not met on previous candle
        {
         if(ObjectFind(0, sellArrowName) != 0)   // Ensure we do not recreate the same arrow
           {
            ObjectCreate(0, sellArrowName, OBJ_ARROW, 0, time[i], high[i] + 10 * Point);
            ObjectSetInteger(0, sellArrowName, OBJPROP_ARROWCODE, 234);
            ObjectSetInteger(0, sellArrowName, OBJPROP_COLOR, clrRed);
            if(AlertsEnabled && Time[0] != lastAlertTime)
              {
               Alert("Sell Signal: ", TimeToString(time[i]), " Bears: ", bears1, " Bulls: ", bulls1, " Momentum: ", momentum);
               lastAlertTime = Time[0];
              }
           }
        }
      else
        {
         if(ObjectFind(0, sellArrowName) == 0)   // Remove the arrow if conditions are no longer met
            ObjectDelete(0, sellArrowName);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
