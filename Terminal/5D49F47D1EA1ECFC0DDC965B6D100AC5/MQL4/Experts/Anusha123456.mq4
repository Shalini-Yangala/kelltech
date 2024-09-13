//+------------------------------------------------------------------+
//|                                             CT1.mq4              |
//|                        Copyright 2024, Kern Wealth Advisors      |
//|                                      https://www.zellerkern.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kern Wealth Advisors"
#property link      "https://www.zellerkern.com/"
#property version   "1.00"
#property strict

// Input parameters
extern int    coralPeriod = 21;   // Period for Coral Filter
extern double lotSize    = 0.1;   // Initial lot size for trading
extern double martingale = 1.5;   // Martingale multiplier

// Global variables for martingale
double currentLotSize;
int    lastOrderType;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize global variables
    currentLotSize = lotSize;
    lastOrderType = -1; // No previous order

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Get the current Coral Trend value
    double currentCoral = iCustom(NULL, 0, "CoralTrendIndicator", coralPeriod, 0);
    
    Print("Current Coral Value: ", currentCoral);

    // Check if there is an open trade
    bool tradeOpen = false;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                tradeOpen = true;
                break;
            }
        }
    }

    // Trading logic
    if (!tradeOpen) {
        if (currentCoral > 0) {
            // Place buy trade
            PlaceTrade(OP_BUY, Ask);
        } else if (currentCoral < 0) {
            // Place sell trade
            PlaceTrade(OP_SELL, Bid);
        }
    }
}

//+------------------------------------------------------------------+
//| Function to place trade and manage martingale                    |
//+------------------------------------------------------------------+
void PlaceTrade(int tradeType, double price)
{
    // Adjust lot size based on last order type
    if (lastOrderType != tradeType && lastOrderType != -1) {
        currentLotSize = lotSize; // Reset lot size if new trade type
    }

    // Place the order
    int ticket = OrderSend(Symbol(), tradeType, currentLotSize, price, 3, 0, 0, "", 0, Blue);

    if (ticket < 0) {
        Print("Error placing order: ", GetLastError());
    } else {
        Print((tradeType == OP_BUY ? "Buy" : "Sell"), " order placed at ", price);

        // Display arrow on chart
        string arrowName = (tradeType == OP_BUY ? "BuyArrow_" : "SellArrow_") + TimeToStr(Time[0], TIME_DATE | TIME_MINUTES);
        double arrowPrice = (tradeType == OP_BUY ? Low[0] - 10 * Point : High[0] + 10 * Point);
        if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, Time[0], arrowPrice)) {
            Print("Error creating arrow: ", GetLastError());
        } else {
            ObjectSetInteger(0, arrowName, OBJPROP_COLOR, (tradeType == OP_BUY ? Blue : Red));
            ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, (tradeType == OP_BUY ? 233 : 234)); // Up or down arrow
            ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);
        }

        // Update last order type and adjust lot size for martingale
        lastOrderType = tradeType;
        currentLotSize *= martingale;
    }
}

//+------------------------------------------------------------------+
//| Function to get the last closed order type                       |
//+------------------------------------------------------------------+
int GetLastOrderType()
{
    int lastType = -1;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderCloseTime() != 0) {
                lastType = OrderType();
                break;
            }
        }
    }
    return lastType;
}
