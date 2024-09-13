//+---------------------------------------------------------------------+
//|                                               RSICloud.mq5          |
//|                                Copyright © 2015, Yuriy Tokman (YTG) |
//|                                                  http://ytg.com.ua/ |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua/"

#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrForestGreen,clrOrangeRed
#property indicator_label1  "Directed_Movement"

//+----------------------------------------------+
//|  Including the smoothing algorithms class    |
//+----------------------------------------------+
#include <SmoothingAlgorithms.mqh>
//+----------------------------------------------+
//---- Declaration of variables of the CXMA class from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
/*enum Smooth_Method - Enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET  0 // Constant to reset the indicator recalculation in the terminal
//+----------------------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR           |
//+----------------------------------------------+
input uint                 RSIPeriod=14;         // RSI indicator period
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE; // Applied price for RSI calculation
input Smooth_Method MA_Method1=MODE_SMA_;        // Smoothing method for the first smoothing
input int Length1=12;                            // Depth of the first smoothing
input int Phase1=15;                             // Parameter for the first smoothing,
//---- For JJMA, this parameter varies between -100 to +100, affecting the quality of the transition process;
//---- For VIDYA, this is the CMO period, for AMA, this is the slow moving average period.
input Smooth_Method MA_Method2=MODE_JJMA;        // Smoothing method for the second smoothing
input int Length2 = 5;                           // Depth of the second smoothing
input int Phase2=15;                             // Parameter for the second smoothing,
//---- For JJMA, this parameter varies between -100 to +100, affecting the quality of the transition process;
//---- For VIDYA, this is the CMO period, for AMA, this is the slow moving average period.
input int Shift=0;                               // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- Declaration of dynamic arrays that will be used later as indicator buffers
double XRSIBuffer[];
double XXRSIBuffer[];
//---- Declaration of integer variables for the start of data counting
int min_rates_total,min_rates_1,min_rates_2;
//---- Declaration of integer variables for indicator handles
int RSI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables for the start of data counting
   min_rates_1=int(RSIPeriod);
   min_rates_2=min_rates_1+GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total=min_rates_2+GetStartBars(MA_Method2,Length2,Phase2);

//---- Obtaining the handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print("Failed to obtain handle for iRSI indicator");
      return(INIT_FAILED);
     }
//---- Convert the dynamic array into an indicator buffer
   SetIndexBuffer(0,XRSIBuffer,INDICATOR_DATA);
//---- Convert the dynamic array into an indicator buffer
   SetIndexBuffer(1,XXRSIBuffer,INDICATOR_DATA);
//---- Apply horizontal shift to the first indicator by Shift value
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Apply drawing start offset for the first indicator to min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Initialize the variable for the short name of the indicator
   string shortname="Directed_Movement";
//--- Create a name for display in a separate subwindow and in the tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Define the precision of indicator value display
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- Define the precision of indicator value display
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- Set the number of horizontal levels of the indicator to 3
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- Set the values of the horizontal levels of the indicator
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,70);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,30);
//---- Assign colors to the lines of the horizontal levels
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- Use a short dash-dot-dot style for the horizontal level lines
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- Finish initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,    // Number of history bars on the current tick
   const int prev_calculated,// Number of history bars on the previous tick
   const datetime &time[],
   const double &open[],
   const double& high[],     // Price array of highs for indicator calculation
   const double& low[],      // Price array of lows for indicator calculation
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
  {
//---- Check if the number of bars is sufficient for calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total)
      return(RESET);

//---- Declaration of floating-point variables
   double rsi[1];
//---- Declaration of integer variables
   int first,bar;

//---- Calculate the start number 'first' for the recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // Check for the first start of indicator calculation
      first=min_rates_1; // Start number for calculating all bars
   else
      first=prev_calculated-1; // Start number for calculating new bars

//---- Main loop for indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Copy new data into the array
      if(CopyBuffer(RSI_Handle,0,rates_total-1-bar,1,rsi)<=0)
         return(RESET);
      XRSIBuffer[bar]=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,rsi[0],bar,false);
      XXRSIBuffer[bar]=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,XRSIBuffer[bar],bar,false);
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
