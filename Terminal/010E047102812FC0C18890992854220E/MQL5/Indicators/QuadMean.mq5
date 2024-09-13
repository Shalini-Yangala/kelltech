//+------------------------------------------------------------------+
//|                                                     QuadMean.mq5 |
//|                                               Elite Forex Trades |
//|                                     https://eliteforextrades.com |
//+------------------------------------------------------------------+
#property copyright "Elite Forex Trades"
#property link      "https://eliteforextrades.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "MA Moving Colors"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width1  5

// Input parameters for the indicator
input int inpPeriod = 25; // Period for RMS calculation
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Type of price to apply

// Buffers for storing RMS values and their corresponding colors
double val[],valColor[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Set the buffers for storing data and color indices
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valColor,INDICATOR_COLOR_INDEX);

   return(INIT_SUCCEEDED); // Initialization succeeded
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // number of bars
                const int prev_calculated,  // previously calculated bars
                const datetime& time[],     // time array
                const double& open[],       // open price array
                const double& high[],       // high price array
                const double& low[],        // low price array
                const double& close[],      // close price array
                const long& tick_volume[],  // tick volume array
                const long& volume[],       // real volume array
                const int& spread[])        // spread array
  {
   // Determine starting point for calculations
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   // Loop through bars to calculate RMS and color values
   for(int i=limit; i<rates_total && !_StopFlag; i++)
     {
      // Calculate the RMS value for the current bar
      val[i] = iRootMeanSquare(iGetPrice(inpPrice,open[i],high[i],low[i],close[i]),inpPeriod,i,rates_total);
      
      // Determine the color index based on the trend direction
      valColor[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valColor[i-1] : 0;
     }

   return(rates_total); // Return the number of bars
  }

//+------------------------------------------------------------------+
//| Function to calculate the Root Mean Square (RMS)                 |
//+------------------------------------------------------------------+
double iRootMeanSquare(double value, int period, int r, int bars, int instanceNo=0)
  {
   // Structure to store intermediate calculations
   struct sWorkStruct
     {
      double valueXvalue;      // Squared value of the price
      double valueXvalueSum;   // Sum of squared values
     };

   static sWorkStruct m_work[];   // Array of work structures
   static int m_workSize = -1;    // Size of the work array

   // Resize the work array if necessary
   if(m_workSize <= bars)
      m_workSize = ArrayResize(m_work,bars+500,2000);

   if(period<1)
      period = 1; // Ensure period is at least 1

   // Calculate the squared value of the price
   m_work[r].valueXvalue = value*value;

   // Update the sum of squared values for the given period
   if(r>=period)
     {
      m_work[r].valueXvalueSum  = m_work[r-1].valueXvalueSum + m_work[r].valueXvalue - m_work[r-period].valueXvalue;
     }
   else
     {
      m_work[r].valueXvalueSum = m_work[r].valueXvalue;
      for(int k=1; k<period && r>=k; k++)
         m_work[r].valueXvalueSum  += m_work[r-k].valueXvalue;
     }

   // Calculate and return the RMS value
   return(MathSqrt(m_work[r].valueXvalueSum/(double)period));
  }

//+------------------------------------------------------------------+
//| Function to get the price based on the selected type             |
//+------------------------------------------------------------------+
double iGetPrice(int tprice, double open, double high, const double low, const double close)
  {
   // Return the appropriate price based on the selected type
   switch(tprice)
     {
     
      case PRICE_CLOSE:
         return(close);
      case PRICE_OPEN:
         return(open);
      case PRICE_HIGH:
         return(high);
      case PRICE_LOW:
         return(low);
      case PRICE_MEDIAN:
         return((high+low)/2.0);
      case PRICE_TYPICAL:
         return((high+low+close)/3.0);
      case PRICE_WEIGHTED:
         return((high+low+close+close)/4.0);
     }

   return(0); // Default case, should not happen
  }
//+------------------------------------------------------------------+
