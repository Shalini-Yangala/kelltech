//+------------------------------------------------------------------+
//|                                                       StochR.mq4 |
//|                                             Kern Wealth Advisors |
//|                                       http://www.zellerkern.com/ |
//+------------------------------------------------------------------+
#property copyright "Kern Wealth Advisors"
#property link      "http://www.zellerkern.com/"
#property version   "1.00"
#property strict

// Inputs for Stochastic Oscillator
input int KPeriod = 14;
input int DPeriod = 3;
input int Slowing = 3;
input int OverboughtLevel = 80;
input int OversoldLevel = 20;

// Inputs for ATR
input int ATRPeriod = 14;
input double ATRMultiplier = 1.5;

// Risk management
input double MaxDrawdownPercent = 3.5;
input double AlertBalancePercent = 1.0;

// Other inputs
input double Lots = 0.1;
input double StopLoss = 50;
input double TakeProfit = 100;

// Global variables
double previousBalance;
double previousEquity;
bool tradeAllowed = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   previousBalance = AccountBalance();
   previousEquity = AccountEquity();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Cleanup code if necessary
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if trading is allowed
   if(!tradeAllowed)
      return;

   // Calculate the current Stochastic values
   double K = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double D = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);

   // Calculate the current ATR value
   double atr = iATR(NULL, 0, ATRPeriod, 0);
   double entryPriceBuy = High[1] + ATRMultiplier * atr;
   double entryPriceSell = Low[1] - ATRMultiplier * atr;

   // Check for buy signal
   if(K < OversoldLevel && D < OversoldLevel && Bid > entryPriceBuy && !IsTradeOpen(OP_BUY))
   {
      // Buy condition met
      OpenBuyOrder();
   }

   // Check for sell signal
   if(K > OverboughtLevel && D > OverboughtLevel && Ask < entryPriceSell && !IsTradeOpen(OP_SELL))
   {
      // Sell condition met
      OpenSellOrder();
   }

   // Risk management
   CheckRiskManagement();
}

//+------------------------------------------------------------------+
//| Function to check if a trade is already open                     |
//+------------------------------------------------------------------+
bool IsTradeOpen(int tradeType)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderType() == tradeType)
            return(true);
      }
   }
   return(false);
}

//+------------------------------------------------------------------+
//| Function to open a buy order                                     |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
   double lotSize = Lots;
   double price = Ask;
   double sl = price - StopLoss * Point;
   double tp = price + TakeProfit * Point;
   int ticket = OrderSend(Symbol(), OP_BUY, lotSize, price, 3, sl, tp, "Buy Order", 0, 0, Green);
   if(ticket < 0)
   {
      Print("Error opening buy order: ", GetLastError());
   }
   else
   {
      Alert("Buy order opened at Ask: " + DoubleToString(price, _Digits));
   }
}

//+------------------------------------------------------------------+
//| Function to open a sell order                                    |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
   double lotSize = Lots;
   double price = Bid;
   double sl = price + StopLoss * Point;
   double tp = price - TakeProfit * Point;
   int ticket = OrderSend(Symbol(), OP_SELL, lotSize, price, 3, sl, tp, "Sell Order", 0, 0, Red);
   if(ticket < 0)
   {
      Print("Error opening sell order: ", GetLastError());
   }
   else
   {
      Alert("Sell order opened at Bid: " + DoubleToString(price, _Digits));
   }
}

//+------------------------------------------------------------------+
//| Function to check risk management                                |
//+------------------------------------------------------------------+
void CheckRiskManagement()
{
   double currentBalance = AccountBalance();
   double currentEquity = AccountEquity();

   // Check for max drawdown
   double drawdown = (previousBalance - currentEquity) / previousBalance * 100;
   if(drawdown >= MaxDrawdownPercent)
   {
      tradeAllowed = false;
      Alert("Trading halted due to drawdown limit reached.");
   }

   // Check for balance alert
   if(currentBalance / previousBalance < AlertBalancePercent / 100)
   {
      Alert("Account balance dropped below specified percentage.");
   }

   // Update previous balance and equity
   previousBalance = currentBalance;
   previousEquity = currentEquity;
}
//+------------------------------------------------------------------+
