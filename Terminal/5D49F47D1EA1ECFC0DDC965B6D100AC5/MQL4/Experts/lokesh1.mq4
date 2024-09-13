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
int handleAlphaTrend;

//--- global variables
double lastLotSize = Lots;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- create handle for custom indicator
    handleAlphaTrend = iCustom(NULL, 0, "AlphaTrend",13,1,0);
    
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
    static double lastAlphaTrendValue;
    double alphaTrendValue;
    
    alphaTrendValue = iCustom(NULL, 0, "AlphaTrend", 0, 0);
    
    if (lastAlphaTrendValue != alphaTrendValue)
    {
        double alphaTrendPrevValue = iCustom(NULL, 0, "AlphaTrend", 1, 1);
        
        if (alphaTrendValue > alphaTrendPrevValue)
        {
            // Buy Signal
            if (OrderSend(Symbol(), OP_BUY, lastLotSize, Ask, 3, 0, 0, "AlphaTrend Buy", 0, 0, Blue) > 0)
            {
                lastLotSize = Lots;
            }
            else
            {
                lastLotSize *= MartingaleMultiplier;
            }
        }
        else if (alphaTrendValue < alphaTrendPrevValue)
        {
            // Sell Signal
            if (OrderSend(Symbol(), OP_SELL, lastLotSize, Bid, 3, 0, 0, "AlphaTrend Sell", 0, 0, Red) > 0)
            {
                lastLotSize = Lots;
            }
            else
            {
                lastLotSize *= MartingaleMultiplier;
            }
        }
        
        lastAlphaTrendValue = alphaTrendValue;
    }
}
