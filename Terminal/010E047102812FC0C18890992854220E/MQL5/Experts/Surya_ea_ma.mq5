//+------------------------------------------------------------------+
//|                                                       Klight.mq5 |
//|                                    Copyright 2024, Tibra Capital |
//|                                            http://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Tibra Capital"
#property link      "http://www.tibra.com/"
#property version   "1.00"
#include <Trade\Trade.mqh> // Include trade library
CTrade trade;
// Input parameters
input double Lots = 0.1;
input int SMA_Period = 21;
input int Chaikin_Period1 = 3;
input int Chaikin_Period2 = 10;
input int Chaikin_Period3 = 12;
input int Chaikin_Period4 = 36;
input double MartingaleMultiplier = 1.75;
// Indicator handles
int handle_SMA, handle_Chaikin1, handle_Chaikin2;
// Indicator buffers
double Buffer_SMA[], Buffer_Chaikin1[], Buffer_Chaikin2[];
// Variables to track last trade time
datetime lastAlertTime = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Create indicators
   handle_SMA = iMA(_Symbol, _Period, SMA_Period, 0, MODE_SMA, PRICE_CLOSE);
   handle_Chaikin1 = iChaikin(_Symbol, _Period, Chaikin_Period1, Chaikin_Period2, MODE_SMA, VOLUME_TICK);
   handle_Chaikin2 = iChaikin(_Symbol, _Period, Chaikin_Period3, Chaikin_Period4, MODE_SMA, VOLUME_TICK);
// Check if handles are valid
   if(handle_SMA == INVALID_HANDLE || handle_Chaikin1 == INVALID_HANDLE || handle_Chaikin2 == INVALID_HANDLE)
     {
      Print("Failed to create indicators");
      return INIT_FAILED;
     }
// Set up indicator buffers
   SetIndexBuffer(0, Buffer_SMA, INDICATOR_DATA);
   SetIndexBuffer(1, Buffer_Chaikin1, INDICATOR_DATA);
   SetIndexBuffer(2, Buffer_Chaikin2, INDICATOR_DATA);
   ChartIndicatorAdd(0, 0, handle_SMA);
   ChartIndicatorAdd(0, 1, handle_Chaikin1);
   ChartIndicatorAdd(0, 2, handle_Chaikin2);
//lastTradeTime = 0; // Initialize last trade time
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Retrieve indicator values
   if(CopyBuffer(handle_SMA, 0, 0, 3, Buffer_SMA) <= 0 ||
      CopyBuffer(handle_Chaikin1, 0, 0, 3, Buffer_Chaikin1) <= 0 ||
      CopyBuffer(handle_Chaikin2, 0, 0, 3, Buffer_Chaikin2) <= 0)
     {
      Print("Failed to retrieve indicator data");
      return;
     }
   double smaValue = Buffer_SMA[1];
   double chaikin1Current = Buffer_Chaikin1[0];
   double chaikin1Previous = Buffer_Chaikin1[1];
   double chaikin2Current = Buffer_Chaikin2[0];
   double chaikin2Previous = Buffer_Chaikin2[1];
   datetime currentTime = TimeCurrent();
// Check for buy signal
   if(chaikin1Previous < chaikin2Previous && chaikin1Current > chaikin2Current && iClose(_Symbol, PERIOD_CURRENT, 0) > smaValue)
     {
      if((iTime(_Symbol,PERIOD_CURRENT,0) != lastAlertTime))
        {
         OpenBuy();
         string buyObjectName = "BuySignalArrow_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
         if(!ObjectCreate(0, buyObjectName, OBJ_ARROW, 0, TimeCurrent(), iLow(_Symbol, PERIOD_CURRENT, 0) - 10 * _Point))
            Print("Failed to create buy arrow");
         ObjectSetInteger(0, buyObjectName, OBJPROP_COLOR, clrBlue);
         ObjectSetInteger(0, buyObjectName, OBJPROP_ARROWCODE, 233);
         lastAlertTime = iTime(_Symbol,PERIOD_CURRENT,0);
        }
     }
// Check for sell signal
   if(chaikin1Previous > chaikin2Previous && chaikin1Current < chaikin2Current && iClose(_Symbol, PERIOD_CURRENT, 0) < smaValue)
     {
      if((iTime(_Symbol,PERIOD_CURRENT,0) != lastAlertTime))
        {
         OpenSell();
         string sellObjectName = "SellSignalArrow_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
         if(!ObjectCreate(0, sellObjectName, OBJ_ARROW, 0, TimeCurrent(), iHigh(_Symbol, PERIOD_CURRENT, 0) + 10 * _Point))
            Print("Failed to create sell arrow");
         ObjectSetInteger(0, sellObjectName, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, sellObjectName, OBJPROP_ARROWCODE, 234);
         lastAlertTime = iTime(_Symbol,PERIOD_CURRENT,0);
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to open a buy order                                     |
//+------------------------------------------------------------------+
void OpenBuy()
  {
   if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return;
   double lotSize = CalculateLotSize();
   trade.Buy(lotSize);
  }
//+------------------------------------------------------------------+
//| Function to open a sell order                                    |
//+------------------------------------------------------------------+
void OpenSell()
  {
   if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      return;
   double lotSize = CalculateLotSize();
   trade.Sell(lotSize);
  }
//+------------------------------------------------------------------+
//| Function to calculate lot size with martingale                   |
//+------------------------------------------------------------------+
double CalculateLotSize()
  {
   double lotSize = Lots;
   int lossCount = 0;
   HistorySelect(0, TimeCurrent());
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
        {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
           {
            long type = HistoryDealGetInteger(ticket, DEAL_ENTRY);
            double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            if((type == DEAL_ENTRY_OUT || type == DEAL_ENTRY_INOUT) && profit < 0)
              {
               lossCount++;
              }
            else
              {
               break;
              }
           }
        }
     }
   lotSize *= MathPow(MartingaleMultiplier, lossCount);
   return (lotSize);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
