//+------------------------------------------------------------------+
//|                                               MeanTransition.mq5 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.01"


#include <Trade\Trade.mqh>
input int MA_Period1_LowVol = 21;
input int MA_Period2_LowVol = 46;
input int MA_Period1_HighVol = 21;
input int MA_Period2_HighVol = 46;
input int RSI_Period = 14;
input int STO_Period = 14;
input double RSI_LowBound = 30.0;
input double RSI_HighBound = 70.0;
input double STO_LowBound = 20.0;
input double STO_HighBound = 80.0;
input double LotSize = 0.1;
input int TradeDelaySeconds = 60; // Delay between trades in seconds
int handleLWMA1, handleLWMA2, handleEMA1, handleEMA2, handleRSI, handleSTO;
CTrade trade;
double LWMA1[], LWMA2[], EMA1[], EMA2[], RSI[], STO_Main[], STO_Signal[];
datetime lastTradeTime = 0; // Time of the last trade
int lastTradeType = -1; // Last trade type: -1 = none, 0 = buy, 1 = sell
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   handleLWMA1 = iMA(_Symbol, _Period, MA_Period1_LowVol, 0, MODE_LWMA, PRICE_CLOSE);
   handleLWMA2 = iMA(_Symbol, _Period, MA_Period2_LowVol, 0, MODE_LWMA, PRICE_CLOSE);
   handleEMA1 = iMA(_Symbol, _Period, MA_Period1_HighVol, 0, MODE_EMA, PRICE_CLOSE);
   handleEMA2 = iMA(_Symbol, _Period, MA_Period2_HighVol, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
   handleSTO = iStochastic(_Symbol, _Period, STO_Period, 3, 3, MODE_SMA, 0);
   if (handleLWMA1 == INVALID_HANDLE || handleLWMA2 == INVALID_HANDLE || handleEMA1 == INVALID_HANDLE ||
       handleEMA2 == INVALID_HANDLE || handleRSI == INVALID_HANDLE || handleSTO == INVALID_HANDLE)
   {
      Print("Error in creating indicator handles");
      return INIT_FAILED;
   }
   ArraySetAsSeries(LWMA1, true);
   ArraySetAsSeries(LWMA2, true);
   ArraySetAsSeries(EMA1, true);
   ArraySetAsSeries(EMA2, true);
   ArraySetAsSeries(RSI, true);
   ArraySetAsSeries(STO_Main, true);
   ArraySetAsSeries(STO_Signal, true);
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handleLWMA1);
   IndicatorRelease(handleLWMA2);
   IndicatorRelease(handleEMA1);
   IndicatorRelease(handleEMA2);
   IndicatorRelease(handleRSI);
   IndicatorRelease(handleSTO);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if copying buffer data was successful
    if (CopyBuffer(handleLWMA1, 0, 0, 3, LWMA1) <= 0 ||
        CopyBuffer(handleLWMA2, 0, 0, 3, LWMA2) <= 0 ||
        CopyBuffer(handleEMA1, 0, 0, 3, EMA1) <= 0 ||
        CopyBuffer(handleEMA2, 0, 0, 3, EMA2) <= 0 ||
        CopyBuffer(handleRSI, 0, 0, 1, RSI) <= 0 ||
        CopyBuffer(handleSTO, 0, 0, 1, STO_Main) <= 0 ||
        CopyBuffer(handleSTO, 1, 0, 1, STO_Signal) <= 0)
    {
        Print("Error copying buffer data.");
        return;
    }
    bool isLowVol = (RSI[0] < RSI_LowBound && STO_Main[0] < STO_LowBound);
    bool isHighVol = (RSI[0] > RSI_HighBound && STO_Main[0] > STO_HighBound);
    // Check if enough time has passed since the last trade
    if (TimeCurrent() - lastTradeTime >= TradeDelaySeconds)
    {
        // Check if there is an existing position
        bool positionOpen = PositionSelect(_Symbol);
        long posType = positionOpen ? PositionGetInteger(POSITION_TYPE) : POSITION_TYPE_BUY; // Default to BUY if no position
        if (isLowVol)
        {
            // Check for buy conditions
            if (LWMA1[1] < LWMA2[1] && LWMA1[0] > LWMA2[0])
            {
                if (positionOpen && posType == POSITION_TYPE_SELL)
                    trade.PositionClose(_Symbol); // Close SELL position
                if (!positionOpen || posType != POSITION_TYPE_BUY)
                {
                    if (trade.Buy(LotSize, _Symbol))
                    {
                        lastTradeTime = TimeCurrent(); // Update the last trade time
                        lastTradeType = 0; // Record the trade type (BUY)
                    }
                    else
                        Print("Error placing buy order: ", GetLastError());
                }
            }
            // Check for sell conditions
            else if (LWMA1[1] > LWMA2[1] && LWMA1[0] < LWMA2[0])
            {
                if (positionOpen && posType == POSITION_TYPE_BUY)
                    trade.PositionClose(_Symbol); // Close BUY position
                if (!positionOpen || posType != POSITION_TYPE_SELL)
                {
                    if (trade.Sell(LotSize, _Symbol))
                    {
                        lastTradeTime = TimeCurrent(); // Update the last trade time
                        lastTradeType = 1; // Record the trade type (SELL)
                    }
                    else
                        Print("Error placing sell order: ", GetLastError());
                }
            }
        }
        else if (isHighVol)
        {
            // Check for buy conditions
            if (EMA1[1] < EMA2[1] && EMA1[0] > EMA2[0])
            {
                if (positionOpen && posType == POSITION_TYPE_SELL)
                    trade.PositionClose(_Symbol); // Close SELL position
                if (!positionOpen || posType != POSITION_TYPE_BUY)
                {
                    if (trade.Buy(LotSize, _Symbol))
                    {
                        lastTradeTime = TimeCurrent(); // Update the last trade time
                        lastTradeType = 0; // Record the trade type (BUY)
                    }
                    else
                        Print("Error placing buy order: ", GetLastError());
                }
            }
            // Check for sell conditions
            else if (EMA1[1] > EMA2[1] && EMA1[0] < EMA2[0])
            {
                if (positionOpen && posType == POSITION_TYPE_BUY)
                    trade.PositionClose(_Symbol); // Close BUY position
                if (!positionOpen || posType != POSITION_TYPE_SELL)
                {
                    if (trade.Sell(LotSize, _Symbol))
                    {
                        lastTradeTime = TimeCurrent(); // Update the last trade time
                        lastTradeType = 1; // Record the trade type (SELL)
                    }
                    else
                        Print("Error placing sell order: ", GetLastError());
                }
            }
        }
    }
}