//+------------------------------------------------------------------+
//|                                                 CrossOverAvg.mq5 |
//|                                        Copyright 2024, FX Empire |
//|                                         http://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, FX Empire"
#property link      "http://www.fxempire.com/"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade;

input int TEMA_Period = 14;               // TEMA period
input int FAMA_Period = 14;               // FAMA period
input double MartingaleMultiplier = 1.3;  // Martingale multiplier
input double MaxAccountRisk = 14;         // Maximum risk percentage
input double LotSize = 0.1;               // Initial lot size
input double AccountRiskThreshold = 14;   // Account risk threshold percentage
input double StopLoss = 50;               // Stop loss in points
input double TakeProfit = 50;             // Take profit in points

// Global variables
int TEMA_Handle, FAMA_Handle;
double LastLotSize = 0.1;
double AccountRiskLimit;
bool isBuyTradeOpen = false;
bool isSellTradeOpen = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create TEMA and FAMA handles
    TEMA_Handle = iTEMA(NULL, 0, TEMA_Period, 0, PRICE_CLOSE);
    FAMA_Handle = iFrAMA(NULL, 0, FAMA_Period, 0, PRICE_CLOSE);

    if (TEMA_Handle == INVALID_HANDLE || FAMA_Handle == INVALID_HANDLE)
    {
        Print("Failed to create indicator handles");
        return INIT_FAILED;
    }

    // Calculate account risk limit
    AccountRiskLimit = AccountInfoDouble(ACCOUNT_BALANCE) * (AccountRiskThreshold / 100.0);

    Print("Initialization successful.");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release indicator handles
    IndicatorRelease(TEMA_Handle);
    IndicatorRelease(FAMA_Handle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    double TEMA[], FAMA[];
    if (CopyBuffer(TEMA_Handle, 0, 0, 3, TEMA) <= 0)
    {
        Print("Failed to copy TEMA buffer. Error: ", GetLastError());
        return;
    }
    if (CopyBuffer(FAMA_Handle, 0, 0, 3, FAMA) <= 0)
    {
        Print("Failed to copy FAMA buffer. Error: ", GetLastError());
        return;
    }

    // Check if there are any open trades to avoid multiple trades
    if (OrdersTotal() > 0)
    {
        Print("There are already open trades. Skipping new trade.");
        return;
    }

    if (TEMA[1] > FAMA[1] && TEMA[2] <= FAMA[2])
    {
        if (!isBuyTradeOpen)
        {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if (trade.Buy(LotSize, _Symbol, ask, ask - StopLoss * _Point, ask + TakeProfit * _Point))
            {
                Print("Buy condition met. Lot size: ", LotSize);
                LastLotSize = LotSize;
                isBuyTradeOpen = true;
                isSellTradeOpen = false;
            }
            else
            {
                Print("Error opening buy order: ", GetLastError());
            }
        }
    }
    if (TEMA[1] < FAMA[1] && TEMA[2] >= FAMA[2])
    {
        if (!isSellTradeOpen)
        {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if (trade.Sell(LotSize, _Symbol, bid, bid + StopLoss * _Point, bid - TakeProfit * _Point))
            {
                Print("Sell condition met. Lot size: ", LotSize);
                LastLotSize = LotSize;
                isSellTradeOpen = true;
                isBuyTradeOpen = false;
            }
            else
            {
                Print("Error opening sell order: ", GetLastError());
            }
        }
    }
}