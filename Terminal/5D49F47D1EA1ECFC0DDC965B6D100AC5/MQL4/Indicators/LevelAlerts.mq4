//+------------------------------------------------------------------+
//|                                                  LevelAlerts.mq4 |
//|                                                U.S Forex Academy |
//|                                   http://www.usforexacademy.com/ |
//+------------------------------------------------------------------+
#property copyright "U.S Forex Academy"
#property link      "http://www.usforexacademy.com/"
#property version   "1.02"
#property strict
#property indicator_chart_window

//--- input parameters
input bool EnablePushNotification = true; // Enable push notifications
input bool EnableEmailAlert = true;       // Enable email alerts
input string EmailAddress = "abc@gmail.com"; // Email address for alerts
input bool ShowAlertOnChart = true;       // Show alert on the chart
input color LineColor = clrRed;           // Color of the horizontal line
input int LineStyle = STYLE_DASHDOTDOT;   // Style of the horizontal line
input int LineWidth = 2;                  // Width of the horizontal line

double alertLevel = 0;           // Alert price level
bool alertTriggeredUp = false;   // Flag to track if upward alert has been triggered
bool alertTriggeredDown = false; // Flag to track if downward alert has been triggered

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create button for drawing horizontal line
   if(!CreateButton("DrawAlertLine", 0, 50, 50, 100, 30, "Draw Line"))
     {
      Print("Error: Failed to create button.");
      return(INIT_FAILED);
     }

   // Set indicator properties
   IndicatorShortName("LevelAlerts");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Delete button and lines when indicator is removed
   ObjectDelete("DrawAlertLine");
   ObjectDelete("AlertLine");
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
   // Monitor the price level for alerts
   if(ObjectFind(0, "AlertLine") >= 0)
     {
      alertLevel = ObjectGetDouble(0, "AlertLine", OBJPROP_PRICE1);
      double currentPrice = iClose(Symbol(), PERIOD_CURRENT, 0);

      // Check if the current price crosses the alert level upwards
      if(!alertTriggeredUp && currentPrice >= alertLevel)
        {
         // Trigger notifications
         SendAlert("Price has crossed above your alert level: ");
         alertTriggeredUp = true;    // Set the upward alert as triggered
         alertTriggeredDown = false; // Reset the downward alert trigger
        }

      // Check if the current price crosses the alert level downwards
      if(!alertTriggeredDown && currentPrice < alertLevel)
        {
         // Trigger notifications
         SendAlert("Price has crossed below your alert level: ");
         alertTriggeredDown = true;  // Set the downward alert as triggered
         alertTriggeredUp = false;   // Reset the upward alert trigger
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Function to create a button on the chart                         |
//+------------------------------------------------------------------+
bool CreateButton(string name, int sub_window, int x, int y, int width, int height, string label)
  {
   if(!ObjectCreate(0, name, OBJ_BUTTON, sub_window, 0, 0))
     {
      Print("Error creating button: ", name);
      return(false);
     }
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler for button click                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier
                  const long &lparam,   // Event parameter of long type
                  const double &dparam, // Event parameter of double type
                  const string &sparam) // Event parameter of string type
  {
   // Handle button click for drawing line
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "DrawAlertLine")
     {
      // Prompt user to place the horizontal line
      double linePrice = iClose(Symbol(), PERIOD_CURRENT, 0);  // Use current price as the initial price
      if(ObjectFind(0, "AlertLine") < 0)
        {
         ObjectCreate(0, "AlertLine", OBJ_HLINE, 0, Time[0], linePrice);
         ObjectSetInteger(0, "AlertLine", OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, "AlertLine", OBJPROP_STYLE, LineStyle);
         ObjectSetInteger(0, "AlertLine", OBJPROP_WIDTH, LineWidth);
         ObjectSetInteger(0, "AlertLine", OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, "AlertLine", OBJPROP_SELECTED, true);
         Print("Alert Line created at price: ", DoubleToString(linePrice, _Digits));
        }
      else
        {
         Print("Alert Line already exists.");
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to send alert notifications                             |
//+------------------------------------------------------------------+
void SendAlert(string messagePrefix)
  {
   string message = messagePrefix + DoubleToString(alertLevel, _Digits);
   
   // Show alert in the terminal and as a popup
   if(ShowAlertOnChart)
     {
      Alert(message);  
     }

   // Send push notification
   if(EnablePushNotification)
     {
      SendNotification(message);  // Send push notification
     }
     

   // Send email alert
   if(EnableEmailAlert)
     {
      SendMail(EmailAddress, message);  // Send email to the specified address
     }

   Print(message);  // Print message in the Experts tab
  }
//+------------------------------------------------------------------+
