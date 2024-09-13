//+------------------------------------------------------------------+
//|                                              SimpleDataTypes.mq4 |
//|                                                      Qubec Forex |
//|                                            https://forex.quebec/ |
//+------------------------------------------------------------------+
#property copyright "Qubec Forex"
#property link      "https://forex.quebec/"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   string Text="The current value is:";
   datetime MyTime=TimeLocal();
   Comment(Text,MyTime);



  }
//+------------------------------------------------------------------+
