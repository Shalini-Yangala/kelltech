//+------------------------------------------------------------------+
//|                                            HeadAndShoulders.mq4 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue       // Left shoulder
#property indicator_color2 Red        // Head
#property indicator_color3 Green      // Right shoulder
#property indicator_color4 Black      // Neckline
#property indicator_color5 Magenta    // Buy signal
#property indicator_color6 Yellow     // Sell signal

// Input parameters
input int LeftShoulderBars = 5;       // Number of bars for left shoulder
input int HeadBars = 10;              // Number of bars for head
input int RightShoulderBars = 5;      // Number of bars for right shoulder
input int MinDistanceBars = 5;        // Minimum bars distance between peaks

// Indicator buffers
double LeftShoulderBuffer[];
double HeadBuffer[];
double RightShoulderBuffer[];
double NecklineBuffer[];
double BuySignalBuffer[];
double SellSignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicator buffers mapping
   SetIndexBuffer(0, LeftShoulderBuffer);
   SetIndexBuffer(1, HeadBuffer);
   SetIndexBuffer(2, RightShoulderBuffer);
   SetIndexBuffer(3, NecklineBuffer);
   SetIndexBuffer(4, BuySignalBuffer);
   SetIndexBuffer(5, SellSignalBuffer);

   // Set up indicator labels
   IndicatorShortName("Head and Shoulders");
   SetIndexStyle(4, DRAW_ZIGZAG);
   SetIndexArrow(0, 233);
   SetIndexLabel(0, "Left Shoulder");
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexLabel(1, "Head");
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 233);
   SetIndexLabel(2, "Right Shoulder");
   SetIndexStyle(3, DRAW_LINE);
   SetIndexLabel(3, "Neckline");
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 234);
   SetIndexLabel(4, "Buy Signal");
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 234);
   SetIndexLabel(5, "Sell Signal");

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
   int shift;
   double leftShoulderHigh, headHigh, rightShoulderHigh;
   double leftShoulderLow, headLow, rightShoulderLow;
   double neckline;

   // Limit the number of bars to check
   int startBar = MathMax(0, rates_total - 50);

   // Reset buffers
   ArrayInitialize(LeftShoulderBuffer, 0.0);
   ArrayInitialize(HeadBuffer, 0.0);
   ArrayInitialize(RightShoulderBuffer, 0.0);
   ArrayInitialize(NecklineBuffer, 0.0);
   ArrayInitialize(BuySignalBuffer, 0.0);
   ArrayInitialize(SellSignalBuffer, 0.0);

   // Detect pattern within the last 50 bars
   for (shift = startBar; shift < rates_total - LeftShoulderBars - HeadBars - RightShoulderBars; shift++)
     {
      // Find peaks for left shoulder
      leftShoulderHigh = High[Highest(NULL, 0, MODE_HIGH, LeftShoulderBars, shift)];
      leftShoulderLow = Low[Lowest(NULL, 0, MODE_LOW, LeftShoulderBars, shift)];

      // Find peaks for head
      headHigh = High[Highest(NULL, 0, MODE_HIGH, HeadBars, shift + LeftShoulderBars)];
      headLow = Low[Lowest(NULL, 0, MODE_LOW, HeadBars, shift + LeftShoulderBars)];

      // Find peaks for right shoulder
      rightShoulderHigh = High[Highest(NULL, 0, MODE_HIGH, RightShoulderBars, shift + LeftShoulderBars + HeadBars)];
      rightShoulderLow = Low[Lowest(NULL, 0, MODE_LOW, RightShoulderBars, shift + LeftShoulderBars + HeadBars)];

      // Check if head is highest
      if(headHigh > leftShoulderHigh && headHigh > rightShoulderHigh)
        {
         // Check if left shoulder and right shoulder are not on the same side of the head
         if((leftShoulderHigh > rightShoulderHigh && leftShoulderLow > rightShoulderLow) || (leftShoulderHigh < rightShoulderHigh && leftShoulderLow < rightShoulderLow))
           {
            // Check distance between peaks
            if((shift + LeftShoulderBars + HeadBars + MinDistanceBars) < (shift + LeftShoulderBars))
              {
               // Calculate neckline
               neckline = leftShoulderLow;
               if(neckline > rightShoulderLow)
                  neckline = rightShoulderLow;

               // Assign values to buffers
               LeftShoulderBuffer[shift + LeftShoulderBars - 1] = leftShoulderHigh;
               HeadBuffer[shift + LeftShoulderBars + HeadBars - 1] = headHigh;
               RightShoulderBuffer[shift + LeftShoulderBars + HeadBars + RightShoulderBars - 1] = rightShoulderHigh;
               NecklineBuffer[shift + LeftShoulderBars - 1] = neckline;

               // Check for buy and sell signals
               if(close[shift] < neckline)
                 {
                  BuySignalBuffer[shift + LeftShoulderBars - 1] = Low[shift];
                  SellSignalBuffer[shift + LeftShoulderBars + HeadBars + RightShoulderBars - 1] = High[shift];
                 }
               else if(close[shift] > neckline)
                 {
                  BuySignalBuffer[shift + LeftShoulderBars + HeadBars + RightShoulderBars - 1] = High[shift];
                  SellSignalBuffer[shift + LeftShoulderBars - 1] = Low[shift];
                 }
              }
           }
        }
     }
   return(rates_total);
  }
