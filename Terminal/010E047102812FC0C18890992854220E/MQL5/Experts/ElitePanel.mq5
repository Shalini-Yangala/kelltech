//+------------------------------------------------------------------+
//|                                                   ElitePanel.mq5 |
//|                                        Copyright 2024, FX Empire |
//|                                         http://www.fxempire.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, FX Empire"
#property link      "http://www.fxempire.com/"
#property version   "1.00"
#include <Trade\Trade.mqh>
//--- input parameters
input int    ElliottWavePeriod = 21; // Elliott Wave period
input int    RSI_Period = 14;        // RSI Period
input int    CCI_Period = 14;        // CCI Period
input int    Volume_Period = 14;     // Volume Period
input double RiskPercent = 1.0;      // Risk per trade as a percentage of equity
input bool   AlertsOn = true;        // Enable/Disable alerts
input int    RSIOverbought = 70;
input int    RSIOversold = 30;
input int    StochasticOverbought = 80;
input int    StochasticOversold = 20;
input int    CCIOverbought = 100;
input int    CCIOversold = -100;
input int                  Bands_Period=20;           // period of moving average
input int                  bands_shift=0;             // shift
input double               bandsdeviation=2.0;        // number of standard deviations
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // type of price
input int                  Kperiod=5;                 // the K period (the number of bars for calculation)
input int                  Dperiod=3;                 // the D period (the period of primary smoothing)
input int                  slowing=3;                 // period of final smoothing
input ENUM_MA_METHOD       ma_method=MODE_SMA;        // type of smoothing
input ENUM_STO_PRICE       price_field=STO_LOWHIGH;   // method of calculation of the Stochastic
//--- global variables
CTrade trade;
//--- indicator handles
int handle_RSI, handle_Stochastic, handle_CCI, handle_Bands, handle_Volume;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- initialize indicators
   handle_Bands = iBands(_Symbol, _Period, Bands_Period, bands_shift, bandsdeviation, applied_price);
   handle_RSI = iRSI(_Symbol, _Period, RSI_Period, applied_price);
   handle_Stochastic = iStochastic(_Symbol, _Period, Kperiod, Dperiod, slowing, ma_method, price_field);
   handle_CCI = iCCI(_Symbol, _Period, CCI_Period, applied_price);
   handle_Volume = iVolumes(_Symbol,_Period,0);
   if (handle_RSI == INVALID_HANDLE || handle_Stochastic == INVALID_HANDLE || handle_CCI == INVALID_HANDLE ||
       handle_Bands == INVALID_HANDLE || handle_Volume == INVALID_HANDLE)
   {
      Print("Error initializing indicators.");
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- release indicator handles
   if (handle_RSI != INVALID_HANDLE)
      IndicatorRelease(handle_RSI);
   if (handle_Stochastic != INVALID_HANDLE)
      IndicatorRelease(handle_Stochastic);
   if (handle_CCI != INVALID_HANDLE)
      IndicatorRelease(handle_CCI);
   if (handle_Bands != INVALID_HANDLE)
      IndicatorRelease(handle_Bands);
   if (handle_Volume != INVALID_HANDLE)
      IndicatorRelease(handle_Volume);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double RSIBuffer[3], StochasticBuffer[3], CCIBuffer[3], VolumeBuffer[3];
   //--- get the current and previous values of each indicator
   double bands_upper, bands_lower;
   double bands_values[3];
   if (CopyBuffer(handle_Bands, 1, 0, 3, bands_values) > 0)
   {
      bands_upper = bands_values[0];
      bands_lower = bands_values[2];
   }
   else
   {
      Print("Error getting Bands values");
      return;
   }
   //--- get RSI values
   if (CopyBuffer(handle_RSI, 0, 0, 3, RSIBuffer) <= 0)
   {
      Print("Error getting RSI values");
      return;
   }
   //--- get Stochastic values
   if (CopyBuffer(handle_Stochastic, 0, 0, 3, StochasticBuffer) <= 0)
   {
      Print("Error getting Stochastic values");
      return;
   }
   //--- get CCI values
   if (CopyBuffer(handle_CCI, 0, 0, 3, CCIBuffer) <= 0)
   {
      Print("Error getting CCI values");
      return;
   }
   //--- get Volume values
   if (CopyBuffer(handle_Volume, 0, 0, 3, VolumeBuffer) <= 0)
   {
      Print("Error getting Volume values");
      return;
   }
   double rsi_current = RSIBuffer[0];
   double rsi_previous = RSIBuffer[1];
   double stochastic_current = StochasticBuffer[0];
   double stochastic_previous = StochasticBuffer[1];
   double cci_current = CCIBuffer[0];
   double cci_previous = CCIBuffer[1];
   double volume_current = VolumeBuffer[0];
   double volume_previous = VolumeBuffer[1];
   //--- simple logic for Elliott Wave
   double price = iClose(_Symbol, PERIOD_CURRENT, 0);
   double price_previous = iClose(_Symbol, PERIOD_CURRENT, 1);
   bool wave_up = price > (price - ElliottWavePeriod);
   bool wave_down = price < (price + ElliottWavePeriod);
   //--- confluence logic
   bool buy_signal = rsi_current < RSIOverbought && rsi_previous < RSIOverbought &&
                     stochastic_current < StochasticOverbought && stochastic_previous < StochasticOverbought &&
                     cci_current < CCIOverbought && cci_previous < CCIOverbought &&
                     price < bands_lower && price_previous < bands_lower &&
                     volume_current > 1.5 * volume_previous && wave_up;
   bool sell_signal = rsi_current > RSIOversold && rsi_previous > RSIOversold &&
                      stochastic_current > StochasticOversold && stochastic_previous > StochasticOversold &&
                      cci_current > CCIOversold && cci_previous > CCIOversold &&
                      price > bands_upper && price_previous > bands_upper &&
                      volume_current > 1.5 * volume_previous && wave_down;
   double lotSize = CalculateLotSize(RiskPercent);
   //--- buy condition
   if (buy_signal)
   {
      trade.Buy(lotSize);
      if (AlertsOn) Alert("Buy signal triggered.");
      DrawElliottWaves();
      
   }
   //--- sell condition
   if (sell_signal)
   {
      trade.Sell(lotSize);
      if (AlertsOn) Alert("Sell signal triggered.");
      DrawElliottWaves();
     
   }
}
//+------------------------------------------------------------------+
//| Calculate Lot Size function                                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent)
{
   double lotSize = 0.01; // Minimum lot size
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * riskPercent / 100.0;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double stopLossPoints = 100; // Example stop loss
   lotSize = riskAmount / (stopLossPoints * tickValue);
   // Normalize lot size to the nearest valid lot size increment
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   return lotSize;
}
//+------------------------------------------------------------------+
//| Function to draw Elliott waves                                   |
//+------------------------------------------------------------------+
void DrawElliottWaves()
{
    // Elliott wave detection and drawing
    int bars = iBars(_Symbol, PERIOD_CURRENT);
    if (bars < 50) return;
    // Detect waves
    for (int i = 50; i < bars; i += 50)
    {
        double price1 = iClose(_Symbol, PERIOD_CURRENT, i);
        double price2 = iClose(_Symbol, PERIOD_CURRENT, i + 20);
        double price3 = iClose(_Symbol, PERIOD_CURRENT, i + 40);
        double price4 = iClose(_Symbol, PERIOD_CURRENT, i + 60);
        double price5 = iClose(_Symbol, PERIOD_CURRENT, i + 80);
        // Draw lines for waves
        ObjectCreate(0, "Wave" + IntegerToString(i), OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, i), price1, iTime(_Symbol, PERIOD_CURRENT, i + 20), price2);
        ObjectCreate(0, "Wave" + IntegerToString(i + 20), OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, i + 20), price2, iTime(_Symbol, PERIOD_CURRENT, i + 40), price3);
        ObjectCreate(0, "Wave" + IntegerToString(i + 40), OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, i + 40), price3, iTime(_Symbol, PERIOD_CURRENT, i + 60), price4);
        ObjectCreate(0, "Wave" + IntegerToString(i + 60), OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, i + 60), price4, iTime(_Symbol, PERIOD_CURRENT, i + 80), price5);
        ObjectCreate(0, "Wave" + IntegerToString(i + 60), OBJ_TREND, 0, iTime(_Symbol, PERIOD_CURRENT, i + 60), price4, iTime(_Symbol, PERIOD_CURRENT, i + 80), price5);
    }
}