//+------------------------------------------------------------------+
//|                                             GradientVelocity.mq5 |
//|                                                U.S Forex Academy |
//|                                   http://www.usforexacademy.com/ |
//+------------------------------------------------------------------+
#property copyright "U.S Forex Academy"
#property link      "http://www.usforexacademy.com/"
#property version   "1.00"

// Indicator properties
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Velocity"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//------------------------------------------------------------------
// Enumeration for different price types                            
//------------------------------------------------------------------

enum enPrices
{
   pr_close,      // Close price
   pr_open,       // Open price
   pr_high,       // High price
   pr_low,        // Low price
   pr_median,     // Median price
   pr_typical,    // Typical price
   pr_weighted,   // Weighted price
   pr_average,    // Average price
   pr_haclose,    // Heiken Ashi close price
   pr_haopen,     // Heiken Ashi open price
   pr_hahigh,     // Heiken Ashi high price
   pr_halow,      // Heiken Ashi low price
   pr_hamedian,   // Heiken Ashi median price
   pr_hatypical,  // Heiken Ashi typical price
   pr_haweighted, // Heiken Ashi weighted price
   pr_haaverage   // Heiken Ashi average price
};

// Input parameters
input int       Length       = 32;        // Velocity period
input enPrices  Price        = pr_median; // Price type to use
input int       NormPeriod   = 14;        // Normalization period
input color     ColorFrom    = clrOrange; // Color for downward velocity
input color     ColorTo      = clrLime;   // Color for upward velocity
input int       ColorSteps   = 50;        // Number of color steps for gradient

input bool GradientColor = true; // Option to use gradient coloring

// Buffers for indicator values and colors
double vel[];
double colorBuffer[];

// Number of color steps
int cSteps;

// Initialization function
int OnInit()
{
   // Set buffers for indicator values and colors
   SetIndexBuffer(0, vel, INDICATOR_DATA); 
   SetIndexBuffer(1, colorBuffer, INDICATOR_COLOR_INDEX); 
   
   // Initialize color steps
   cSteps = (ColorSteps > 1) ? ColorSteps : 2;
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, cSteps + 1);
   
   // Set gradient colors for the indicator line
   for (int i = 0; i < cSteps + 1; i++) 
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, i, gradientColor(i, cSteps + 1, ColorFrom, ColorTo));
      
   // Set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "Velocity (" + string(Length) + ")");
   
   return (0);
}

// -----------------------------------------------------------
//Calculation function
//------------------------------------------------------------

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {
   
   // Calculate indicator values
   for (int i = (int)MathMax(prev_calculated - 1, 0); i < rates_total; i++) {
      double price = getPrice(Price, open, close, high, low, i, rates_total);
      vel[i] = iRsi(iVelocity(price, Length, i, rates_total), NormPeriod, rates_total, i);
      
      if (i > 0) {
         colorBuffer[i] = colorBuffer[i - 1];
         double minVel = vel[i];
         double maxVel = vel[i];
         double col = 0;
         
         // Determine min and max velocity for gradient calculation
         for (int k = 1; k < ColorSteps && (i - k) >= 0; k++) {
            minVel = MathMin(vel[i - k], minVel);
            maxVel = MathMax(vel[i - k], maxVel);
         }
         
         // Calculate color index for gradient
         if ((maxVel - minVel) == 0) {
            col = 50;
         } else {
            col = 100 * (vel[i] - minVel) / (maxVel - minVel);
         }

         // Apply gradient coloring or default color
         if (GradientColor) {
            colorBuffer[i] = MathFloor(col * cSteps / 100.0);
         } else {
            colorBuffer[i] = 0;  // Default color (no gradient)
         }
      }                    
   }
   
   return (rates_total);
}

//----------------------------------------------------------
// Function to get the price based on the selected type
//----------------------------------------------------------

