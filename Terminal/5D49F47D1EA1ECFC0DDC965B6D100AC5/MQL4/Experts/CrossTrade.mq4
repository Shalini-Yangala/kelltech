//+------------------------------------------------------------------+
//|                                                   CrossTrade.mq4 |
//|                                                     Qubec Forex. |
//|                                            https://forex.quebec/ |
//+------------------------------------------------------------------+
#property copyright "Qubec Forex."
#property link      "https://forex.quebec/"
#property version   "1.00"
#property strict
// Declare input parameters
input int    ShortPeriod = 10;  // Short period for SMA
input int    LongPeriod = 30;   // Long period for SMA
// List of Forex assets
string ForexSymbols[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "USDCAD", "AUDUSD", "NZDUSD"};

double EURUSDShortMA,GBPUSDShortMA,AUDUSDShortMA,USDCADShortMA,USDJPYShortMA,USDCHFShortMA,NZDUSDShortMA;
double EURUSDFastMA,GBPUSDFastMA,AUDUSDFastMA,USDCADFastMA,USDJPYFastMA,USDCHFFastMA,NZDUSDFastMA;
double EURUSDPreShortMA,GBPUSDPreShortMA,AUDUSDPreShortMA,USDCADPreShortMA,USDJPYPreShortMA,USDCHFPreShortMA,NZDUSDPreShortMA;
double EURUSDPreFastMA,GBPUSDPreFastMA,AUDUSDPreFastMA,USDCADPreFastMA,USDJPYPreFastMA,USDCHFPreFastMA,NZDUSDPreFastMA;
double EURUSDShortMA15,GBPUSDShortMA15,AUDUSDShortMA15,USDCADShortMA15,USDJPYShortMA15,USDCHFShortMA15,NZDUSDShortMA15;
double EURUSDFastMA15,GBPUSDFastMA15,AUDUSDFastMA15,USDCADFastMA15,USDJPYFastMA15,USDCHFFastMA15,NZDUSDFastMA15;
double EURUSDPreShortMA15,GBPUSDPreShortMA15,AUDUSDPreShortMA15,USDCADPreShortMA15,USDJPYPreShortMA15,USDCHFPreShortMA15,NZDUSDPreShortMA15;
double EURUSDPreFastMA15,GBPUSDPreFastMA15,AUDUSDPreFastMA15,USDCADPreFastMA15,USDJPYPreFastMA15,USDCHFPreFastMA15,NZDUSDPreFastMA15;
double EURUSDCrossOver,GBPUSDCrossOver,AUDUSDCrossOver,USDCADCrossOver,USDJPYCrossOver,USDCHFCrossOver,NZDUSDCrossOver;
double EURUSDTradeStatus,GBPUSDTradeStatus,AUDUSDTradeStatus,USDCADTradeStatus,USDJPYTradeStatus,USDCHFTradeStatus,NZDUSDTradeStatus;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
// Check if the current symbol is a Forex asset
   if(!IsForexSymbol(Symbol()))
     {
      Print("This EA works only with Forex assets.");
      return(INIT_FAILED);
     }

