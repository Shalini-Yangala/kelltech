//+------------------------------------------------------------------+
//|                                                    VolumeProfile.mq5|
//|                        Custom Vertical Volume Profile Indicator          |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 0

//--- input parameters
input int     ProfileBars = 20;       // Number of bars to include in the profile
input color   VolumeColor = clrBlue;  // Color of the volume bars
input int     BarWidth = 2;           // Width of the volume bars

//--- global variables
datetime     profile_start_time;      // Start time of the profile
datetime     profile_end_time;        // End time of the profile

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize the indicator
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
   // Determine the range of bars for the profile
   int begin_bar = rates_total - ProfileBars;
   if(begin_bar < 0) begin_bar = 0;

   // Clear existing objects
   ObjectsDeleteAll(0,0, OBJ_RECTANGLE);

   // Create volume profile
   CreateVolumeProfile(time, open, high, low, close, volume, begin_bar, rates_total);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create volume profile on the chart                               |
//+------------------------------------------------------------------+
void CreateVolumeProfile(const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &volume[], int begin_bar, int end_bar)
  {
   // Get the highest and lowest prices in the selected range
   double highest_price = low[begin_bar];
   double lowest_price = high[begin_bar];
   for(int i = begin_bar; i < end_bar; i++)
     {
      if(high[i] > highest_price) highest_price = high[i];
      if(low[i] < lowest_price) lowest_price = low[i];
     }

   // Define the number of volume bins (e.g., 50 bins for the profile)
   int num_bins = 50;
   double bin_size = (highest_price - lowest_price) / num_bins;
   double volume_bins[];
   ArraySetAsSeries(volume_bins, true);
   ArrayResize(volume_bins, num_bins);

   // Initialize volume bins to zero
   for(int i = 0; i < num_bins; i++) volume_bins[i] = 0;

   // Calculate volume for each price bin
   for(int i = begin_bar; i < end_bar; i++)
     {
      int bin_index = (int)((close[i] - lowest_price) / bin_size);
      if(bin_index >= 0 && bin_index < num_bins)
        {
         volume_bins[bin_index] += volume[i];
        }
     }

   // Draw the volume profile on the chart
   DrawVolumeProfile(lowest_price, bin_size, num_bins, volume_bins, time);
  }

//+------------------------------------------------------------------+
//| Draw volume profile on the chart                                |
//+------------------------------------------------------------------+
void DrawVolumeProfile(double lowest_price, double bin_size, int num_bins, const double &volume_bins[], const datetime &time[])
  {
   for(int i = 0; i < num_bins; i++)
     {
      double bin_low = lowest_price + i * bin_size;
      double bin_high = bin_low + bin_size;

      // Draw volume bars for the current bin
      double bin_volume = volume_bins[i];
      if(bin_volume > 0)
        {
         string obj_name = "VolumeBin_" + IntegerToString(i);

         // Create the object with start and end times (visible area on the chart)
         datetime start_time = time[0];
         datetime end_time = start_time + PeriodSeconds() * ProfileBars; // Extending to cover bars

         // Create the object
         if(!ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, start_time, bin_low, end_time, bin_high))
           {
            Print("Failed to create object: ", obj_name);
            continue;
           }

         // Set properties of the object
         ObjectSetInteger(0, obj_name, OBJPROP_COLOR, VolumeColor);
         ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, BarWidth);
         ObjectSetInteger(0, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

         // Adjust the size based on volume
         double scale_factor = 1000.0; // Adjust scaling factor as needed
         ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, BarWidth);
         ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, MathMax(1, (int)(bin_volume / scale_factor))); // Ensure visible height
        }
     }
  }


