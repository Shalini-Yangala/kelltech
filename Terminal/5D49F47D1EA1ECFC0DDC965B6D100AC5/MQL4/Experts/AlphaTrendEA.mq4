//+------------------------------------------------------------------+
//|                                                   AlphaTrendEA.mq4|
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                        https://www.mql5.com      |
//+------------------------------------------------------------------+
#property strict

//--- input parameters
input double Lots = 0.1;
input double StopLoss = 50;
input double TakeProfit = 100;
input double MartingaleMultiplier = 1.5;

//--- indicator handles
double handleAlphaTrend;

//--- global variables
double lastLotSize = Lots;
double lastAlphaTrendValue = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- create handle for custom indicator
    handleAlphaTrend = iCustom(NULL, 0, "Alpha Trend", 1.0, 14, true, false);
    
    if (handleAlphaTrend == INVALID_HANDLE)
    {
        Print("Error creating AlphaTrend indicator handle");
        return(INIT_FAILED);
    }
    
    return(INIT_SUCCEEDED);
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
    double alphaTrendValue = iCustom(NULL, 0, "Alpha Trend", 0, 0);
    double alphaTrendPrevValue = iCustom(NULL, 0, "Alpha Trend", 1, 0);
    
    if (alphaTrendValue != lastAlphaTrendValue)
    {
        Print("AlphaTrend Value: ", alphaTrendValue, " Previous Value: ", alphaTrendPrevValue);
        
        if (alphaTrendValue > alphaTrendPrevValue)
        {
            // Buy Signal
            Print("Attempting Buy Order with lot size: ", lastLotSize);
            int ticket = OrderSend(Symbol(), OP_BUY, lastLotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "AlphaTrend Buy", 0, 0, Blue);
            if (ticket > 0)
            {
                Print("Buy Order placed successfully with ticket: ", ticket);
                lastLotSize = Lots;  // Reset lot size after successful trade
            }
            else
            {
                Print("Buy Order failed, error: ", GetLastError());
                lastLotSize *= MartingaleMultiplier;  // Increase lot size after failed trade
            }
        }
        else if (alphaTrendValue < alphaTrendPrevValue)
        {
            // Sell Signal
            Print("Attempting Sell Order with lot size: ", lastLotSize);
            int ticket = OrderSend(Symbol(), OP_SELL, lastLotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "AlphaTrend Sell", 0, 0, Red);
            if (ticket > 0)
            {
                Print("Sell Order placed successfully with ticket: ", ticket);
                lastLotSize = Lots;  // Reset lot size after successful trade
            }
            else
            {
                Print("Sell Order failed, error: ", GetLastError());
                lastLotSize *= MartingaleMultiplier;  // Increase lot size after failed trade
            }
        }
        
        lastAlphaTrendValue = alphaTrendValue;
    }
}

//+------------------------------------------------------------------+
//| Check if there's an active order of the specified type           |
//+------------------------------------------------------------------+
bool IsOrderTypeActive(int orderType)
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == orderType && OrderSymbol() == Symbol())
            {
                return true;
            }
        }
    }
    return false;
}