// Check if the current timeframe is 5M or 15M
   if(Period() != PERIOD_M5 && Period() != PERIOD_M15)
     {
      Print("This EA works only on 5M and 15M timeframes.");
      return(INIT_FAILED);
     }
   LeftSideDashborad();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,"BackPanel");
   ObjectDelete(0,"SubPanel");
   ObjectDelete(0,"SubPanel1");
   ObjectDelete(0,"SubPanel2");
   ObjectDelete(0,"ShortMA");
   ObjectDelete(0,"LongMA");
   ObjectDelete(0,"CrossOver");
   ObjectDelete(0,"TradeStatus");
   ObjectDelete(0,"EURUSD");
   ObjectDelete(0,"GBPUSD");
   ObjectDelete(0,"AUDUSD");
   ObjectDelete(0,"USDCAD");
   ObjectDelete(0,"USDJPY");
   ObjectDelete(0,"USDCHF");
   ObjectDelete(0,"NZDUSD");
   ObjectDelete(0,"EURUSDCCIValue");
   ObjectDelete(0,"GBPUSDCCIValue");
   ObjectDelete(0,"AUDUSDCCIValue");
   ObjectDelete(0,"USDCADCCIValue");
   ObjectDelete(0,"USDJPYCCIValue");
   ObjectDelete(0,"USDCHFCCIValue");
   ObjectDelete(0,"NZDUSDCCIValue");
   ObjectDelete(0,"EURUSDMOMValue");
   ObjectDelete(0,"GBPUSDMOMValue");
   ObjectDelete(0,"AUDUSDMOMValue");
   ObjectDelete(0,"USDCADMOMValue");
   ObjectDelete(0,"USDJPYMOMValue");
   ObjectDelete(0,"USDCHFMOMValue");
   ObjectDelete(0,"NZDUSDMOMValue");
   ObjectDelete(0,"EURUSDRSIValue");
   ObjectDelete(0,"GBPUSDRSIValue");
   ObjectDelete(0,"AUDUSDRSIValue");
   ObjectDelete(0,"USDCADRSIValue");
   ObjectDelete(0,"USDJPYRSIValue");
   ObjectDelete(0,"USDCHFRSIValue");
   ObjectDelete(0,"NZDUSDRSIValue");
   ObjectDelete(0,"EURUSDSTOValue");
   ObjectDelete(0,"GBPUSDSTOValue");
   ObjectDelete(0,"AUDUSDSTOValue");
   ObjectDelete(0,"USDCADSTOValue");
   ObjectDelete(0,"USDJPYSTOValue");
   ObjectDelete(0,"USDCHFSTOValue");
   ObjectDelete(0,"NZDUSDSTOValue");
   ObjectDelete(0,"EURUSDSTValue");
   ObjectDelete(0,"GBPUSDSTValue");
   ObjectDelete(0,"AUDUSDSTValue");
   ObjectDelete(0,"USDCADSTValue");
   ObjectDelete(0,"USDJPYSTValue");
   ObjectDelete(0,"USDCHFSTValue");
   ObjectDelete(0,"NZDUSDSTValue");
   ObjectDelete(0,"EURUSDMAValue");
   ObjectDelete(0,"GBPUSDMAValue");
   ObjectDelete(0,"AUDUSDMAValue");
   ObjectDelete(0,"USDCADMAValue");
   ObjectDelete(0,"USDJPYMAValue");
   ObjectDelete(0,"USDCHFMAValue");
   ObjectDelete(0,"NZDUSDMAValue");
   ObjectDelete(0,"EURUSDCCIBUY/SELL");
   ObjectDelete(0,"GBPUSDCCIBUY/SELL");
   ObjectDelete(0,"AUDUSDCCIBUY/SELL");
   ObjectDelete(0,"USDCADCCIBUY/SELL");
   ObjectDelete(0,"USDJPYCCIBUY/SELL");
   ObjectDelete(0,"USDCHFCCIBUY/SELL");
   ObjectDelete(0,"NZDUSDCCIBUY/SELL");
   ObjectDelete(0,"EURUSDMOMBUY/SELL");
   ObjectDelete(0,"GBPUSDMOMBUY/SELL");
   ObjectDelete(0,"AUDUSDMOMBUY/SELL");
   ObjectDelete(0,"USDCADMOMBUY/SELL");
   ObjectDelete(0,"USDJPYMOMBUY/SELL");
   ObjectDelete(0,"USDCHFMOMBUY/SELL");
   ObjectDelete(0,"NZDUSDMOMBUY/SELL");
   ObjectDelete(0,"EURUSDRSIBUY/SELL");
   ObjectDelete(0,"GBPUSDRSIBUY/SELL");
   ObjectDelete(0,"AUDUSDRSIBUY/SELL");
   ObjectDelete(0,"USDCADRSIBUY/SELL");
   ObjectDelete(0,"USDJPYRSIBUY/SELL");
   ObjectDelete(0,"USDCHFRSIBUY/SELL");
   ObjectDelete(0,"NZDUSDRSIBUY/SELL");
   ObjectDelete(0,"EURUSDSTOBUY/SELL");
   ObjectDelete(0,"GBPUSDSTOBUY/SELL");
   ObjectDelete(0,"AUDUSDSTOBUY/SELL");
   ObjectDelete(0,"USDCADSTOBUY/SELL");
   ObjectDelete(0,"USDJPYSTOBUY/SELL");
   ObjectDelete(0,"USDCHFSTOBUY/SELL");
   ObjectDelete(0,"NZDUSDSTOBUY/SELL");
   ObjectDelete(0,"EURUSDSTBUY/SELL");
   ObjectDelete(0,"GBPUSDSTBUY/SELL");
   ObjectDelete(0,"AUDUSDSTBUY/SELL");
   ObjectDelete(0,"USDCADSTBUY/SELL");
   ObjectDelete(0,"USDJPYSTBUY/SELL");
   ObjectDelete(0,"USDCHFSTBUY/SELL");
   ObjectDelete(0,"NZDUSDSTBUY/SELL");
   ObjectDelete(0,"EURUSDMABUY/SELL");
   ObjectDelete(0,"GBPUSDMABUY/SELL");
   ObjectDelete(0,"AUDUSDMABUY/SELL");
   ObjectDelete(0,"USDCADMABUY/SELL");
   ObjectDelete(0,"USDJPYMABUY/SELL");
   ObjectDelete(0,"USDCHFMABUY/SELL");
   ObjectDelete(0,"NZDUSDMABUY/SELL");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