double workHa[][4];
double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   if (price >= pr_haclose && price <= pr_haaverage)
   {
      // Resize array if necessary
      if (ArrayRange(workHa, 0) != bars) ArrayResize(workHa, bars);

      double haOpen;
      if (i > 0)
         haOpen = (workHa[i - 1][2] + workHa[i - 1][3]) / 2.0;
      else
         haOpen = open[i] + close[i];
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh = MathMax(high[i], MathMax(haOpen, haClose));
      double haLow = MathMin(low[i], MathMin(haOpen, haClose));

      if (haOpen < haClose) {
         workHa[i][0] = haLow;
         workHa[i][1] = haHigh;
      } else {
         workHa[i][0] = haHigh;
         workHa[i][1] = haLow;
      }
      workHa[i][2] = haOpen;
      workHa[i][3] = haClose;
      
      switch (price)
      {
         case pr_haclose:     return (haClose);
         case pr_haopen:      return (haOpen);
         case pr_hahigh:      return (haHigh);
         case pr_halow:       return (haLow);
         case pr_hamedian:    return ((haHigh + haLow) / 2.0);
         case pr_hatypical:   return ((haHigh + haLow + haClose) / 3.0);
         case pr_haweighted:  return ((haHigh + haLow + haClose + haClose) / 4.0);
         case pr_haaverage:   return ((haHigh + haLow + haClose + haOpen) / 4.0);
      }
   }
   
   switch (price)
   {
      case pr_close:     return (close[i]);
      case pr_open:      return (open[i]);
      case pr_high:      return (high[i]);
      case pr_low:       return (low[i]);
      case pr_median:    return ((high[i] + low[i]) / 2.0);
      case pr_typical:   return ((high[i] + low[i] + close[i]) / 3.0);
      case pr_weighted:  return ((high[i] + low[i] + close[i] + close[i]) / 4.0);
      case pr_average:   return ((high[i] + low[i] + close[i] + open[i]) / 4.0);
   }
   return (0);
}

//-----------------------------------------------
// Function to calculate the velocity
//-----------------------------------------------
double prices[];
double iVelocity(double price, double length, int i, int total)
{
   if (ArraySize(prices) != total) ArrayResize(prices, total);
   prices[i] = price;
   
   double suma = 0.0, sumwa = 0;
   double sumb = 0.0, sumwb = 0;

   for (int k = 0; k < length && (i - k) >= 0; k++)
   {
      double weight = length - k;
      suma += prices[i - k] * weight;
      sumb += prices[i - k] * weight * weight;
      sumwa += weight;
      sumwb += weight * weight;
   }
   return (sumb / sumwb - suma / sumwa);
}

//----------------------------------------------------
// Function to calculate the RSI
//----------------------------------------------------

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int bars, int i, int forInstance = 0)
{
   if (ArrayRange(workRsi, 0) != bars) ArrayResize(workRsi, bars);
   int z = forInstance * 3;
   double alpha = 1.0 / period;
   
   workRsi[i][_price + z] = price;
   
   if (i < period - 1)
   {
      double sum = 0.0;
      for (int k = 0; k <= i; k++)
         sum += workRsi[i - k][_price + z];
      workRsi[i][_change + z] = sum / (i + 1);
      return (workRsi[i][_change + z]);
   }
   
   if (i == period - 1)
   {
      double sum = 0.0;
      for (int k = 0; k < period; k++)
         sum += workRsi[i - k][_price + z];
      workRsi[i][_change + z] = sum / period;
      return (workRsi[i][_change + z]);
   }
   
   double tempSum1 = workRsi[i - 1][_change + z] * (period - 1);
   tempSum1 += workRsi[i][_price + z];
   workRsi[i][_change + z] = tempSum1 / period;
   return (workRsi[i][_change + z]);
}


//------------------------------------------------------------------
// Function to extract RGB components from a color code
//------------------------------------------------------------------


void ColorToRGB(color colorCode, int &r, int &g, int &b)
{
   r = (colorCode >> 16) & 0xFF; // Extract red component
   g = (colorCode >> 8) & 0xFF;  // Extract green component
   b = colorCode & 0xFF;         // Extract blue component
}

// Function to create a color code from RGB components
color RGBToColor(int r, int g, int b)
{
   return (color)((r << 16) | (g << 8 ) | b); // Combine RGB components into a single color code

}
//---------------------------------------------------------
// Function to calculate the gradient color
//---------------------------------------------------------
color gradientColor(int index, int steps, color fromColor, color toColor)
{
    int r1, g1, b1;
    int r2, g2, b2;
   
    // Extract RGB components from color codes
    ColorToRGB(fromColor, r1, g1, b1);
    ColorToRGB(toColor, r2, g2, b2);
   
    double ratio = (double)index / (steps - 1);
   
    // Calculate the intermediate RGB values
    int r = r1 + (int)((r2 - r1) * ratio);
    int g = g1 + (int)((g2 - g1) * ratio);
    int b = b1 + (int)((b2 - b1) * ratio);
   
    // Combine RGB components into a color code and return
    return (color)RGBToColor(r, g, b); // Explicit cast to color type
}

