
//+------------------------------------------------------------------+
//|                                             ShalluGannCurves.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict
//color clrGreen;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Define the start and end price and time
    double startPrice = 1.2000; // Set your start price here
    double endPrice = 1.3000;   // Set your end price here
    datetime startTime = D'2024.01.01 00:00'; // Set your start time here
    datetime endTime = D'2024.01.02 00:00';   // Set your end time here

    // Draw Gann curves
    DrawGannCurves(startPrice, startTime, endPrice, endTime);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Custom Gann Curves function                                      |
//+------------------------------------------------------------------+
void DrawGannCurves(const double startPrice, const datetime startTime, const double endPrice, const datetime endTime)
{
    // Define the number of curves
    int curves = 8;
    
    // Calculate price range
    double priceRange = endPrice - startPrice;
    
    // Calculate time range
    int timeRange = endTime - startTime;
    
    // Calculate price step
    double priceStep = priceRange / (curves - 1);
    
    // Calculate time step
    int timeStep = timeRange / (curves - 1);
    
    for(int i = 0; i < curves; i++)
    {
        // Calculate price for the curve
        double curvePrice = startPrice + i * priceStep;
        
        // Calculate time for the curve
        datetime curveTime = startTime + i * timeStep;
        
        // Draw the curve
        ObjectCreate(0, "GannCurve_" + IntegerToString(i), OBJ_TRENDBYANGLE, 0, curveTime, curvePrice, 0, curvePrice);
        
        // Set color and other properties for the curve
        ObjectSetInteger(0, "GannCurve_" + IntegerToString(i), OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "GannCurve_" + IntegerToString(i), OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, "GannCurve_" + IntegerToString(i), OBJPROP_WIDTH, 1);
    }
}










   
  
  
