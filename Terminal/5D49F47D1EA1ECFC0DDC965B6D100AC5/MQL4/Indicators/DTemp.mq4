//+------------------------------------------------------------------+
//|                                                        DTemp.mq4 |
//|                               Copyright 2024, Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Blue
#property indicator_color4 Red

// Input parameters
extern int oscillator_type = 0; // 0: RSI, 1: MACD, 2: Stochastic
extern int rsi_oscillator_period = 14;
extern double rsi_overbought_level = 70;
extern double rsi_oversold_level = 30;
extern ENUM_MA_METHOD ma_type = MODE_SMA;
extern int Kperiod = 5;          // K line period
extern int Dperiod = 3;          // D line period
extern int slowing = 3;          // Slowing
extern double stoc_overbought_level = 80;
extern double stoc_oversold_level = 20;
extern int fast_ema_period = 12;  // Fast EMA period
extern int low_ema_period = 26;   // Slow EMA period
extern int signal_period = 9;     // Signal line period
extern ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;    // Applied price
extern double macd_threshold = 0;

// Indicator buffers
double SignalUpBuffer[];
double SignalDownBuffer[];
double SignalUpArrowBuffer[];
double SignalDownArrowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffers mapping
   SetIndexBuffer(0, SignalUpBuffer);
   SetIndexBuffer(1, SignalDownBuffer);
   SetIndexBuffer(2, SignalUpArrowBuffer);
   SetIndexBuffer(3, SignalDownArrowBuffer);
   
   // Set indicator labels and styles
   IndicatorShortName("DTemp");
   SetIndexLabel(0, "Signal Up");
   SetIndexLabel(1, "Signal Down");
   SetIndexLabel(2, "Buy Arrow");
   SetIndexLabel(3, "Sell Arrow");

   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 233); // Arrow code for buy signal
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234); // Arrow code for sell signal

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   // Ensure there are enough bars to calculate
   if(rates_total < 2)
      return 0;

   int startIdx = prev_calculated > 0 ? prev_calculated - 1 : 0;

   // Calculate divergence based on selected oscillator
   for(int i = startIdx; i < rates_total - 1; i++)
     {
      bool buy_signal = false;
      bool sell_signal = false;

      // RSI divergence
      if(oscillator_type == 0)
        {
         double rsi_value = iRSI(NULL, 0, rsi_oscillator_period, applied_price, i);
         double rsi_previous_value = iRSI(NULL, 0, rsi_oscillator_period, applied_price, i + 1);
         
         if(rsi_value < rsi_oversold_level && rsi_value > rsi_previous_value)
           {
            buy_signal = true;
           }
         else if(rsi_value > rsi_overbought_level && rsi_value < rsi_previous_value)
           {
            sell_signal = true;
           }
        }
      // MACD divergence
      else if(oscillator_type == 1)
        {
         double macd_value = iMACD(NULL, 0, fast_ema_period, low_ema_period, signal_period, applied_price, MODE_MAIN, i);
         double macd_previous_value = iMACD(NULL, 0, fast_ema_period, low_ema_period, signal_period, applied_price, MODE_MAIN, i + 1);
         
         if(macd_value < macd_threshold && macd_value > macd_previous_value)
           {
            buy_signal = true;
           }
         else if(macd_value > macd_threshold && macd_value < macd_previous_value)
           {
            sell_signal = true;
           }
        }
      // Stochastic divergence
      else if(oscillator_type == 2)
        {
         double stoc_value = iStochastic(NULL, 0, Kperiod, Dperiod, slowing, ma_type, 0, MODE_MAIN, i);
         double stoc_previous_value = iStochastic(NULL, 0, Kperiod, Dperiod, slowing, ma_type, 0, MODE_MAIN, i + 1);
         
         if(stoc_value < stoc_oversold_level && stoc_value > stoc_previous_value)
           {
            buy_signal = true;
           }
         else if(stoc_value > stoc_overbought_level && stoc_value < stoc_previous_value)
           {
            sell_signal = true;
           }
        }

      // Set arrow only if previous signal was not set
      if(buy_signal && (i == 0 || SignalUpArrowBuffer[i - 1] == EMPTY_VALUE))
        {
         SignalUpArrowBuffer[i] = low[i];
         SignalDownArrowBuffer[i] = EMPTY_VALUE;
        }
      else if(sell_signal && (i == 0 || SignalDownArrowBuffer[i - 1] == EMPTY_VALUE))
        {
         SignalDownArrowBuffer[i] = high[i];
         SignalUpArrowBuffer[i] = EMPTY_VALUE;
        }
      else
        {
         SignalUpBuffer[i] = EMPTY_VALUE;
         SignalDownBuffer[i] = EMPTY_VALUE;
         SignalUpArrowBuffer[i] = EMPTY_VALUE;
         SignalDownArrowBuffer[i] = EMPTY_VALUE;
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
