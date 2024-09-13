//+------------------------------------------------------------------+
//|                                                     GoldCore.mq5 |
//|                                               Copyright 2024, NA |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA"
#property link      "N/A"
#property version   "1.00"
#include <Trade\Trade.mqh>
input double Lots=0.1;          // Lot size
input int StopLoss=100;         // Stop Loss in points
input int TakeProfit=200;       // Take Profit in points
input int EMA1Period=50;
input int EMA2Period=100;
input int EMA3Period=200;
input int CCI_Period=14;
input int Momentum_Period=14;

//--- input parameters
input int CCIThreshold1 = -100;
input int CCIThreshold2 = 100;
input int MOMThreshold = 100;
// Create trade object
CTrade trade;

int bars;

int EURUSDCCIValue, EURUSDMomentumValue, EURUSDEMAValue1, EURUSDEMAValue2;
int GBPUSDCCIValue, GBPUSDMomentumValue, GBPUSDEMAValue1, GBPUSDEMAValue2;
int AUDUSDCCIValue, AUDUSDMomentumValue, AUDUSDEMAValue1, AUDUSDEMAValue2;
int USDCADCCIValue, USDCADMomentumValue, USDCADEMAValue1, USDCADEMAValue2;
int USDJPYCCIValue, USDJPYMomentumValue, USDJPYEMAValue1, USDJPYEMAValue2;
int USDCHFCCIValue, USDCHFMomentumValue, USDCHFEMAValue1, USDCHFEMAValue2;
int NZDUSDCCIValue, NZDUSDMomentumValue, NZDUSDEMAValue1, NZDUSDEMAValue2;

//--- Arrays for indicator values
double EURUSDCCIBuffer[], EURUSDMomentumBuffer[], EURUSDEMABuffer1[], EURUSDEMABuffer2[];
double GBPUSDCCIBuffer[], GBPUSDMomentumBuffer[], GBPUSDEMABuffer1[], GBPUSDEMABuffer2[];
double AUDUSDCCIBuffer[], AUDUSDMomentumBuffer[], AUDUSDEMABuffer1[], AUDUSDEMABuffer2[];
double USDCADCCIBuffer[], USDCADMomentumBuffer[], USDCADEMABuffer1[], USDCADEMABuffer2[];
double USDJPYCCIBuffer[], USDJPYMomentumBuffer[], USDJPYEMABuffer1[], USDJPYEMABuffer2[];
double USDCHFCCIBuffer[], USDCHFMomentumBuffer[], USDCHFEMABuffer1[], USDCHFEMABuffer2[];
double NZDUSDCCIBuffer[], NZDUSDMomentumBuffer[], NZDUSDEMABuffer1[], NZDUSDEMABuffer2[];

