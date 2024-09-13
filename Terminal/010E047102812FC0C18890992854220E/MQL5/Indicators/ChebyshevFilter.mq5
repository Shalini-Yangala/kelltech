/*
//+------------------------------------------------------------------+
//|                                              ChebyshevFilter.mq5 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.01"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_label1  "Chebchave Colors"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width1  3

// Input parameters
input int ripple = 11;        // Ripple (dB)
input int length = 25;        // Normalization Length
input int Upper_range = 60;   // Max of Range
input int Lower_range = 5;    // Min of Range
input int p_r = 5;            // Pivots to Right
input int p_l = 5;            // Pivots to Left
input bool show_div = false;  // Show Divergences

// Indicator buffers
double flt_price[], valColor[];
double bull_divergence[], bear_divergence[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Set the buffers for storing data and color indices
   SetIndexBuffer(0, flt_price);
   SetIndexBuffer(1, valColor);
   SetIndexBuffer(2, bull_divergence);
   SetIndexBuffer(3, bear_divergence);

// Initialize arrays as series
   ArraySetAsSeries(flt_price, true);
   ArraySetAsSeries(valColor, true);
   ArraySetAsSeries(bull_divergence, true);
   ArraySetAsSeries(bear_divergence, true);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Chebyshev Filter function                                        |
//+------------------------------------------------------------------+
double ChebyshevFilter(double price, int ripple_param)
  {
   double ripple_factor = MathPow(10, ripple_param / 20.0);
   double beta = MathSqrt(1 + ripple_factor * ripple_factor) / ripple_factor;
   double gamma = (MathPow(beta, 2) - 1) / MathSqrt(1 + MathPow(beta, 2));
   static double prev_filtered = 0;
   static double prev_prev_filtered = 0;

// Apply the Chebyshev filter calculation
   double filtered = (1 / beta) * (price - 2 * prev_filtered + prev_prev_filtered)
                     + 2 * (1 - gamma) * prev_filtered
                     - (1 - beta + gamma) * prev_prev_filtered;

   prev_prev_filtered = prev_filtered;
   prev_filtered = filtered;

   return filtered;
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
   int start = prev_calculated;
   if(start == 0)
      start = p_r + p_l;

// Ensure that the buffers have sufficient size
   ArrayResize(flt_price, rates_total);
   ArrayResize(valColor, rates_total);
   ArrayResize(bull_divergence, rates_total);
   ArrayResize(bear_divergence, rates_total);

   for(int i = start; i < rates_total; i++)
     {
      // Apply Chebyshev Filter
      double filtered_price = ChebyshevFilter(close[i], ripple);

      // Normalization
      double sma = iMA(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE);
      double stdev = iStdDev(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE);

      if(stdev != 0)
        {
         flt_price[i] = (filtered_price - sma) / stdev;
        }

      // Color the line based on the direction
      if(i > 0)
        {
         if(flt_price[i] > flt_price[i-1])
            valColor[i] = 1;
         else
            if(flt_price[i] < flt_price[i-1])
               valColor[i] = 2;
            else
               valColor[i] = valColor[i-1];
        }
      else
        {
         valColor[i] = 0;
        }
     }

   if(show_div)
     {
      for(int j = start; j < rates_total - p_r; j++)
        {
         if(j - p_r >= 0 && j + p_r < rates_total)
           {
            bool pivot_L = (low[j] < low[j - p_r] && low[j] < low[j + p_r]);
            bool pivot_H = (high[j] > high[j - p_r] && high[j] > high[j + p_r]);
            bool priceLL = low[j] < iLow(NULL, 0, j - p_r);
            bool priceHH = high[j] > iHigh(NULL, 0, j - p_r);
            bool cheb_filterHL = flt_price[j] > flt_price[j - p_r];
            bool cheb_filterLH = flt_price[j] < flt_price[j - p_r];
            if(pivot_L && cheb_filterHL && Lower_range <= j - p_r && j - p_r <= Upper_range)
              {
               bull_divergence[j] = flt_price[j];
               string name1 = "Bull"+IntegerToString(j);
               ObjectCreate(0,name1,OBJ_ARROW,1,iTime(_Symbol,PERIOD_CURRENT,j),bull_divergence[j]);
               ObjectSetInteger(0,name1,OBJPROP_ARROWCODE,233);
               ObjectSetInteger(0,name1,OBJPROP_WIDTH,1);
               ObjectSetInteger(0,name1,OBJPROP_COLOR,clrBlue);
              }
            else
               bull_divergence[j] = EMPTY_VALUE;
            if(pivot_H && cheb_filterLH && Lower_range <= j - p_r && j - p_r <= Upper_range)
              {
               bear_divergence[j] = flt_price[j];
               string name2 = "Bear"+IntegerToString(j);
               ObjectCreate(0,name2,OBJ_ARROW,1,iTime(_Symbol,PERIOD_CURRENT,j),bear_divergence[j]);
               ObjectSetInteger(0,name2,OBJPROP_ARROWCODE,234);
               ObjectSetInteger(0,name2,OBJPROP_WIDTH,1);
               ObjectSetInteger(0,name2,OBJPROP_COLOR,clrRed);
              }
            else
               bear_divergence[j] = EMPTY_VALUE;
           }
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
*/
//==================================================================================================================================================================


//+------------------------------------------------------------------+
//|                                                ChebyshevFilter.mq5|
//|                                          Walker Capital           |
//|                                    http://www.walkercapital.com.au|
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.02"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_label1  "Chebyshev Filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray, clrLimeGreen, clrDarkOrange
#property indicator_width1  3

