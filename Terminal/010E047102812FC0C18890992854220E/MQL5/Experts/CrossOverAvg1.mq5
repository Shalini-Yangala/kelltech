//+------------------------------------------------------------------+
//|                                                 CrossOverAvg.mq5 |
//|                                        Copyright 2024, FX Empire |
//|                                         http://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, FX Empire"
#property link      "http://www.fxempire.com/"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade; // Trade object for executing trades

// Input parameters
input int TEMA_Period = 14;               // TEMA period
input int FAMA_Period = 14;               // FAMA period
input double MartingaleMultiplier = 1.3;  // Martingale multiplier
input double MaxAccountRisk = 14;         // Maximum risk percentage
input double LotSize = 0.1;               // Initial lot size
input double AccountRiskThreshold = 14;   // Account risk threshold percentage
input double StopLoss = 50;               // Stop loss in points
input double TakeProfit = 50;             // Take profit in points

// Global variables
int TEMA_Handle, FAMA_Handle;             // Indicator handles
double LastLotSize = 0.1;                 // Last used lot size
bool isBuyTradeOpen = false;              // Flag for buy trade status
bool isSellTradeOpen = false;             // Flag for sell trade status
bool lastTradeWasLoss = false;            // Flag to track if last trade was a loss

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create TEMA and FAMA indicator handles
    TEMA_Handle = iTEMA(NULL, 0, TEMA_Period, 0, PRICE_CLOSE);
    FAMA_Handle = iFrAMA(NULL, 0, FAMA_Period, 0, PRICE_CLOSE);

    // Check if indicator handles were successfully created
    if (TEMA_Handle == INVALID_HANDLE || FAMA_Handle == INVALID_HANDLE)
    {
        Print("Failed to create indicator handles");
        return INIT_FAILED;
    }

    Print("Initialization successful.");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release indicator handles when EA is removed from chart
    IndicatorRelease(TEMA_Handle);
    IndicatorRelease(FAMA_Handle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    double TEMA[], FAMA[];

    // Attempt to copy indicator buffer values
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
        return;
    }

    // Buy condition: TEMA crosses above FAMA
    if (TEMA[1] > FAMA[1] && TEMA[2] <= FAMA[2])
    {
        if (!isBuyTradeOpen)
        {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            // Attempt to open a buy trade
            if (trade.Buy(LotSize, _Symbol, ask, ask - StopLoss * _Point, ask + TakeProfit * _Point))
            {
                LastLotSize = LotSize;
                isBuyTradeOpen = true;   // Set buy trade flag
                isSellTradeOpen = false; // Reset sell trade flag
            }
            else
            {
                Print("Error opening buy order: ", GetLastError());
            }
        }
    }

    // Sell condition: TEMA crosses below FAMA
    if (TEMA[1] < FAMA[1] && TEMA[2] >= FAMA[2])
    {
        if (!isSellTradeOpen)
        {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            // Attempt to open a sell trade
            if (trade.Sell(LotSize, _Symbol, bid, bid + StopLoss * _Point, bid - TakeProfit * _Point))
            {
                LastLotSize = LotSize;
                isSellTradeOpen = true;  // Set sell trade flag
                isBuyTradeOpen = false;  // Reset buy trade flag
            }
            else
            {
                Print("Error opening sell order: ", GetLastError());
            }
        }
    }

    // Dynamic account risk management
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);

    // Calculate the current account risk percentage
    double currentAccountRisk = 100.0 - (accountEquity / accountBalance) * 100.0;

    // Check if account risk limit is reached
    if (currentAccountRisk <= -MaxAccountRisk)
    {
        Print("Account risk limit reached. No further trading.");
        return;
    }

    // Check if the last trade was a loss
    if (OrdersTotal() > 0)
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (!OrderSelect(i, SELECT_BY_POS))
                continue;

            if (OrderType() == OP_BUY && OrderProfit() < 0)
            {
                lastTradeWasLoss = true;
                break;
            }
            else if (OrderType() == OP_SELL && OrderProfit() < 0)
            {
                lastTradeWasLoss = true;
                break;
            }
        }
    }

    // If last trade was a loss, increase lot size for next trade
    if (lastTradeWasLoss)
    {
        double newLotSize = LastLotSize * MartingaleMultiplier;
        if (newLotSize <= AccountFreeMarginCheck(_Symbol))
        {
            LastLotSize = newLotSize;
        }
        else
        {
            Print("Insufficient margin to increase lot size.");
        }
    }
    else
    {
        // Reset lot size if no loss occurred
        LastLotSize = LotSize;
    }
}
