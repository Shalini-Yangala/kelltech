//+------------------------------------------------------------------+
//|                                                      PanelX.mq5 |
//|                                                      Tibra Capita |
//|                                            http://www.tibra.com/ |
//+------------------------------------------------------------------+
#property copyright "Tibra Capita"
#property link      "http://www.tibra.com/"
#property version   "1.01"

#include <Trade\Trade.mqh>
CTrade trade;
// Global variables for panel and dashboard
int handle_rsi, handle_cci, handle_ema, handle_stochastic, handle_bbands;
int panel_width = 200, panel_height = 150;
int dash_width = 200, dash_height = 200;
int btn_height = 30, btn_width = 100;
int totalTrades;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   handle_rsi = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   handle_cci = iCCI(_Symbol, _Period, 14,PRICE_CLOSE);
   handle_ema = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   handle_stochastic = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   handle_bbands = iBands(_Symbol, _Period, 20, 2.0, 0, PRICE_CLOSE);
   CreateTradingPanel();
   CreateIndicatorDashboard();
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Create Trading Panel                                             |
//+------------------------------------------------------------------+
void CreateTradingPanel()
  {
// Create trading panel
   int x = 10, y = 10;
   y += btn_height + 5;
   y += btn_height + 5;
   CreateButton();
  }
//+------------------------------------------------------------------+
//| Create Indicator Dashboard                                       |
//+------------------------------------------------------------------+
void CreateIndicatorDashboard()
  {
// Create indicator dashboard
   int x = int(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) )- dash_width - 10;
   int y = 10;
   CreateButton("btn_add_rsi", "RSI", x, y, btn_width, btn_height, clrGreen);
   y += btn_height + 5;
   CreateButton("btn_add_cci", "CCI", x, y, btn_width, btn_height, clrYellow);
   y += btn_height + 5;
   CreateButton("btn_add_ema", "EMA", x, y, btn_width, btn_height, clrOrange);
   y += btn_height + 5;
   CreateButton("btn_add_stochastic", "Stochastic", x, y, btn_width, btn_height, clrAliceBlue);
   y += btn_height + 5;
   CreateButton("btn_add_bbands", "BBands", x, y, btn_width, btn_height, clrAntiqueWhite);
   y += btn_height + 5;
   CreateButton("btn_remove_all", "Remove All", x, y, btn_width, btn_height, clrRed);
  }
//+------------------------------------------------------------------+
//| Create Button                                                    |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int width, int height, color clr)
  {
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
   if(!ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0))
     {
      Print("Failed to create button: ", name);
      return;
     }
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clr);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
// Remove all objects on deinitialization
   ObjectsDeleteAll(0, 0, -1);
   
   
  // Release and remove all indicators
   RemoveAllIndicators();
   
   // Remove trading panel and dashboard objects
   ObjectDelete(0,"rightPanel");
   ObjectDelete(0,"rightPanel1");
   ObjectDelete(0,"BuyButton");
   ObjectDelete(0,"SellButton");
   ObjectDelete(0,"ExitButton");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Handle button clicks
   if(ObjectGetInteger(0, "btn_add_rsi", OBJPROP_STATE))
     {
      AddIndicator("RSI");
      ObjectSetInteger(0, "btn_add_rsi", OBJPROP_STATE, false);
     }
   if(ObjectGetInteger(0, "btn_add_cci", OBJPROP_STATE))
     {
      AddIndicator("CCI");
      ObjectSetInteger(0, "btn_add_cci", OBJPROP_STATE, false);
     }
   if(ObjectGetInteger(0, "btn_add_ema", OBJPROP_STATE))
     {
      AddIndicator("EMA");
      ObjectSetInteger(0, "btn_add_ema", OBJPROP_STATE, false);
     }
   if(ObjectGetInteger(0, "btn_add_stochastic", OBJPROP_STATE))
     {
      AddIndicator("Stochastic");
      ObjectSetInteger(0, "btn_add_stochastic", OBJPROP_STATE, false);
     }
   if(ObjectGetInteger(0, "btn_add_bbands", OBJPROP_STATE))
     {
      AddIndicator("BBands");
      ObjectSetInteger(0, "btn_add_bbands", OBJPROP_STATE, false);
     }
   if(ObjectGetInteger(0, "btn_remove_all", OBJPROP_STATE))
     {
      RemoveAllIndicators();
      ObjectSetInteger(0, "btn_remove_all", OBJPROP_STATE, false);
     }
  }
