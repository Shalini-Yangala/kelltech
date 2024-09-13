//+------------------------------------------------------------------+
//|                                                     ADX_EA.mq5   |
//|                        Copyright 2024, Your Company Name         |
//|                              http://www.yourcompanywebsite.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Company Name"
#property link      "http://www.yourcompanywebsite.com"
#property version   "1.00"
#property strict
#include <Trade\Trade.mqh> // Include trade library
// Input parameters
input double TakeProfit = 50;            // Take profit in pips
input double StopLoss = 50;              // Stop loss in pips
input double DailyDrawdownLimit = -3.5;  // Daily drawdown limit in percentage
input double MonthlyDrawdownLimit = -7.0; // Monthly drawdown limit in percentage
input double MartingaleMultiplier = 2.0; // Martingale multiplier
input int ADXPeriod = 14;                // ADX period
// Global variables
double DPlusArray[], DMinusArray[];
double MAValue;
double LotSize = 0.1;                    // Initial lot size
int LastPosition = 0;                    // 0 = None, 1 = Buy, 2 = Sell
int adxHandle;                           // Handle for ADX indicator
datetime lastTradeTime = 0;              // Time of the last trade
CTrade trade;                            // Create an instance of trade class
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    adxHandle = iADXWilder(Symbol(), PERIOD_M5, ADXPeriod);
    if (adxHandle == INVALID_HANDLE)
    {
        Print("Failed to create ADX indicator handle.");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Update ADX values
    if (CopyBuffer(adxHandle, 1, 0, 1, DPlusArray) <= 0 ||
        CopyBuffer(adxHandle, 2, 0, 1, DMinusArray) <= 0)
    {
        Print("Failed to get ADX values.");
        return;
    }
    double DPlus = DPlusArray[0];
    double DMinus = DMinusArray[0];
    MAValue = iMA(Symbol(), PERIOD_M5, ADXPeriod, 0, MODE_SMA, PRICE_CLOSE); // Moving Average value
    // Check drawdown conditions
    if (CheckDrawdown())
        return;
    // Check if a new candle has started
    datetime currentCandleTime = iTime(Symbol(), PERIOD_M5, 0);
    if (currentCandleTime == lastTradeTime)
        return; // If the current candle time is the same as the last trade time, do not trade
    // Trading logic
    ManageOpenPositions();
    CheckEntryConditions(DPlus, DMinus);
    // Update the last trade time to the current candle time
    lastTradeTime = currentCandleTime;
}
//+------------------------------------------------------------------+
//| Manage Open Positions                                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    // Check and manage existing positions
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket))
        {
            int positionType = PositionGetInteger(POSITION_TYPE);
            if (positionType == POSITION_TYPE_BUY && LastPosition != 1)
            {
                // Close Buy positions if not in Buy mode
                trade.PositionClose(ticket);
                LotSize = 0.1;
            }
            else if (positionType == POSITION_TYPE_SELL && LastPosition != 2)
            {
                // Close Sell positions if not in Sell mode
                trade.PositionClose(ticket);
                LotSize = 0.1;
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Check entry conditions                                           |
//+------------------------------------------------------------------+
void CheckEntryConditions(double DPlus, double DMinus)
{
    // Check for existing positions
    if (LastPosition == 0) {
        // No position, check for new positions
        if (DPlus < MAValue) // Sell condition
        {
            OpenSellPosition();
        }
        else if (DMinus > MAValue) // Buy condition
        {
            OpenBuyPosition();
        }
    } else if (LastPosition == 1) {
        // Existing Buy position, check for Sell condition to close and reverse
        if (DPlus < MAValue) {
            trade.PositionCloseBy(Symbol(), POSITION_TYPE_BUY);
            OpenSellPosition(); // Open Sell position
        }
    } else if (LastPosition == 2) {
        // Existing Sell position, check for Buy condition to close and reverse
        if (DMinus > MAValue) {
            trade.PositionCloseBy(Symbol(), POSITION_TYPE_SELL);
            OpenBuyPosition(); // Open Buy position
        }
    }
}
//+------------------------------------------------------------------+
//| Open Sell Position                                               |
//+------------------------------------------------------------------+
void OpenSellPosition()
{
    double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double sl = Bid + StopLoss * _Point; // Stop Loss
    double tp = Bid - TakeProfit * _Point; // Take Profit
    // Adjust lot size using Martingale if there's an existing position
    if (LastPosition == 2) {
        LotSize *= MartingaleMultiplier; // Double the lot size
    } else {
        LotSize = 0.1; // Reset to initial size
    }
    if (trade.Sell(LotSize, Symbol(), Bid, sl, tp)) {
        LastPosition = 2; // Update last position
    }
}
//+------------------------------------------------------------------+
//| Open Buy Position                                                |
//+------------------------------------------------------------------+
void OpenBuyPosition()
{
    double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    double sl = Ask - StopLoss * _Point; // Stop Loss
    double tp = Ask + TakeProfit * _Point; // Take Profit
    // Adjust lot size using Martingale if there's an existing position
    if (LastPosition == 1) {
        LotSize *= MartingaleMultiplier; // Double the lot size
    } else {
        LotSize = 0.1; // Reset to initial size
    }
    if (trade.Buy(LotSize, Symbol(), Ask, sl, tp)) {
        LastPosition = 1; // Update last position
    }
}
//+------------------------------------------------------------------+
//| Check Drawdown                                                   |
//+------------------------------------------------------------------+
bool CheckDrawdown()
{
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double dailyDrawdown = (accountBalance - accountEquity) / accountBalance * 100;
     // Monthly drawdown calculation
    double monthlyBalance = GetMonthlyBalance();
    double monthlyDrawdown = (monthlyBalance - AccountInfoDouble(ACCOUNT_BALANCE)) / monthlyBalance * 100;
    return (dailyDrawdown < DailyDrawdownLimit || monthlyDrawdown < MonthlyDrawdownLimit);
}
//+------------------------------------------------------------------+
//| Get Monthly Balance                                              |
//+------------------------------------------------------------------+
double GetMonthlyBalance()
{
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    timeStruct.day = 1;
    timeStruct.hour = 0;
    timeStruct.min = 0;
    timeStruct.sec = 0;
    datetime monthStart = StructToTime(timeStruct);
    HistorySelect(monthStart, TimeCurrent());
    double monthlyBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    for (int i = 0; i < HistoryDealsTotal(); i++)
    {
        ulong ticket = HistoryDealGetTicket(i);
        if (HistoryDealSelect(ticket))
        {
            if (HistoryDealGetInteger(ticket, DEAL_TIME) >= monthStart)
            {
                monthlyBalance -= HistoryDealGetDouble(ticket, DEAL_PROFIT);
            }
        }
    }
    return monthlyBalance;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if (adxHandle != INVALID_HANDLE)
        IndicatorRelease(adxHandle); // Release the ADX handle
}



