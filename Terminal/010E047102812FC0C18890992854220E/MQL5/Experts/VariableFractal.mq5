//+------------------------------------------------------------------+
//|                                              VariableFractal.mq5 |
//|                                                    Tibra Capital |
//|                                            http://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Tibra Capital"
#property link      "http://www.tibra.com/"
#property version   "1.00"
#include <Trade\Trade.mqh>

//--- input parameters
input int    FRAMA_Period = 14; // FRAMA Period
input int    VIDYA_Period = 14; // VIDYA Period
input int    MaxTrades = 3;     // Maximum active trades
input double RiskPercent = 1.0; // Risk per trade as a percentage of equity

//--- global variables
CTrade trade; // Object for managing trade operations

//--- indicator handles
int handle_FRAMA, handle_VIDYA; // Handles for FRAMA and VIDYA indicators

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- create FRAMA handle
   handle_FRAMA = iCustom(_Symbol, _Period, "Examples\\FRAMA", FRAMA_Period);
   handle_VIDYA = iCustom(_Symbol, _Period, "Examples\\VIDYA", VIDYA_Period);

   //--- check if FRAMA handle is created successfully
   if(handle_FRAMA == INVALID_HANDLE)
     {
      Print("Error creating FRAMA handle");
      return(INIT_FAILED);
     }

   //--- check if VIDYA handle is created successfully
   if(handle_VIDYA == INVALID_HANDLE)
     {
      Print("Error creating VIDYA handle");
      return(INIT_FAILED);
     }

   //--- successful initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- release FRAMA handle
   if(handle_FRAMA != INVALID_HANDLE)
      IndicatorRelease(handle_FRAMA);

   //--- release VIDYA handle
   if(handle_VIDYA != INVALID_HANDLE)
      IndicatorRelease(handle_VIDYA);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double lotSize = CalculateLotSize(RiskPercent); // Calculate lot size based on risk percentage
   double frama_prev, frama_current;               // Variables for FRAMA values
   double vidya_prev, vidya_current;               // Variables for VIDYA values
   double frama_values[2];                         // Array to store FRAMA values
   double vidya_values[2];                         // Array to store VIDYA values

   //--- get FRAMA values
   if(CopyBuffer(handle_FRAMA, 0, 1, 2, frama_values) <= 0)
     {
      Print("Error getting FRAMA values");
      return;
     }

   //--- get VIDYA values
   if(CopyBuffer(handle_VIDYA, 0, 1, 2, vidya_values) <= 0)
     {
      Print("Error getting VIDYA values");
      return;
     }

   frama_prev = frama_values[1];    // Previous FRAMA value
   frama_current = frama_values[0]; // Current FRAMA value

   vidya_prev = vidya_values[1];    // Previous VIDYA value
   vidya_current = vidya_values[0]; // Current VIDYA value

   //--- get the number of open trades
   int totalTrades = TotalOpenTrades();

   //--- buy condition: FRAMA crosses above VIDYA and number of trades is less than MaxTrades
   if(frama_current > vidya_current && frama_prev <= vidya_prev && totalTrades < MaxTrades)
     {
      trade.Buy(lotSize); // Open a buy trade
     }

   //--- sell condition: FRAMA crosses below VIDYA and number of trades is less than MaxTrades
   if(frama_current < vidya_current && frama_prev >= vidya_prev && totalTrades < MaxTrades)
     {
      trade.Sell(lotSize); // Open a sell trade
     }
  }
//+------------------------------------------------------------------+
//| Get total number of open trades for the current symbol           |
//+------------------------------------------------------------------+
int TotalOpenTrades()
  {
   int totalTrades = 0; // Initialize total trades counter

   //--- loop through all open positions
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i); // Get position ticket
      if(PositionSelect(IntegerToString(ticket)))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol) // Check if position is for the current symbol
           {
            totalTrades++; // Increment the total trades counter
           }
        }
     }
   return totalTrades; // Return the total number of open trades
  }
//+------------------------------------------------------------------+
//| Calculate Lot Size based on risk percentage                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent)
  {
   double lotSize = 0.01; // Minimum lot size
   double balance = AccountInfoDouble(ACCOUNT_BALANCE); // Get account balance
   double riskAmount = balance * riskPercent / 100.0;   // Calculate risk amount
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Get tick value
   double stopLossPoints = 100; // Example stop loss in points

   lotSize = riskAmount / (stopLossPoints * tickValue); // Calculate lot size based on risk

   //--- Normalize lot size to the nearest valid lot size increment
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lotSize = MathFloor(lotSize / lotStep) * lotStep;

   return lotSize; // Return the calculated lot size
  }
