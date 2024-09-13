//+------------------------------------------------------------------+
//|                                                      CCTrend.mq4 |
//|                                                Guerrilla Trading |
//|                               http://www.guerrillatrading.co.uk/ |
//+------------------------------------------------------------------+
#property copyright "Guerrilla Trading"
#property link      "http://www.guerrillatrading.co.uk/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

// Indicator buffers
double BuyArrowBuffer[];
double SellArrowBuffer[];

// Input parameters
input int ATRPeriod = 14;
input int CorrPeriod = 14;
input double CorrThreshold = 0.5; // Correlation threshold for signals

// Last signal tracking
int lastSignal = 0; // 0: No signal, 1: Buy, -1: Sell

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorBuffers(2);
   SetIndexBuffer(0, BuyArrowBuffer);
   SetIndexBuffer(1, SellArrowBuffer);

   // Set arrow styles
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);

   // Set arrow codes
   SetIndexArrow(0, 233); // Up arrow
   SetIndexArrow(1, 234); // Down arrow

   // Set indicator labels
   SetIndexLabel(0, "Buy Arrow");
   SetIndexLabel(1, "Sell Arrow");

   // Initialize buffers with EMPTY_VALUE
   ArrayInitialize(BuyArrowBuffer, EMPTY_VALUE);
   ArrayInitialize(SellArrowBuffer, EMPTY_VALUE);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   // Check if there's enough data
   if (rates_total < MathMax(ATRPeriod, CorrPeriod))
      return (0);

   double atr[], meanATR[], corr, meanPrice, covar, varPrice, varATR;
   ArrayResize(atr, rates_total);
   ArrayResize(meanATR, rates_total);

   // Calculate ATR values
   for (int i = 0; i < rates_total; i++)
      atr[i] = iATR(NULL, 0, ATRPeriod, i);

   // Calculate mean ATR values
   for (int i = CorrPeriod - 1; i < rates_total; i++)
   {
      meanATR[i] = 0;
      for (int j = i - CorrPeriod + 1; j <= i; j++)
         meanATR[i] += atr[j];
      meanATR[i] /= CorrPeriod;
   }

   // Calculate correlation and generate signals
   for (int i = MathMax(CorrPeriod, ATRPeriod); i < rates_total; i++)
   {
      // Calculate mean price
      meanPrice = 0;
      for (int j = i - CorrPeriod + 1; j <= i; j++)
         meanPrice += close[j];
      meanPrice /= CorrPeriod;

      // Calculate covariance and variances
      covar = 0;
      varPrice = 0;
      varATR = 0;
      for (int k = i - CorrPeriod + 1; k <= i; k++)
      {
         covar += (close[k] - meanPrice) * (atr[k] - meanATR[i]);
         varPrice += MathPow(close[k] - meanPrice, 2);
         varATR += MathPow(atr[k] - meanATR[i], 2);
      }

      // Calculate correlation coefficient
      corr = covar / (MathSqrt(varPrice * varATR) + 1e-10); // Avoid division by zero

      // Generate signals
      int currentSignal = 0;
      if (corr > CorrThreshold)
      {
         currentSignal = 1; // Buy signal
      }
      else if (corr < -CorrThreshold)
      {
         currentSignal = -1; // Sell signal
      }

      // Draw arrows only if the signal changes
      if (currentSignal != lastSignal)
      {
         if (currentSignal == 1)
         {
            BuyArrowBuffer[i] = low[i] - 0.0001; // Draw buy arrow below the bar
            SellArrowBuffer[i] = EMPTY_VALUE; // Clear sell arrow buffer
         }
         else if (currentSignal == -1)
         {
            SellArrowBuffer[i] = high[i] + 0.0001; // Draw sell arrow above the bar
            BuyArrowBuffer[i] = EMPTY_VALUE; // Clear buy arrow buffer
         }

         // Update lastSignal
         lastSignal = currentSignal;
      }
   }

   return (rates_total);
}
//+------------------------------------------------------------------+
