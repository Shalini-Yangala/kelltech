//+------------------------------------------------------------------+
//|                                           button_application.mq4 |
//|                             Copyright 2024, kelltechdigital Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, kelltechdigital Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create button
    ObjectCreate(0, "CloseTradesButton", OBJ_BUTTON, 0, 0, 0);
    ObjectSetString(0, "CloseTradesButton", OBJPROP_TEXT, "CAT");
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_XDISTANCE, 65);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_YDISTANCE, 35);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_SELECTED, false);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_STATE, false);
    ObjectSetInteger(0, "CloseTradesButton", OBJPROP_CORNER,1);
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Remove button
    ObjectDelete(0, "CloseTradesButton");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if the button is clicked
    if (IsClicked("CloseTradesButton"))
    {
        // Close all open trades
        CloseAllTrades();
    }
}
//+------------------------------------------------------------------+
//| Function to check if the button is clicked                       |
//+------------------------------------------------------------------+
bool IsClicked(string buttonName)
{
    int buttonHandle = ObjectFind(0, buttonName);
    if (buttonHandle < 0)
        return false;
    return ObjectGetInteger(0, buttonName, OBJPROP_STATE) == true;
}
//+------------------------------------------------------------------+
//| Function to close all open trades                                |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderType() <= OP_SELL)
        {
            double Order_id=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3);
        }
    }
}














