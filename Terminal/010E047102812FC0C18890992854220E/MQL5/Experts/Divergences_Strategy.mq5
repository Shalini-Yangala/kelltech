//+------------------------------------------------------------------+
//|                                         Divergences_Strategy.mq5 |
//|                                               Copyright 2024, NA |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA"
#property link      "N/A"
#property version   "1.00"

#include <Trade\Trade.mqh> // Include the Trade.mqh file

input int VerificationCandles = 20;
input double Lots = 0.1;
input int TimeGapCandles = 5;

input ENUM_APPLIED_VOLUME AppVolume = VOLUME_TICK;

input int TpPoints=200;
input int S1Points=200;


int totalBars;
int handleObv;
datetime timeLow1, timeLow2, timeHigh1, timeHigh2;
double low1, low2, high1, high2;
datetime timeLowObv1, timeLowObv2, timeHighObv1, timeHighObv2;
double lowObv1, lowObv2, highObv1, highObv2;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    totalBars = iBars(_Symbol, PERIOD_CURRENT);
    handleObv = iOBV(_Symbol, PERIOD_CURRENT, AppVolume);
    return (INIT_SUCCEEDED);
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
    int bars = iBars(_Symbol, PERIOD_CURRENT);
    if (totalBars != bars)
    {
        totalBars = bars;
           datetime newTime = 0;     
        double newLow = 0, newHigh = 0;
        
        findHighLow(newLow, newHigh, newTime);
        
        
            datetime newTimeObv = 0;
        double newLowObv = 0, newHighObv = 0;
       findHighLowObv(newLowObv, newHighObv, newTimeObv);

        if (newLow != 0 || newLowObv != 0)
        {
            if (newLow != 0)
            {
                low2 = low1;
                timeLow2 = timeLow1;
                low1 = newLow;
                timeLow1 = newTime;
            }
            if (newLowObv != 0)
            {
                lowObv2 = lowObv1;
                timeLowObv2 = timeLowObv1;
                lowObv1 = newLowObv;
                timeLowObv1 = newTime;
            }

            // Print(low1," ",low2," ",lowObv1," ",lowObv2," ");
            ulong timeGap = TimeGapCandles * PeriodSeconds(PERIOD_CURRENT);
            if (low1 < low2 && lowObv1 > lowObv2 && (ulong)MathAbs(timeLow1 - timeLowObv1) < timeGap && (ulong)MathAbs(timeLow2 - timeLowObv2) < timeGap)
            {
                Print(__FUNCTION__, "> New buy signal......");
                
                double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                ask = NormalizeDouble(ask,_Digits);
                
                double tp=ask+TpPoints * _Point;
                tp=NormalizeDouble(tp,_Digits);
                double s1=ask-S1Points*_Point;
                s1=NormalizeDouble(s1,_Digits);
                CTrade trade;
                trade.Buy(Lots, _Symbol,ask,s1,tp);
               
            }
        }

        if (newHigh != 0 || newHighObv != 0)
        {
            if (newHigh != 0)
            {
                high2 = high1;
                timeHigh2 = timeHigh1;
                high1 = newHigh;
                timeHigh1 = newTime;
            }
            if (newHighObv != 0)
            {
                highObv2 = highObv1;
                timeHighObv2 = timeHighObv1;
                highObv1 = newHighObv;
                timeHighObv1 = newTimeObv;
            }

            // Print(low1," ",low2," ",lowObv1," ",lowObv2," ");
            ulong timeGap = TimeGapCandles * PeriodSeconds(PERIOD_CURRENT);
            if (high1 < high2 && highObv1 > highObv2 && (ulong)MathAbs(timeHigh1 - timeHighObv1) < timeGap && (ulong)MathAbs(timeHigh2 - timeHighObv2) < timeGap)
            {
                Print(__FUNCTION__, "> New sell signal......");
                
                double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
                bid= NormalizeDouble(bid,_Digits);
                
                double tp=bid- TpPoints * _Point;
                tp=NormalizeDouble(tp,_Digits);
                double s1=bid+S1Points*_Point;
                s1=NormalizeDouble(s1,_Digits);
                
                CTrade trade;
                trade.Sell(Lots, _Symbol,bid,s1,tp);
               
            }
        }

        // Comment("High:", DoubleToString(high, _Digits),
        // "\nLow: ", DoubleToString(low, _Digits));
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findHighLow(double &newLow, double &newHigh, datetime &newTime)
{
    int indexBar = VerificationCandles + 1;
    double high = iHigh(_Symbol, PERIOD_CURRENT, indexBar);
    double low = iLow(_Symbol, PERIOD_CURRENT, indexBar);
    datetime time = iTime(_Symbol, PERIOD_CURRENT, indexBar);

    bool isHigh = true, isLow = true;
    for (int i = 1; i < VerificationCandles; i++)
    {
        double highLeft = iHigh(_Symbol, PERIOD_CURRENT, indexBar + i);
        double highRight = iHigh(_Symbol, PERIOD_CURRENT, indexBar - i);

        if (highLeft > high || highRight > high)
            isHigh = false;

        double lowLeft = iLow(_Symbol, PERIOD_CURRENT, indexBar + i);
        double lowRight = iLow(_Symbol, PERIOD_CURRENT, indexBar - i);
        if (lowLeft < low || lowRight < low)
            isLow = false;

        if (isHigh && !isLow)
            break;
        if (i == VerificationCandles)
        {
            if (isHigh)
            {
                Print(__FUNCTION__, "> Found a new high(", DoubleToString(high, _Digits), ")at ", time, "...");
                ObjectCreate(0, "High" + TimeToString(time), OBJ_ARROW_SELL, 0, time, high);
                newHigh = high;
                newTime = time;
            }

            if (isLow)
            {
                Print(__FUNCTION__, "> Found a new low(", DoubleToString(low, _Digits), ")at ", time, "...");
                ObjectCreate(0, "Low" + TimeToString(time), OBJ_ARROW_BUY, 0, time, low);
                newLow = low;
                newTime = time;
            }
        }
    }
}

//+------------------------------------------------------------------+
void findHighLowObv(double &newLow, double &newHigh, datetime &newTime)
{
    int indexBar = VerificationCandles;

    double obv[];
    if (CopyBuffer(handleObv, 0, 1, VerificationCandles * 2 + 1, obv) < VerificationCandles * 2 + 1)
        return;

    double value = obv[indexBar];
    datetime time = iTime(_Symbol, PERIOD_CURRENT, indexBar);

    bool isHigh = true, isLow = true;
    for (int i = 1; i <= VerificationCandles; i++)
    {
        double valLeft = obv[indexBar + i];
        double valRight = obv[indexBar - i];

        if (valLeft > value || valRight > value)
            isHigh = false;

        if (valLeft < value || valRight < value)
            isLow = false;

        if (isHigh && !isLow)
            break;

        if (i == VerificationCandles)
        {
            if (isHigh)
            {
                Print(__FUNCTION__, "> Found a new high (", DoubleToString(value, _Digits), ") at ", time, "...");
                ObjectCreate(0, "High" + TimeToString(time), OBJ_ARROW_SELL, 1, time, value);
                newHigh = value;
                newTime = time;
            }

            if (isLow)
            {
                Print(__FUNCTION__, "> Found a new low (", DoubleToString(value, _Digits), ") at ", time, "...");
                ObjectCreate(0, "Low" + TimeToString(time), OBJ_ARROW_BUY, 1, time, value);
                newLow = value;
                newTime = time;
            }
        }
    }
}