//+------------------------------------------------------------------+
//| Add Indicator                                                    |
//+------------------------------------------------------------------+
void AddIndicator(string indicator)
  {
   if(indicator == "RSI")
     {
      ChartIndicatorAdd(0,1,handle_rsi);
     }
   if(indicator == "CCI")
     {
      ChartIndicatorAdd(0,2,handle_cci);
     }
   if(indicator == "EMA")
     {
      ChartIndicatorAdd(0,0,handle_ema);
     }
   if(indicator == "Stochastic")
     {
      ChartIndicatorAdd(0,3,handle_stochastic);
     }
   if(indicator == "BBands")
     {
      ChartIndicatorAdd(0,0,handle_bbands);
     }
  }
//+------------------------------------------------------------------+
//| Remove All Indicators                                            |
//+------------------------------------------------------------------+
void RemoveAllIndicators()
  {
   // Remove RSI
   if (handle_rsi != INVALID_HANDLE)
     {
     IndicatorRelease(handle_rsi);
      ChartIndicatorDelete(0, 1, "RSI");
      
      handle_rsi = INVALID_HANDLE;
     }
   // Remove CCI
   if (handle_cci != INVALID_HANDLE)
     {
     IndicatorRelease(handle_cci);
      ChartIndicatorDelete(0, 2, "CCI");
     
      handle_cci = INVALID_HANDLE;
     }
   // Remove EMA
   if (handle_ema != INVALID_HANDLE)
     {
     IndicatorRelease(handle_ema);
      ChartIndicatorDelete(0, 0, "EMA");
    
      handle_ema = INVALID_HANDLE;
     }
   // Remove Stochastic
   if (handle_stochastic != INVALID_HANDLE)
     {
     IndicatorRelease(handle_stochastic);
      ChartIndicatorDelete(0, 3, "Stochastic");
     
      handle_stochastic = INVALID_HANDLE;
     }
   // Remove BBands
   if (handle_bbands != INVALID_HANDLE)
     {
       IndicatorRelease(handle_bbands);
      ChartIndicatorDelete(0, 0, "BBands");
      
      handle_bbands = INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton()
  {
   ObjectCreate(0, "rightPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "rightPanel", OBJPROP_XSIZE, 380);
   ObjectSetInteger(0, "rightPanel", OBJPROP_YSIZE,70);
   ObjectSetInteger(0, "rightPanel", OBJPROP_XDISTANCE,80);
   ObjectSetInteger(0, "rightPanel", OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0, "rightPanel", OBJPROP_BGCOLOR, clrSkyBlue);
   ObjectSetInteger(0, "rightPanel", OBJPROP_BACK, true);
   ObjectSetInteger(0, "rightPanel", OBJPROP_CORNER, 0);
   ObjectCreate(0, "rightPanel1", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "dashboardleft", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_XSIZE, 130);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_YSIZE,220);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_XDISTANCE,1265);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_YDISTANCE,5);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_BGCOLOR, clrSkyBlue);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_BACK, true);
   ObjectSetInteger(0, "rightPanel1", OBJPROP_CORNER, 0);
   ObjectCreate(0,"BuyButton",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"BuyButton",OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,"BuyButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"BuyButton",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"BuyButton",OBJPROP_YSIZE,30);
   ObjectSetInteger(0,"BuyButton",OBJPROP_CORNER,0);
   ObjectSetString(0,"BuyButton",OBJPROP_TEXT,"BUY");
   ObjectSetInteger(0,"BuyButton",OBJPROP_BGCOLOR,clrGreen);
   ObjectSetInteger(0,"BuyButton",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"SellButton",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"SellButton",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"SellButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"SellButton",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"SellButton",OBJPROP_YSIZE,30);
   ObjectSetInteger(0,"SellButton",OBJPROP_CORNER,0);
   ObjectSetString(0,"SellButton",OBJPROP_TEXT,"SELL");
   ObjectSetInteger(0,"SellButton",OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(0,"SellButton",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"ExitButton",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"ExitButton",OBJPROP_XDISTANCE,340);
   ObjectSetInteger(0,"ExitButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"ExitButton",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"ExitButton",OBJPROP_YSIZE,30);
   ObjectSetInteger(0,"ExitButton",OBJPROP_CORNER,0);
   ObjectSetString(0,"ExitButton",OBJPROP_TEXT,"EXIT");
   ObjectSetInteger(0,"ExitButton",OBJPROP_BGCOLOR,clrBlue);
   ObjectSetInteger(0,"ExitButton",OBJPROP_COLOR,clrBlack);
  }
//+------------------------------------------------------------------+
//|  Button Functionality                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "BuyButton")
     {
      trade.Buy(0.1);
     }
   else
      if(id == CHARTEVENT_OBJECT_CLICK && sparam == "SellButton")
        {
         trade.Sell(0.1);
        }
      else
         if(id == CHARTEVENT_OBJECT_CLICK && sparam == "ExitButton")
           {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               ulong ticket = PositionGetTicket(i);
               trade.PositionClose(ticket);
              }
            totalTrades=0;
           }
  }
//+------------------------------------------------------------------+