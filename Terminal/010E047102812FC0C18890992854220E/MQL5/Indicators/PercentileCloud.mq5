//+------------------------------------------------------------------+
//|                             PercentileCloud.mq5                   |
//|                                        Copyright © 2009, Vic2008 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009"
#property link ""
//---- indicator version number
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   5
//+-----------------------------------+
//|  Indicator rendering parameters   |
//+-----------------------------------+
//---- rendering indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- cloud color used is
#property indicator_color1  clrLawnGreen
//---- indicator label display
#property indicator_label1  "Upper Cloud"
//+-----------------------------------+
//|  Indicator rendering parameters   |
//+-----------------------------------+
//---- rendering indicator as a colored cloud
#property indicator_type2   DRAW_FILLING
//---- cloud color used is
#property indicator_color2  clrPink
//---- indicator label display
#property indicator_label2  "Lower Cloud"
//+-----------------------------------+
//|  Indicator rendering parameters   |
//+-----------------------------------+
//---- rendering indicator as a line
#property indicator_type3   DRAW_LINE
//---- the line color used for the indicator is green
#property indicator_color3 clrGreen
//---- indicator line is a solid curve
#property indicator_style3  STYLE_SOLID
//---- the thickness of the indicator line is 1
#property indicator_width3  1
//---- indicator label display
#property indicator_label3  "Upper PC Channel"
//+-----------------------------------+
//|  Indicator rendering parameters   |
//+-----------------------------------+
//---- rendering indicator as a line
#property indicator_type4   DRAW_LINE
//---- the line color used for the indicator is blue
#property indicator_color4 clrBlue
//---- indicator line is a solid curve
#property indicator_style4  STYLE_SOLID
//---- the thickness of the indicator line is 1
#property indicator_width4  1
//---- indicator label display
#property indicator_label4  "Middle PC Channel"
//+-----------------------------------+
//|  Indicator rendering parameters   |
//+-----------------------------------+
//---- rendering indicator as a line
#property indicator_type5   DRAW_LINE
//---- the line color used for the indicator is magenta
#property indicator_color5 clrMagenta
//---- indicator line is a solid curve
#property indicator_style5  STYLE_SOLID
//---- the thickness of the indicator line is 1
#property indicator_width5  1
//---- indicator label display
#property indicator_label5  "Lower PC Channel"
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR |
//+-----------------------------------+
input double percent=1.0; // percentage price deviation from the previous indicator value
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that will be further used as indicator buffers
double UpperBuffer[],MiddleBuffer[],LowerBuffer[];
double UpBuffer1[],UpBuffer2[],DnBuffer1[],DnBuffer2[];
//---- declaration of global variables
double plusvar,minusvar;
//---- declaration of integer variables for the start of data counting
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of constants
   min_rates_total=2;
   double var1=percent/100;
   plusvar=1+var1;
   minusvar=1-var1;
  
//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(0,UpBuffer2,INDICATOR_DATA);
//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(1,UpBuffer1,INDICATOR_DATA);
//---- applying horizontal shift for indicator 1
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- applying shift for the start of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values for the indicator that will not be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(2,DnBuffer1,INDICATOR_DATA);
//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//---- applying horizontal shift for indicator 1
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- applying shift for the start of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values for the indicator that will not be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(4,UpperBuffer,INDICATOR_DATA);
//---- applying horizontal shift for indicator 1
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- applying shift for the start of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values for the indicator that will not be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(5,MiddleBuffer,INDICATOR_DATA);
//---- applying horizontal shift for indicator 2
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- applying shift for the start of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values for the indicator that will not be visible on the chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transforming dynamic array into indicator buffer
   SetIndexBuffer(6,LowerBuffer,INDICATOR_DATA);
//---- applying horizontal shift for indicator 3
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- applying shift for the start of the indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values for the indicator that will not be visible on the chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializing variable for the short name of the indicator
   string shortname;
   StringConcatenate(shortname,"Percentage Crossover Channel(percent = ",percent,")");
//--- creating a name for display in a separate subwindow and in the tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- defining the precision of the indicator values display
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- completing initialization
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // number of history bars at the current tick
                const int prev_calculated,// number of history bars at the previous tick
                const int begin,          // the index of the first reliable bar
                const double &price[]     // price array for indicator calculation
                )
  {
//---- checking the number of bars for sufficiency for calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- declaration of integer variables
   int first,bar,bar1;

//---- calculation of the start number `first` for bar recalculation
   if(prev_calculated==0) // check for the first calculation start of the indicator
     {
      first=1+begin; // start number for calculation of all bars
      MiddleBuffer[first-1]=price[first-1];
      //---- applying shift for the start of the indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else // start number for new bar calculations
     {
      first=prev_calculated-1;
     }

//---- Main loop for calculating the middle line of the channel
   for(bar=first; bar<rates_total; bar++)
     {
      bar1=bar-1;
      if((price[bar]*minusvar)>MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*minusvar;
      else
        {
         if(price[bar]*plusvar<MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*plusvar;
         else MiddleBuffer[bar]=MiddleBuffer[bar1];
        }
      UpBuffer1[bar]=DnBuffer1[bar]=MiddleBuffer[bar];
      
      UpperBuffer[bar]=UpBuffer2[bar]=MiddleBuffer[bar]+(MiddleBuffer[bar]/100)*percent;
      LowerBuffer[bar]=DnBuffer2[bar]=MiddleBuffer[bar]-(MiddleBuffer[bar]/100)*percent;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
