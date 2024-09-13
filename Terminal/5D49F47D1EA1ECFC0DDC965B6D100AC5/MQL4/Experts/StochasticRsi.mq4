//+------------------------------------------------------------------+
//|                                             StochasticRsi.mq4    |
//|                                 Copyright 2024, Your Name        |
//|                                 https://www.yourwebsite.com      |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// Input Parameters
input int RSI_Period = 14;                // RSI period
input int Stochastic_K = 5;               // Stochastic K period
input int Stochastic_D = 3;               // Stochastic D period
input int Stochastic_Slowing = 3;         // Stochastic slowing period
input int Stochastic_Upper = 80;          // Stochastic upper level
input int Stochastic_Lower = 20;          // Stochastic lower level

// Global Variables
double rsiValue;                          // RSI value
double stochMain;                         // Stochastic main line value
double stochSignal;                       // Stochastic signal line value

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code
    Print("StochasticRsi EA initialized.");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Deinitialization code
    Print("StochasticRsi EA deinitialized.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Calculate RSI
    rsiValue = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE, 0);
    
    // Calculate Stochastic
    stochMain = iStochastic(_Symbol, PERIOD_CURRENT, Stochastic_K, Stochastic_D, Stochastic_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
    stochSignal = iStochastic(_Symbol, PERIOD_CURRENT, Stochastic_K, Stochastic_D, Stochastic_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);

    // Trading logic
    // Buy signal
    if (rsiValue < 30 && stochMain < Stochastic_Lower && stochSignal < Stochastic_Lower)
    {
        int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Buy Order", 0, 0, Blue);
        if (ticket < 0)
        {
            Print("Error placing buy order: ", GetLastError());
        }
        else
        {
            Print("Buy order placed. Ticket: ", ticket);
        }
    }
    // Sell signal
    else if (rsiValue > 70 && stochMain > Stochastic_Upper && stochSignal > Stochastic_Upper)
    {
        int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Sell Order", 0, 0, Red);
        if (ticket < 0)
        {
            Print("Error placing sell order: ", GetLastError());
        }
        else
        {
            Print("Sell order placed. Ticket: ", ticket);
        }
    }
}
//+------------------------------------------------------------------+