// Buffers for indicators
double ema50_buffer[];
double ema100_buffer[];
double ema200_buffer[];
double cci_buffer[];
double momentum_buffer[];
bool CalculateIndicators()
  {
// EMA handles
   int ema50_handle = iMA(_Symbol, PERIOD_H1, EMA1Period, 0, MODE_EMA, PRICE_CLOSE);
   int ema100_handle = iMA(_Symbol, PERIOD_H1, EMA2Period, 0, MODE_EMA, PRICE_CLOSE);
   int ema200_handle = iMA(_Symbol, PERIOD_H1, EMA3Period, 0, MODE_EMA, PRICE_CLOSE);
// CCI handle
   int cci_handle = iCCI(_Symbol, PERIOD_H1, CCI_Period, PRICE_CLOSE);
// Momentum handle
   int momentum_handle = iMomentum(_Symbol, PERIOD_H1, Momentum_Period, PRICE_CLOSE);
// Check for valid handles
   if(ema50_handle == INVALID_HANDLE || ema100_handle == INVALID_HANDLE || ema200_handle == INVALID_HANDLE ||
      cci_handle == INVALID_HANDLE || momentum_handle == INVALID_HANDLE)
     {
      Print("Error creating indicator handles.");
      return false;
     }
// Copy indicator buffers
   if(CopyBuffer(ema50_handle, 0, 0, 1, ema50_buffer) <= 0 ||
      CopyBuffer(ema100_handle, 0, 0, 1, ema100_buffer) <= 0 ||
      CopyBuffer(ema200_handle, 0, 0, 1, ema200_buffer) <= 0 ||
      CopyBuffer(cci_handle, 0, 0, 1, cci_buffer) <= 0 ||
      CopyBuffer(momentum_handle, 0, 0, 1, momentum_buffer) <= 0)
     {
      Print("Error copying indicator buffers.");
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("GoldCore EA initialized");
//--- Initialize indicators
   EURUSDCCIValue = iCCI("EURUSD", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   EURUSDMomentumValue = iMomentum("EURUSD", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   EURUSDEMAValue1 = iMA("EURUSD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   EURUSDEMAValue2 = iMA("EURUSD", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);

//--- Initialize arrays as series
   ArraySetAsSeries(EURUSDCCIBuffer, true);
   ArraySetAsSeries(EURUSDMomentumBuffer, true);
   ArraySetAsSeries(EURUSDEMABuffer1, true);
   ArraySetAsSeries(EURUSDEMABuffer2, true);


//--- Initialize indicators
   GBPUSDCCIValue = iCCI("GBPUSD", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   GBPUSDMomentumValue = iMomentum("GBPUSD", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   GBPUSDEMAValue1 = iMA("GBPUSD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   GBPUSDEMAValue2 = iMA("GBPUSD", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);

//--- Initialize arrays as series
   ArraySetAsSeries(GBPUSDCCIBuffer, true);
   ArraySetAsSeries(GBPUSDMomentumBuffer, true);
   ArraySetAsSeries(GBPUSDEMABuffer1, true);
   ArraySetAsSeries(GBPUSDEMABuffer2, true);




//--- Initialize indicators
   AUDUSDCCIValue = iCCI("AUDUSD", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   AUDUSDMomentumValue = iMomentum("AUDUSD", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   AUDUSDEMAValue1 = iMA("AUDUSD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   AUDUSDEMAValue2 = iMA("AUDUSD", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);
//--- Initialize arrays as series
   ArraySetAsSeries(AUDUSDCCIBuffer, true);
   ArraySetAsSeries(AUDUSDMomentumBuffer, true);
   ArraySetAsSeries(AUDUSDEMABuffer1, true);
   ArraySetAsSeries(AUDUSDEMABuffer2, true);





//--- Initialize indicators
   USDCADCCIValue = iCCI("USDCAD", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   USDCADMomentumValue = iMomentum("USDCAD", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   USDCADEMAValue1 = iMA("USDCAD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   USDCADEMAValue2 = iMA("USDCAD", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);

//--- Initialize arrays as series
   ArraySetAsSeries(USDCADCCIBuffer, true);
   ArraySetAsSeries(USDCADMomentumBuffer, true);
   ArraySetAsSeries(USDCADEMABuffer1, true);
   ArraySetAsSeries(USDCADEMABuffer2, true);




//--- Initialize indicators
   USDJPYCCIValue = iCCI("USDJPY", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   USDJPYMomentumValue = iMomentum("USDJPY", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   USDJPYEMAValue1 = iMA("USDJPY", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   USDJPYEMAValue2 = iMA("USDJPY", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);
//--- Initialize arrays as series
   ArraySetAsSeries(USDJPYCCIBuffer, true);
   ArraySetAsSeries(USDJPYMomentumBuffer, true);
   ArraySetAsSeries(USDJPYEMABuffer1, true);
   ArraySetAsSeries(USDJPYEMABuffer2, true);




//--- Initialize indicators
   USDCHFCCIValue = iCCI("USDCHF", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   USDCHFMomentumValue = iMomentum("USDCHF", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   USDCHFEMAValue1 = iMA("USDCHF", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   USDCHFEMAValue2 = iMA("USDCHF", PERIOD_CURRENT, EMA2Period, 0, MODE_SMA, PRICE_CLOSE);
//--- Initialize arrays as series
   ArraySetAsSeries(USDCHFCCIBuffer, true);
   ArraySetAsSeries(USDCHFMomentumBuffer, true);
   ArraySetAsSeries(USDCHFEMABuffer1, true);
   ArraySetAsSeries(USDCHFEMABuffer2, true);




//--- Initialize indicators
   NZDUSDCCIValue = iCCI("NZDUSD", PERIOD_CURRENT, CCI_Period, PRICE_CLOSE);
   NZDUSDMomentumValue = iMomentum("NZDUSD", PERIOD_CURRENT, Momentum_Period, PRICE_CLOSE);
   NZDUSDEMAValue1 = iMA("NZDUSD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
   NZDUSDEMAValue2 = iMA("NZDUSD", PERIOD_CURRENT, EMA3Period, 0, MODE_SMA, PRICE_CLOSE);
//--- Initialize arrays as series
   ArraySetAsSeries(NZDUSDCCIBuffer, true);
   ArraySetAsSeries(NZDUSDMomentumBuffer, true);
   ArraySetAsSeries(NZDUSDEMABuffer1, true);
   ArraySetAsSeries(NZDUSDEMABuffer2, true);



//--- Get the number of bars
   bars = iBars(_Symbol, PERIOD_CURRENT);

//--- Copy indicator values to buffers
   CopyBuffer(EURUSDCCIValue, 0, 0, bars, EURUSDCCIBuffer);
   CopyBuffer(EURUSDMomentumValue, 0, 0, bars, EURUSDMomentumBuffer);
   CopyBuffer(EURUSDEMAValue1, 0, 0, bars, EURUSDEMABuffer1);
   CopyBuffer(EURUSDEMAValue2, 0, 0, bars, EURUSDEMABuffer2);



//--- Copy indicator values to buffers
   CopyBuffer(GBPUSDCCIValue, 0, 0, bars, GBPUSDCCIBuffer);
   CopyBuffer(GBPUSDMomentumValue, 0, 0, bars, GBPUSDMomentumBuffer);
   CopyBuffer(GBPUSDEMAValue1, 0, 0, bars, GBPUSDEMABuffer1);
   CopyBuffer(GBPUSDEMAValue2, 0, 0, bars, GBPUSDEMABuffer2);


//--- Copy indicator values to buffers
   CopyBuffer(AUDUSDCCIValue, 0, 0, bars, AUDUSDCCIBuffer);
   CopyBuffer(AUDUSDMomentumValue, 0, 0, bars, AUDUSDMomentumBuffer);
   CopyBuffer(AUDUSDEMAValue1, 0, 0, bars, AUDUSDEMABuffer1);
   CopyBuffer(AUDUSDEMAValue2, 0, 0, bars, AUDUSDEMABuffer2);





//--- Copy indicator values to buffers
   CopyBuffer(USDCADCCIValue, 0, 0, bars, USDCADCCIBuffer);
   CopyBuffer(USDCADMomentumValue, 0, 0, bars, USDCADMomentumBuffer);
   CopyBuffer(USDCADEMAValue1, 0, 0, bars, USDCADEMABuffer1);
   CopyBuffer(USDCADEMAValue2, 0, 0, bars, USDCADEMABuffer2);




//--- Copy indicator values to buffers
   CopyBuffer(USDJPYCCIValue, 0, 0, bars, USDJPYCCIBuffer);
   CopyBuffer(USDJPYMomentumValue, 0, 0, bars, USDJPYMomentumBuffer);
   CopyBuffer(USDJPYEMAValue1, 0, 0, bars, USDJPYEMABuffer1);
   CopyBuffer(USDJPYEMAValue2, 0, 0, bars, USDJPYEMABuffer2);




//--- Copy indicator values to buffers
   CopyBuffer(USDCHFCCIValue, 0, 0, bars, USDCHFCCIBuffer);
   CopyBuffer(USDCHFMomentumValue, 0, 0, bars, USDCHFMomentumBuffer);
   CopyBuffer(USDCHFEMAValue1, 0, 0, bars, USDCHFEMABuffer1);
   CopyBuffer(USDCHFEMAValue2, 0, 0, bars, USDCHFEMABuffer2);

   CopyBuffer(NZDUSDCCIValue, 0, 0, bars, NZDUSDCCIBuffer) ;
   CopyBuffer(NZDUSDMomentumValue, 0, 0, bars, NZDUSDMomentumBuffer);
   CopyBuffer(NZDUSDEMAValue1, 0, 0, bars, NZDUSDEMABuffer1);
   CopyBuffer(NZDUSDEMAValue2, 0, 0, bars, NZDUSDEMABuffer2);
   LeftSideDashborad();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!CalculateIndicators())
     {
      Print("Failed to calculate indicators.");
      return;
     }
// Get the latest indicator values
   double ema50 = ema50_buffer[0];
   double ema100 = ema100_buffer[0];
   double ema200 = ema200_buffer[0];
   double cci = cci_buffer[0];
   double momentum = momentum_buffer[0];
// Determine trend direction
   int trend_votes = 0;
   if(ema50 > ema100 && ema100 > ema200)
      trend_votes++;
   if(momentum > 100)
      trend_votes++;
   if(cci > 100)
      trend_votes++;
// Get the current Ask and Bid prices
   double ask = 0;
   double bid = 0;
   if(!SymbolInfoDouble(_Symbol, SYMBOL_ASK, ask) || !SymbolInfoDouble(_Symbol, SYMBOL_BID, bid))
     {
      Print("Error retrieving Ask/Bid prices.");
      return;
     }
// Majority vote logic
   if(trend_votes >= 2)
     {
      // Calculate StopLoss and TakeProfit for Buy Order
      double buy_sl = ask - StopLoss * _Point;
      double buy_tp = ask + TakeProfit * _Point;
      // Open Buy Order
      if(!PositionSelect(_Symbol))
        {
         trade.Buy(Lots, _Symbol, ask, buy_sl, buy_tp, "GoldCore EA");
        }
     }
   else
      if(trend_votes < 2)
        {
         // Calculate StopLoss and TakeProfit for Sell Order
         double sell_sl = bid + StopLoss * _Point;
         double sell_tp = bid - TakeProfit * _Point;
         // Open Sell Order
         if(!PositionSelect(_Symbol))
           {
            trade.Sell(Lots, _Symbol, bid, sell_sl, sell_tp, "GoldCore EA");
           }
        }

   ObjectSetString(0, "EURUSDCCIValue", OBJPROP_TEXT, DoubleToString(EURUSDCCIBuffer[1],2));
   ObjectSetString(0, "GBPUSDCCIValue", OBJPROP_TEXT, DoubleToString(GBPUSDCCIBuffer[1],2));
   ObjectSetString(0, "AUDUSDCCIValue", OBJPROP_TEXT, DoubleToString(AUDUSDCCIBuffer[1],2));
   ObjectSetString(0, "USDCADCCIValue", OBJPROP_TEXT, DoubleToString(USDCADCCIBuffer[1],2));
   ObjectSetString(0, "USDJPYCCIValue", OBJPROP_TEXT, DoubleToString(USDJPYCCIBuffer[1],2));
   ObjectSetString(0, "USDCHFCCIValue", OBJPROP_TEXT, DoubleToString(USDCHFCCIBuffer[1],2));
   ObjectSetString(0, "NZDUSDCCIValue", OBJPROP_TEXT, DoubleToString(NZDUSDCCIBuffer[1],2));

   ObjectSetString(0, "EURUSDMOMValue", OBJPROP_TEXT, DoubleToString(EURUSDMomentumBuffer[1],2));
   ObjectSetString(0, "GBPUSDMOMValue", OBJPROP_TEXT, DoubleToString(GBPUSDMomentumBuffer[1],2));
   ObjectSetString(0, "AUDUSDMOMValue", OBJPROP_TEXT, DoubleToString(AUDUSDMomentumBuffer[1],2));
   ObjectSetString(0, "USDCADMOMValue", OBJPROP_TEXT, DoubleToString(USDCADMomentumBuffer[1],2));
   ObjectSetString(0, "USDJPYMOMValue", OBJPROP_TEXT, DoubleToString(USDJPYMomentumBuffer[1],2));
   ObjectSetString(0, "USDCHFMOMValue", OBJPROP_TEXT, DoubleToString(USDCHFMomentumBuffer[1],2));
   ObjectSetString(0, "NZDUSDMOMValue", OBJPROP_TEXT, DoubleToString(NZDUSDMomentumBuffer[1],2));


   ObjectSetString(0, "EURUSDEMAValue", OBJPROP_TEXT, DoubleToString(EURUSDEMABuffer1[1],2));
   ObjectSetString(0, "GBPUSDEMAValue", OBJPROP_TEXT, DoubleToString(GBPUSDEMABuffer1[1],2));
   ObjectSetString(0, "AUDUSDEMAValue", OBJPROP_TEXT, DoubleToString(AUDUSDEMABuffer1[1],2));
   ObjectSetString(0, "USDCADEMAValue", OBJPROP_TEXT, DoubleToString(USDCADEMABuffer1[1],2));
   ObjectSetString(0, "USDJPYEMAValue", OBJPROP_TEXT, DoubleToString(USDJPYEMABuffer1[1],2));
   ObjectSetString(0, "USDCHFEMAValue", OBJPROP_TEXT, DoubleToString(USDCHFEMABuffer1[1],2));
   ObjectSetString(0, "NZDUSDEMAValue", OBJPROP_TEXT, DoubleToString(NZDUSDEMABuffer1[1],2));

// Moving average
   if(EURUSDEMABuffer1[1] > EURUSDEMABuffer2[1])
     {
      ObjectSetString(0,"EURUSDEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(EURUSDEMABuffer1[1] < EURUSDEMABuffer2[1])
        {
         ObjectSetString(0,"EURUSDEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"EURUSDEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(GBPUSDEMABuffer1[1] > GBPUSDEMABuffer2[1])
     {
      ObjectSetString(0,"GBPUSDEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(GBPUSDEMABuffer1[1] < GBPUSDEMABuffer2[1])
        {
         ObjectSetString(0,"GBPUSDEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"GBPUSDEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }


   if(AUDUSDEMABuffer1[1] > AUDUSDEMABuffer2[1])
     {
      ObjectSetString(0,"AUDUSDEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(AUDUSDEMABuffer1[1] < AUDUSDEMABuffer2[1])
        {
         ObjectSetString(0,"AUDUSDEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"AUDUSDEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }


   if(USDCADEMABuffer1[1] > USDCADEMABuffer2[1])
     {
      ObjectSetString(0,"USDCADEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCADEMABuffer1[1] < USDCADEMABuffer2[1])
        {
         ObjectSetString(0,"USDCADEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCADEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(USDJPYEMABuffer1[1] > USDJPYEMABuffer2[1])
     {
      ObjectSetString(0,"USDJPYEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDJPYEMABuffer1[1] < USDJPYEMABuffer2[1])
        {
         ObjectSetString(0,"USDJPYEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDJPYEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }


   if(USDCHFEMABuffer1[1] > USDCHFEMABuffer2[1])
     {
      ObjectSetString(0,"USDCHFEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCHFEMABuffer1[1] < USDCHFEMABuffer2[1])
        {
         ObjectSetString(0,"USDCHFEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCHFEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(NZDUSDEMABuffer1[1] > NZDUSDEMABuffer2[1])
     {
      ObjectSetString(0,"NZDUSDEMABUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(NZDUSDEMABuffer1[1] < NZDUSDEMABuffer2[1])
        {
         ObjectSetString(0,"NZDUSDEMABUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"NZDUSDEMABUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_COLOR, clrBlue);
        }


//MOM LOGIC
   if(EURUSDMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"EURUSDMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(EURUSDMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"EURUSDMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"EURUSDMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(GBPUSDMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"GBPUSDMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(GBPUSDMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"GBPUSDMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"GBPUSDMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(AUDUSDMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"AUDUSDMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(AUDUSDMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"AUDUSDMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"AUDUSDMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(USDCADMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"USDCADMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCADMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"USDCADMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCADMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(USDJPYMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"USDJPYMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDJPYMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"USDJPYMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDJPYMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(USDCHFMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"USDCHFMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCHFMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"USDCHFMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCHFMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(NZDUSDMomentumBuffer[1] < MOMThreshold)
     {
      ObjectSetString(0,"NZDUSDMOMBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(NZDUSDMomentumBuffer[1] > MOMThreshold)
        {
         ObjectSetString(0,"NZDUSDMOMBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"NZDUSDMOMBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

//CCI Logic
   if(EURUSDCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"EURUSDCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(EURUSDCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"EURUSDCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"EURUSDCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }

   if(GBPUSDCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"GBPUSDCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(GBPUSDCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"GBPUSDCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"GBPUSDCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
   if(AUDUSDCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"AUDUSDCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(AUDUSDCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"AUDUSDCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"AUDUSDCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
   if(USDCADCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"USDCADCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCADCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"USDCADCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCADCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
   if(USDJPYCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"USDJPYCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDJPYCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"USDJPYCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDJPYCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
   if(USDCHFCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"USDCHFCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(USDCHFCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"USDCHFCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"USDCHFCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
   if(NZDUSDCCIBuffer[1] > CCIThreshold1)
     {
      ObjectSetString(0,"NZDUSDCCIBUY/SELL",OBJPROP_TEXT,"(BUY)");
      ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_COLOR, clrGreen);
     }
   else
      if(NZDUSDCCIBuffer[1] > CCIThreshold2)
        {
         ObjectSetString(0,"NZDUSDCCIBUY/SELL",OBJPROP_TEXT,"(SELL)");
         ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0,"NZDUSDCCIBUY/SELL",OBJPROP_TEXT,"(NUTR)");
         ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlue);
        }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LeftSideDashborad()
  {
   ObjectCreate(0, "BackPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "BackPanel", OBJPROP_XSIZE, 850);
   ObjectSetInteger(0, "BackPanel", OBJPROP_YSIZE, 180);
   ObjectSetInteger(0, "BackPanel", OBJPROP_XDISTANCE, 400);
   ObjectSetInteger(0, "BackPanel", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "BackPanel", OBJPROP_BGCOLOR, clrYellow);
   ObjectSetInteger(0, "BackPanel", OBJPROP_BACK, true);

   ObjectCreate(0, "SubPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "SubPanel", OBJPROP_XSIZE, 830);
   ObjectSetInteger(0, "SubPanel", OBJPROP_YSIZE, 160);
   ObjectSetInteger(0, "SubPanel", OBJPROP_XDISTANCE, 410);
   ObjectSetInteger(0, "SubPanel", OBJPROP_YDISTANCE, 40);
   ObjectSetInteger(0, "SubPanel", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "SubPanel", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "SubPanel", OBJPROP_BACK, true);

   ObjectCreate(0, "CCI", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "CCI", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "CCI", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "CCI", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "CCI", OBJPROP_TEXT, "CCI");
   ObjectSetInteger(0, "CCI", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "Momentum ", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Momentum ", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "Momentum ", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "Momentum ", OBJPROP_YDISTANCE, 120);
   ObjectSetString(0, "Momentum ", OBJPROP_TEXT, "Momentum");
   ObjectSetInteger(0, "Momentum ", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EMA", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EMA", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EMA", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "EMA", OBJPROP_YDISTANCE, 150);
   ObjectSetString(0, "EMA", OBJPROP_TEXT, "EMA");
   ObjectSetInteger(0, "EMA", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSD", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "EURUSD", OBJPROP_TEXT, "EURUSD");
   ObjectSetInteger(0, "EURUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "GBPUSD", OBJPROP_TEXT, "GBPUSD");
   ObjectSetInteger(0, "GBPUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "AUDUSD", OBJPROP_TEXT, "AUDUSD");
   ObjectSetInteger(0, "AUDUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCAD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCAD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCAD", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCAD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDCAD", OBJPROP_TEXT, "USDCAD");
   ObjectSetInteger(0, "USDCAD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPY", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPY", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPY", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPY", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDJPY", OBJPROP_TEXT, "USDJPY");
   ObjectSetInteger(0, "USDJPY", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHF", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHF", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHF", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHF", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDCHF", OBJPROP_TEXT, "USDCHF");
   ObjectSetInteger(0, "USDCHF", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "NZDUSD", OBJPROP_TEXT, "NZDUSD");
   ObjectSetInteger(0, "NZDUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "GBPUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "AUDUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDCADCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDJPYCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCADMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDJPYMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDEMAValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "EURUSDEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDEMAValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "GBPUSDEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDEMAValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "AUDUSDEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCADEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADEMAValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDCADEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPYEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYEMAValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDJPYEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFEMAValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDCHFEMAValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDEMAValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDEMAValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDEMAValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDEMAValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "NZDUSDEMAValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "EURUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "GBPUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "AUDUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "USDCADCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "USDJPYCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "USDCHFCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "NZDUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);

   ObjectCreate(0, "EURUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "GBPUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "AUDUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDCADMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDJPYMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDCHFMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "NZDUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "EURUSDEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "GBPUSDEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "AUDUSDEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDCADEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDJPYEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDCHFEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFEMABUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "NZDUSDEMABUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDEMABUY/SELL", OBJPROP_YDISTANCE, 150);
  }