// Calculate current and previous SMAs
   EURUSDShortMA = iMA("EURUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   EURUSDFastMA = iMA("EURUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   EURUSDPreShortMA = iMA("EURUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   EURUSDPreFastMA = iMA("EURUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   EURUSDShortMA15 = iMA("EURUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   EURUSDFastMA15 = iMA("EURUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   EURUSDPreShortMA15 = iMA("EURUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   EURUSDPreFastMA15 = iMA("EURUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "EURUSDMOMValue", OBJPROP_TEXT,DoubleToString(EURUSDShortMA,2));
   ObjectSetString(0, "EURUSDRSIValue", OBJPROP_TEXT, DoubleToString(EURUSDFastMA,2));
   ObjectSetString(0, "EURUSDMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(EURUSDShortMA15,2));
   ObjectSetString(0, "EURUSDRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(EURUSDFastMA15,2));
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "EURUSDRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(EURUSDPreShortMA,EURUSDPreFastMA,EURUSDShortMA,EURUSDFastMA,EURUSDPreShortMA15,EURUSDPreFastMA15,EURUSDShortMA15,EURUSDFastMA15,"EURUSDSTOValue","EURUSDSTOBUY/SELL");
   isPositionOpenForSymbol("EURUSD");
   CheckPosition("EURUSD","EURUSDSTValue");


   GBPUSDShortMA = iMA("GBPUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   GBPUSDFastMA = iMA("GBPUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   GBPUSDPreShortMA = iMA("GBPUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   GBPUSDPreFastMA = iMA("GBPUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   GBPUSDShortMA15 = iMA("GBPUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   GBPUSDFastMA15 = iMA("GBPUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   GBPUSDPreShortMA15 = iMA("GBPUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   GBPUSDPreFastMA15 = iMA("GBPUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "GBPUSDMOMValue", OBJPROP_TEXT,DoubleToString(GBPUSDShortMA,2));
   ObjectSetString(0, "GBPUSDRSIValue", OBJPROP_TEXT, DoubleToString(GBPUSDFastMA,2));
   ObjectSetString(0, "GBPUSDMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(GBPUSDShortMA15,2));
   ObjectSetString(0, "GBPUSDRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(GBPUSDFastMA15,2));
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "GBPUSDRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(GBPUSDPreShortMA,GBPUSDPreFastMA,GBPUSDShortMA,GBPUSDFastMA,GBPUSDPreShortMA15,GBPUSDPreFastMA15,GBPUSDShortMA15,GBPUSDFastMA15,"GBPUSDSTOValue","GBPUSDSTOBUY/SELL");
   isPositionOpenForSymbol("GBPUSD");
   CheckPosition("GBPUSD","GBPUSDSTValue");


   AUDUSDShortMA = iMA("AUDUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   AUDUSDFastMA = iMA("AUDUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   AUDUSDPreShortMA = iMA("AUDUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   AUDUSDPreFastMA = iMA("AUDUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   AUDUSDShortMA15 = iMA("AUDUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   AUDUSDFastMA15 = iMA("AUDUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   AUDUSDPreShortMA15 = iMA("AUDUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   AUDUSDPreFastMA15 = iMA("AUDUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "AUDUSDMOMValue", OBJPROP_TEXT,DoubleToString(AUDUSDShortMA,2));
   ObjectSetString(0, "AUDUSDRSIValue", OBJPROP_TEXT, DoubleToString(AUDUSDFastMA,2));
   ObjectSetString(0, "AUDUSDMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(AUDUSDShortMA15,2));
   ObjectSetString(0, "AUDUSDRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(AUDUSDFastMA15,2));
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "AUDUSDRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(AUDUSDPreShortMA,AUDUSDPreFastMA,AUDUSDShortMA,AUDUSDFastMA,AUDUSDPreShortMA15,AUDUSDPreFastMA15,AUDUSDShortMA15,AUDUSDFastMA15,"AUDUSDSTOValue","AUDUSDSTOBUY/SELL");
   isPositionOpenForSymbol("AUDUSD");
   CheckPosition("AUDUSD","AUDUSDSTValue");



   USDCADShortMA = iMA("USDCAD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCADFastMA = iMA("USDCAD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCADPreShortMA = iMA("USDCAD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDCADPreFastMA = iMA("USDCAD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   USDCADShortMA15 = iMA("GBPUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCADFastMA15 = iMA("GBPUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCADPreShortMA15 = iMA("GBPUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDCADPreFastMA15 = iMA("GBPUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "USDCADMOMValue", OBJPROP_TEXT,DoubleToString(USDCADShortMA,2));
   ObjectSetString(0, "USDCADRSIValue", OBJPROP_TEXT, DoubleToString(USDCADFastMA,2));
   ObjectSetString(0, "USDCADMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(USDCADShortMA15,2));
   ObjectSetString(0, "USDCADRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(USDCADFastMA15,2));
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "USDCADRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(USDCADPreShortMA,USDCADPreFastMA,USDCADShortMA,USDCADFastMA,USDCADPreShortMA15,USDCADPreFastMA15,USDCADShortMA15,USDCADFastMA15,"USDCADSTOValue","USDCADSTOBUY/SELL");
   isPositionOpenForSymbol("USDCAD");
   CheckPosition("USDCAD","USDCADSTValue");



   USDJPYShortMA = iMA("USDJPY", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDJPYFastMA = iMA("USDJPY", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDJPYPreShortMA = iMA("USDJPY", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDJPYPreFastMA = iMA("USDJPY", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   USDJPYShortMA15 = iMA("USDJPY", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDJPYFastMA15 = iMA("USDJPY", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDJPYPreShortMA15 = iMA("USDJPY", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDJPYPreFastMA15 = iMA("USDJPY", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "USDJPYMOMValue", OBJPROP_TEXT,DoubleToString(USDJPYShortMA,2));
   ObjectSetString(0, "USDJPYRSIValue", OBJPROP_TEXT, DoubleToString(USDJPYFastMA,2));
   ObjectSetString(0, "USDJPYMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(USDJPYShortMA15,2));
   ObjectSetString(0, "USDJPYRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(USDJPYFastMA15,2));
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "USDJPYRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(USDJPYPreShortMA,USDJPYPreFastMA,USDJPYShortMA,USDJPYFastMA,USDJPYPreShortMA15,USDJPYPreFastMA15,USDJPYShortMA15,USDJPYFastMA15,"USDJPYSTOValue","USDJPYSTOBUY/SELL");
   isPositionOpenForSymbol("USDJPY");
   CheckPosition("USDJPY","USDJPYSTValue");



   USDCHFShortMA = iMA("USDCHF", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCHFFastMA = iMA("USDCHF", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCHFPreShortMA = iMA("USDCHF", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDCHFPreFastMA = iMA("USDCHF", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   USDCHFShortMA15 = iMA("USDCHF", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCHFFastMA15 = iMA("USDCHF", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   USDCHFPreShortMA15 = iMA("USDCHF", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   USDCHFPreFastMA15 = iMA("USDCHF", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "USDCHFMOMValue", OBJPROP_TEXT,DoubleToString(USDCHFShortMA,2));
   ObjectSetString(0, "USDCHFRSIValue", OBJPROP_TEXT, DoubleToString(USDCHFFastMA,2));
   ObjectSetString(0, "USDCHFMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(USDCHFShortMA15,2));
   ObjectSetString(0, "USDCHFRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(USDCHFFastMA15,2));
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "USDCHFRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(USDCHFPreShortMA,USDCHFPreFastMA,USDCHFShortMA,USDCHFFastMA,USDCHFPreShortMA15,USDCHFPreFastMA15,USDCHFShortMA15,USDCHFFastMA15,"USDCHFSTOValue","USDCHFSTOBUY/SELL");
   isPositionOpenForSymbol("USDCHF");
   CheckPosition("USDCHF","USDCHFSTValue");



   NZDUSDShortMA = iMA("NZDUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   NZDUSDFastMA = iMA("NZDUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   NZDUSDPreShortMA = iMA("NZDUSD", PERIOD_M5, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   NZDUSDPreFastMA = iMA("NZDUSD", PERIOD_M5, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   NZDUSDShortMA15 = iMA("NZDUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   NZDUSDFastMA15 = iMA("NZDUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   NZDUSDPreShortMA15 = iMA("NZDUSD", PERIOD_M15, ShortPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   NZDUSDPreFastMA15 = iMA("NZDUSD", PERIOD_M15, LongPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);

   ObjectSetString(0, "NZDUSDMOMValue", OBJPROP_TEXT,DoubleToString(NZDUSDShortMA,2));
   ObjectSetString(0, "NZDUSDRSIValue", OBJPROP_TEXT, DoubleToString(NZDUSDFastMA,2));
   ObjectSetString(0, "NZDUSDMOMBUY/SELL", OBJPROP_TEXT,DoubleToString(NZDUSDShortMA15,2));
   ObjectSetString(0, "NZDUSDRSIBUY/SELL", OBJPROP_TEXT, DoubleToString(NZDUSDFastMA15,2));
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "NZDUSDRSIBUY/SELL", OBJPROP_COLOR, clrRed);
   CheckCrossOver(NZDUSDPreShortMA,NZDUSDPreFastMA,NZDUSDShortMA,NZDUSDFastMA,NZDUSDPreShortMA15,NZDUSDPreFastMA15,NZDUSDShortMA15,NZDUSDFastMA15,"NZDUSDSTOValue","NZDUSDSTOBUY/SELL");
   isPositionOpenForSymbol("NZDUSD");
   CheckPosition("NZDUSD","NZDUSDSTValue");
  }
//+------------------------------------------------------------------+
//| Dashboard function                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LeftSideDashborad()
  {
   ObjectCreate(0, "BackPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "BackPanel", OBJPROP_XSIZE, 850);
   ObjectSetInteger(0, "BackPanel", OBJPROP_YSIZE, 230);
   ObjectSetInteger(0, "BackPanel", OBJPROP_XDISTANCE, 400);
   ObjectSetInteger(0, "BackPanel", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "BackPanel", OBJPROP_BGCOLOR, clrLightGreen);
   ObjectSetInteger(0, "BackPanel", OBJPROP_BACK, true);

   ObjectCreate(0, "SubPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "SubPanel", OBJPROP_XSIZE, 830);
   ObjectSetInteger(0, "SubPanel", OBJPROP_YSIZE, 210);
   ObjectSetInteger(0, "SubPanel", OBJPROP_XDISTANCE, 410);
   ObjectSetInteger(0, "SubPanel", OBJPROP_YDISTANCE, 40);
   ObjectSetInteger(0, "SubPanel", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "SubPanel", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "SubPanel", OBJPROP_BACK, true);

   ObjectCreate(0, "SubPanel1", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_XSIZE, 830);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_YSIZE, 75);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_XDISTANCE, 410);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_YDISTANCE, 40);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_BGCOLOR, clrYellow);
   ObjectSetInteger(0, "SubPanel1", OBJPROP_BACK, true);

   ObjectCreate(0, "SubPanel2", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_XSIZE, 830);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_YSIZE, 145);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_XDISTANCE, 410);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_YDISTANCE, 105);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_BGCOLOR, clrSkyBlue);
   ObjectSetInteger(0, "SubPanel2", OBJPROP_BACK, true);

   ObjectCreate(0, "ShortMA", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "ShortMA", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "ShortMA", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "ShortMA", OBJPROP_YDISTANCE, 120);
   ObjectSetString(0, "ShortMA", OBJPROP_TEXT, "Short MA ");
   ObjectSetInteger(0, "ShortMA", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "LongMA", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "LongMA", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "LongMA", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "LongMA", OBJPROP_YDISTANCE, 150);
   ObjectSetString(0, "LongMA", OBJPROP_TEXT, "Long MA ");
   ObjectSetInteger(0, "LongMA", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "CrossOver", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "CrossOver", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "CrossOver", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "CrossOver", OBJPROP_YDISTANCE, 180);
   ObjectSetString(0, "CrossOver", OBJPROP_TEXT, "CrossOver ");
   ObjectSetInteger(0, "CrossOver", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "TradeStatus", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "TradeStatus", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "TradeStatus", OBJPROP_XDISTANCE, 420);
   ObjectSetInteger(0, "TradeStatus", OBJPROP_YDISTANCE, 210);
   ObjectSetString(0, "TradeStatus", OBJPROP_TEXT, "Trade Status ");
   ObjectSetInteger(0, "TradeStatus", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "EURUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSD", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "EURUSD", OBJPROP_TEXT, "EURUSD");
   ObjectSetInteger(0, "EURUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "GBPUSD", OBJPROP_TEXT, "GBPUSD");
   ObjectSetInteger(0, "GBPUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "AUDUSD", OBJPROP_TEXT, "AUDUSD");
   ObjectSetInteger(0, "AUDUSD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCAD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCAD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCAD", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCAD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDCAD", OBJPROP_TEXT, "USDCAD");
   ObjectSetInteger(0, "USDCAD", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPY", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPY", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPY", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPY", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDJPY", OBJPROP_TEXT, "USDJPY");
   ObjectSetInteger(0, "USDJPY", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHF", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHF", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHF", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHF", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "USDCHF", OBJPROP_TEXT, "USDCHF");
   ObjectSetInteger(0, "USDCHF", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSD", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSD", OBJPROP_YDISTANCE, 60);
   ObjectSetString(0, "NZDUSD", OBJPROP_TEXT, "NZDUSD");
   ObjectSetInteger(0, "NZDUSD", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "EURUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "EURUSDCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "EURUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "GBPUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "GBPUSDCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "GBPUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "AUDUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "AUDUSDCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "AUDUSDCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDCADCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDCADCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "USDCADCCIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDJPYCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDJPYCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "USDJPYCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDCHFCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "USDCHFCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDCCIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "NZDUSDCCIValue", OBJPROP_TEXT, "M5   | ");
   ObjectSetInteger(0, "NZDUSDCCIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "EURUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "GBPUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "AUDUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCADMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDCADMOMValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDJPYMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDJPYMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "USDCHFMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDMOMValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, "NZDUSDMOMValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDRSIValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "EURUSDRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDRSIValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "GBPUSDRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDRSIValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "AUDUSDRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCADRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADRSIValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDCADRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPYRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYRSIValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDJPYRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFRSIValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "USDCHFRSIValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDRSIValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDRSIValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDRSIValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDRSIValue", OBJPROP_YDISTANCE, 150);
   ObjectSetInteger(0, "NZDUSDRSIValue", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "EURUSDSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDSTOValue", OBJPROP_XDISTANCE, 540);
   ObjectSetInteger(0, "EURUSDSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "EURUSDSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDSTOValue", OBJPROP_XDISTANCE, 640);
   ObjectSetInteger(0, "GBPUSDSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "GBPUSDSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDSTOValue", OBJPROP_XDISTANCE, 740);
   ObjectSetInteger(0, "AUDUSDSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "AUDUSDSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCADSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADSTOValue", OBJPROP_XDISTANCE, 840);
   ObjectSetInteger(0, "USDCADSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "USDCADSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPYSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYSTOValue", OBJPROP_XDISTANCE, 940);
   ObjectSetInteger(0, "USDJPYSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "USDJPYSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFSTOValue", OBJPROP_XDISTANCE, 1040);
   ObjectSetInteger(0, "USDCHFSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "USDCHFSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDSTOValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDSTOValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDSTOValue", OBJPROP_XDISTANCE, 1140);
   ObjectSetInteger(0, "NZDUSDSTOValue", OBJPROP_YDISTANCE, 180);
   ObjectSetInteger(0, "NZDUSDSTOValue", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDSTValue", OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, "EURUSDSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "GBPUSDSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDSTValue", OBJPROP_XDISTANCE, 650);
   ObjectSetInteger(0, "GBPUSDSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "AUDUSDSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDSTValue", OBJPROP_XDISTANCE, 750);
   ObjectSetInteger(0, "AUDUSDSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "USDCADSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADSTValue", OBJPROP_XDISTANCE, 850);
   ObjectSetInteger(0, "USDCADSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "USDJPYSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYSTValue", OBJPROP_XDISTANCE, 950);
   ObjectSetInteger(0, "USDJPYSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "USDCHFSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFSTValue", OBJPROP_XDISTANCE, 1050);
   ObjectSetInteger(0, "USDCHFSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "NZDUSDSTValue", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDSTValue", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDSTValue", OBJPROP_XDISTANCE, 1150);
   ObjectSetInteger(0, "NZDUSDSTValue", OBJPROP_YDISTANCE, 210);

   ObjectCreate(0, "EURUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetString(0, "EURUSDCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "EURUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "GBPUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetString(0, "GBPUSDCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetInteger(0, "GBPUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "AUDUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "AUDUSDCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "AUDUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "USDCADCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDCADCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "USDCADCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDJPYCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDJPYCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "USDJPYCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "USDCHFCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "USDCHFCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "USDCHFCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "NZDUSDCCIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_YDISTANCE, 90);
   ObjectSetString(0, "NZDUSDCCIBUY/SELL", OBJPROP_TEXT, "M15 ");
   ObjectSetInteger(0, "NZDUSDCCIBUY/SELL", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "EURUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);


   ObjectCreate(0, "GBPUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "AUDUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDCADMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDJPYMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "USDCHFMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "NZDUSDMOMBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDMOMBUY/SELL", OBJPROP_YDISTANCE, 120);

   ObjectCreate(0, "EURUSDRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDRSIBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "GBPUSDRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDRSIBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "AUDUSDRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDRSIBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDCADRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADRSIBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDJPYRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYRSIBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "USDCHFRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFRSIBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "NZDUSDRSIBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDRSIBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDRSIBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDRSIBUY/SELL", OBJPROP_YDISTANCE, 150);

   ObjectCreate(0, "EURUSDSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "EURUSDSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "EURUSDSTOBUY/SELL", OBJPROP_XDISTANCE, 590);
   ObjectSetInteger(0, "EURUSDSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "GBPUSDSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GBPUSDSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "GBPUSDSTOBUY/SELL", OBJPROP_XDISTANCE, 690);
   ObjectSetInteger(0, "GBPUSDSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "AUDUSDSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AUDUSDSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "AUDUSDSTOBUY/SELL", OBJPROP_XDISTANCE, 790);
   ObjectSetInteger(0, "AUDUSDSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "USDCADSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCADSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCADSTOBUY/SELL", OBJPROP_XDISTANCE, 890);
   ObjectSetInteger(0, "USDCADSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "USDJPYSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDJPYSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDJPYSTOBUY/SELL", OBJPROP_XDISTANCE, 990);
   ObjectSetInteger(0, "USDJPYSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "USDCHFSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "USDCHFSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "USDCHFSTOBUY/SELL", OBJPROP_XDISTANCE, 1090);
   ObjectSetInteger(0, "USDCHFSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

   ObjectCreate(0, "NZDUSDSTOBUY/SELL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NZDUSDSTOBUY/SELL", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "NZDUSDSTOBUY/SELL", OBJPROP_XDISTANCE, 1190);
   ObjectSetInteger(0, "NZDUSDSTOBUY/SELL", OBJPROP_YDISTANCE, 180);

  }
//+------------------------------------------------------------------+
//| Check the CrossOver function                                     |
//+------------------------------------------------------------------+
void CheckCrossOver(double PreShortMA,double PreFastMA,double ShortMA,double FastMA,double PreShortMA15,double PreFastMA15,double ShortMA15,double FastMA15,string var1,string var2)
  {
// Update crossover status 5M chart
   if(PreShortMA <= PreFastMA && ShortMA > FastMA)
     {
      ObjectSetString(0, var1, OBJPROP_TEXT,"Bullish");
      ObjectSetInteger(0, var1, OBJPROP_COLOR, clrGreen);
     }
   else
      if(PreShortMA >= PreFastMA && ShortMA < FastMA)
        {
         ObjectSetString(0, var1, OBJPROP_TEXT,"Bearish");
         ObjectSetInteger(0, var1, OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0, var1, OBJPROP_TEXT,"Neutral");
         ObjectSetInteger(0, var1, OBJPROP_COLOR, clrBlack);
        }

// Update crossover status for 15M Chart
   if(PreShortMA15 <= PreFastMA15 && ShortMA15 > FastMA15)
     {
      ObjectSetString(0, var2, OBJPROP_TEXT,"Bullish");
      ObjectSetInteger(0, var2, OBJPROP_COLOR, clrGreen);
     }
   else
      if(PreShortMA15 >= PreFastMA15 && ShortMA15 < FastMA15)
        {
         ObjectSetString(0, var2, OBJPROP_TEXT,"Bearish");
         ObjectSetInteger(0, var2, OBJPROP_COLOR, clrRed);
        }
      else
        {
         ObjectSetString(0, var2, OBJPROP_TEXT,"Neutral");
         ObjectSetInteger(0, var2, OBJPROP_COLOR, clrBlue);
        }
  }
//+------------------------------------------------------------------+
//| Check if there are any open positions for a particular symbol    |
//+------------------------------------------------------------------+
bool isPositionOpenForSymbol(string symbol)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == symbol)
           {
            return true;
           }
        }
     }
   return false;
  }
//+-----------------------------------------------------------------------------+
//|  Check for the recent opsition and Update the position in the dashboard     |
//+-----------------------------------------------------------------------------+
void CheckPosition(string symbol,string var2)
  {
   if(isPositionOpenForSymbol(symbol))
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == symbol)
              {
               if(OrderType() == OP_BUY)//EURUSDSTValue
                 {
                  ObjectSetString(0, var2, OBJPROP_TEXT,"Buy Position");
                  ObjectSetInteger(0, var2, OBJPROP_COLOR, clrGreen);
                 }
               else
                  if(OrderType() == OP_SELL)
                    {
                     ObjectSetString(0, var2, OBJPROP_TEXT,"Sell Position");
                     ObjectSetInteger(0, var2, OBJPROP_COLOR, clrRed);
                    }
              }
           }
        }
     }
   else
     {
      ObjectSetString(0, var2, OBJPROP_TEXT,"No Position");
      ObjectSetInteger(0, var2, OBJPROP_COLOR, clrBlack);
     }
  }
//+------------------------------------------------------------------+
//| Check if the symbol is a Forex asset                             |
//+------------------------------------------------------------------+
bool IsForexSymbol(string symbol)
  {
   for(int i = 0; i < ArraySize(ForexSymbols); i++)
     {
      if(StringFind(symbol, ForexSymbols[i]) != -1)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
