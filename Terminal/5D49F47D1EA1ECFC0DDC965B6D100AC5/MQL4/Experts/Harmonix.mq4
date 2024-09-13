//+------------------------------------------------------------------+
//|                                                    Harmonix1.mq4 |
//|                             Copyright 2024, Kern Wealth Advisors |
//|                                       http://www.zellerkern.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kern Wealth Advisors"
#property link      "http://www.zellerkern.com/"
#property version   "1.00"
#property strict
// Inputs for risk and money management
input double InitialLotSize = 0.1;
input double MartingaleMultiplier = 1.5;
input double MaxDrawdownPercent = 3.0;
input int LookbackBars = 400; // Number of bars to look back for patterns
// Global variables
double CurrentLotSize;
double AccountEquityAtStartOfDay;
double MaxDrawdown;
datetime TradingStartTime;
bool TradingHalted = false;
// Function to detect Bat pattern
bool DetectBatPattern() {
    double XA, AB, BC, CD;
    for (int i = LookbackBars; i >= 3; i--) {
        XA = MathAbs(High[i+3] - Low[i+2]);
        AB = MathAbs(Low[i+2] - High[i+1]);
        BC = MathAbs(High[i+1] - Low[i]);
        CD = MathAbs(Low[i] - Close[0]);
        if (AB/XA > 0.382 && AB/XA < 0.5 && BC/AB > 0.382 && BC/AB < 0.886 && CD/BC > 1.618 && CD/BC < 2.618) {
            return true;
        }
    }
    return false;
}
// Function to detect Butterfly pattern
bool DetectButterflyPattern() {
    double XA, AB, BC, CD;
    for (int i = LookbackBars; i >= 3; i--) {
        XA = MathAbs(High[i+3] - Low[i+2]);
        AB = MathAbs(Low[i+2] - High[i+1]);
        BC = MathAbs(High[i+1] - Low[i]);
        CD = MathAbs(Low[i] - Close[0]);
        if (AB/XA > 0.786 && AB/XA < 0.886 && BC/AB > 0.382 && BC/AB < 0.886 && CD/BC > 1.618 && CD/BC < 2.618) {
            return true;
        }
    }
    return false;
}
// Function to reset daily drawdown limit
void ResetDailyDrawdown() {
    TradingStartTime = TimeCurrent();
    AccountEquityAtStartOfDay = AccountEquity();
    MaxDrawdown = 0.0;
    TradingHalted = false;
}
// Function to calculate drawdown and check if trading should be halted
void CheckDrawdown() {
    double currentDrawdown = (AccountEquityAtStartOfDay - AccountEquity()) / AccountEquityAtStartOfDay * 100.0;
    if (currentDrawdown > MaxDrawdown) {
        MaxDrawdown = currentDrawdown;
    }
    if (MaxDrawdown >= MaxDrawdownPercent) {
        TradingHalted = true;
    }
}
// Function to check for existing trades
bool HasOpenTrade(int tradeType) {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderType() == tradeType) {
                return true;
            }
        }
    }
    return false;
}
// Function to place a trade
void PlaceTrade(int tradeType) {
    if (TradingHalted) {
        return;
    }
    // Check for existing trades of the same type
    if (HasOpenTrade(tradeType)) {
        return;
    }
    double lotSize = CurrentLotSize;
    int ticket = -1; // Initialize ticket with -1
    if (tradeType == OP_BUY) {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "Harmonic Buy", 0, 0, clrGreen);
    } else if (tradeType == OP_SELL) {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "Harmonic Sell", 0, 0, clrRed);
    }
    if (ticket < 0) {
        Print("Error placing order: ", GetLastError());
    } else {
        if (OrderSelect(ticket, SELECT_BY_TICKET)) {
            if (OrderProfit() < 0) {
                CurrentLotSize *= MartingaleMultiplier;
            } else {
                CurrentLotSize = InitialLotSize;
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    ResetDailyDrawdown();
    CurrentLotSize = InitialLotSize;
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    if (TimeDay(TradingStartTime) != TimeDay(TimeCurrent())) {
        ResetDailyDrawdown();
    }
    CheckDrawdown();
    if (DetectBatPattern()) {
        PlaceTrade(OP_BUY);
    }
    if (DetectButterflyPattern()) {
        PlaceTrade(OP_SELL);
    }
}
//+------------------------------------------------------------------+