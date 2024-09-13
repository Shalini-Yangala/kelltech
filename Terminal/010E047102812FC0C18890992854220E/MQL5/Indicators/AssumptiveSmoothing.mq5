//+------------------------------------------------------------------+
//|                                           AssumptiveSmoothing.mq5 |
//|                                                     Tibra Capital |
//|                                            https://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Tibra Capital"
#property link      "https://www.tibra.com/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_label1 "Open;High;Low;Close"
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_width1 1

input color clr_Bull = Green;
input color clr_Bear = Red;
double buf_open[], buf_high[], buf_low[], buf_close[], buf_color[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   //--- indicator buffers mapping
   SetIndexBuffer(0, buf_open, INDICATOR_DATA);
   SetIndexBuffer(1, buf_high, INDICATOR_DATA);
   SetIndexBuffer(2, buf_low, INDICATOR_DATA);
   SetIndexBuffer(3, buf_close, INDICATOR_DATA);
   color colorbg = ChartBackColorGet(ChartID());
   SetIndexBuffer(4, buf_color, INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, colorbg);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clr_Bull);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, clr_Bear);
   //---
   return (INIT_SUCCEEDED);
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
                const int &spread[]) {
   //---
   for (int i = prev_calculated; i <= rates_total - 1; i++) {
      buf_open[i] = open[i];
      buf_high[i] = high[i];
      buf_low[i] = low[i];
      buf_close[i] = close[i];
      // Check for hopping frog pattern
      bool isLoneBull = (i > 0 && i < rates_total - 1) && (close[i] > open[i] && close[i - 1] < open[i - 1] && close[i + 1] < open[i + 1]);
      bool isLoneBear = (i > 0 && i < rates_total - 1) && (close[i] < open[i] && close[i - 1] > open[i - 1] && close[i + 1] > open[i + 1]);
      if (isLoneBull || isLoneBear) {
         buf_color[i] = 0; // Hide the lone candle
      } else {
         if (close[i] > open[i])
            buf_color[i] = 1;
         if (close[i] < open[i])
            buf_color[i] = 2;
      }
   }
   //--- return value of prev_calculated for next call
   return (rates_total);
}
//+------------------------------------------------------------------+
//| Gets the background color of chart                               |
//+------------------------------------------------------------------+
color ChartBackColorGet(const long chart_ID = 0) {
   //--- prepare the variable to receive the color
   long result = clrNONE;
   //--- reset the error value
   ResetLastError();
   //--- receive chart background color
   if (!ChartGetInteger(chart_ID, CHART_COLOR_BACKGROUND, 0, result)) {
      //--- display the error message in Experts journal
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
   }
   //--- return the value of the chart property
   return ((color)result);
}
//+------------------------------------------------------------------+