// Input parameters
input double ripple = 11.0;        // Ripple (dB)
input int length = 25;             // Normalization Length
input int Upper_range = 60;        // Max of Range
input int Lower_range = 5;         // Min of Range
input int p_r = 5;                 // Pivots to Right
input int p_l = 5;                 // Pivots to Left
input bool show_div = false;       // Show Divergences

// Indicator buffers
double flt_price[], valColor[];
double bull_divergence[], bear_divergence[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set the buffers for storing data and color indices
    SetIndexBuffer(0, flt_price);
    SetIndexBuffer(1, valColor);
    SetIndexBuffer(2, bull_divergence);
    SetIndexBuffer(3, bear_divergence);

    // Initialize arrays as series
    ArraySetAsSeries(flt_price, true);
    ArraySetAsSeries(valColor, true);
    ArraySetAsSeries(bull_divergence, true);
    ArraySetAsSeries(bear_divergence, true);

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Chebyshev Filter function                                        |
//+------------------------------------------------------------------+
double ChebyshevFilter(double src, double ripple_param)
{
    // Calculate ripple factor
    double ripple_factor = MathPow(10, ripple_param / 20.0);

    // Calculate filter coefficients
    double beta = MathSqrt(1 + ripple_factor * ripple_factor) / ripple_factor;
    double gamma = (MathPow(beta, 2) - 1) / MathSqrt(1 + MathPow(beta, 2));

    // Initialize static variables
    static double filtered_price = 0;
    static double prev_filtered_price = 0;
    static double prev_prev_filtered_price = 0;

    // Apply the Chebyshev filter calculation
    filtered_price = (1 / beta) * (src - 2 * prev_filtered_price + prev_prev_filtered_price)
        + 2 * (1 - gamma) * prev_filtered_price
        - (1 - beta + gamma) * prev_prev_filtered_price;

    // Update previous values
    prev_prev_filtered_price = prev_filtered_price;
    prev_filtered_price = filtered_price;

    return filtered_price;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    int start = prev_calculated;
    if (start == 0)
        start = p_r + p_l;

    // Ensure that the buffers have sufficient size
    ArrayResize(flt_price, rates_total);
    ArrayResize(valColor, rates_total);
    ArrayResize(bull_divergence, rates_total);
    ArrayResize(bear_divergence, rates_total);

    // Create indicator handles
    int ma_handle = iMA(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE);
    int stddev_handle = iStdDev(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE);

    double sma[];
    double stdev[];

    ArraySetAsSeries(sma, true);
    ArraySetAsSeries(stdev, true);

    // Copy the data into arrays
    CopyBuffer(ma_handle, 0, 0, rates_total, sma);
    CopyBuffer(stddev_handle, 0, 0, rates_total, stdev);

    for (int i = start; i < rates_total; i++)
    {
        // Apply Chebyshev Filter
        double filtered_price = ChebyshevFilter(close[i], ripple);

        // Normalization
        if (stdev[i] != 0)
        {
            flt_price[i] = (filtered_price - sma[i]) / stdev[i];
        }

        // Color the line based on the direction
        if (i > 0)
        {
            if (flt_price[i] > flt_price[i - 1])
                valColor[i] = 1;
            else if (flt_price[i] < flt_price[i - 1])
                valColor[i] = 2;
            else
                valColor[i] = valColor[i - 1];
        }
        else
        {
            valColor[i] = 0;
        }
    }

    if (show_div)
    {
        for (int j = start; j < rates_total - p_r; j++)
        {
            if (j - p_r >= 0 && j + p_r < rates_total)
            {
                bool pivot_L = (low[j] < low[j - p_r] && low[j] < low[j + p_r]);
                bool pivot_H = (high[j] > high[j - p_r] && high[j] > high[j + p_r]);
                bool priceLL = low[j] < iLow(NULL, 0, j - p_r);
                bool priceHH = high[j] > iHigh(NULL, 0, j - p_r);
                bool cheb_filterHL = flt_price[j] > flt_price[j - p_r];
                bool cheb_filterLH = flt_price[j] < flt_price[j - p_r];

                if (pivot_L && cheb_filterHL && Lower_range <= j - p_r && j - p_r <= Upper_range)
                {
                    bull_divergence[j] = flt_price[j];
                    string name1 = "Bull" + IntegerToString(j);
                    ObjectCreate(0, name1, OBJ_ARROW, 1, time[j], bull_divergence[j]);
                    ObjectSetInteger(0, name1, OBJPROP_ARROWCODE, 233);
                    ObjectSetInteger(0, name1, OBJPROP_WIDTH, 1);
                    ObjectSetInteger(0, name1, OBJPROP_COLOR, clrBlue);
                }
                else
                {
                    bull_divergence[j] = EMPTY_VALUE;
                }

                if (pivot_H && cheb_filterLH && Lower_range <= j - p_r && j - p_r <= Upper_range)
                {
                    bear_divergence[j] = flt_price[j];
                    string name2 = "Bear" + IntegerToString(j);
                    ObjectCreate(0, name2, OBJ_ARROW, 1, time[j], bear_divergence[j]);
                    ObjectSetInteger(0, name2, OBJPROP_ARROWCODE, 234);
                    ObjectSetInteger(0, name2, OBJPROP_WIDTH, 1);
                    ObjectSetInteger(0, name2, OBJPROP_COLOR, clrRed);
                }
                else
                {
                    bear_divergence[j] = EMPTY_VALUE;
                }
            }
        }
    }

    return rates_total;
}
//+------------------------------------------------------------------+
