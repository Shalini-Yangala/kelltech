/*
//+------------------------------------------------------------------+
//|                                                 Elite Hedger.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict


// Inputs
input double Lots = 0.1;
input int HedgeDistance = 12;
input int StopLoss = 25;
input int TakeProfit = 115;
input string NewsSource = "http://example.com/forex-factory-news"; // Placeholder for actual news source

// Global variables
datetime nextNewsTime = 0;
bool isNewsTime = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code
    EventSetTimer(60); // Set timer to check news every minute
    CreateHedgeButton();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    CloseAllPendingOrders();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (isNewsTime)
    {
        // Check for existing trades
        if (OrdersTotal() == 0)
        {
            double price = MarketInfo(Symbol(), MODE_BID);
            PlaceHedgeOrders(price);
        }
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Fetch news events and check if it's time to trade
    CheckForNews();
}

//+------------------------------------------------------------------+
//| Place hedge orders                                               |
//+------------------------------------------------------------------+
void PlaceHedgeOrders(double price)
{
    double buyPrice = price + HedgeDistance * Point;
    double sellPrice = price - HedgeDistance * Point;
    
    // Place Buy order
    int buyTicket = OrderSend(Symbol(), OP_BUY, Lots, buyPrice, 3, buyPrice - StopLoss * Point, buyPrice + TakeProfit * Point, "Hedge Buy", 0, 0, Blue);
    
    // Place Sell order
    int sellTicket = OrderSend(Symbol(), OP_SELL, Lots, sellPrice, 3, sellPrice + StopLoss * Point, sellPrice - TakeProfit * Point, "Hedge Sell", 0, 0, Red);
}

//+------------------------------------------------------------------+
//| Check for news events                                            |
//+------------------------------------------------------------------+
void CheckForNews()
{
    // Placeholder: Fetch news from an external source
    // This would typically involve parsing an XML or JSON feed from Forex Factory

    // Example: Assume we get the next news time
    nextNewsTime = D'2024.05.23 14:30'; // Placeholder for actual news time

    if (TimeCurrent() >= nextNewsTime && TimeCurrent() <= nextNewsTime + 60) // 1-minute window
    {
        isNewsTime = true;
    }
    else
    {
        isNewsTime = false;
    }
}

//+------------------------------------------------------------------+
//| Close all pending orders                                         |
//+------------------------------------------------------------------+
void CloseAllPendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderType() <= OP_SELL)
        {
            OrderDelete(OrderTicket());
        }
    }
}

//+------------------------------------------------------------------+
//| Create manual hedge button                                       |
//+------------------------------------------------------------------+
void CreateHedgeButton()
{
    if (!ObjectCreate(0, "HedgeButton", OBJ_BUTTON, 0, 0, 0))
    {
        Print("Failed to create button!");
        return;
    }
    ObjectSetInteger(0, "HedgeButton", OBJPROP_XSIZE, 120);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_YSIZE, 60);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_CORNER, 0);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_YDISTANCE, 20);
    ObjectSetString(0, "HedgeButton", OBJPROP_TEXT, "Hedge Now");
    ObjectSetInteger(0, "HedgeButton", OBJPROP_COLOR, clrGreen);
}

//+------------------------------------------------------------------+
//| Event handler for manual hedge button click                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == "HedgeButton")
    {
        double price = MarketInfo(Symbol(), MODE_BID);
        PlaceHedgeOrders(price);
    }
}





*/






//===================================================================================================================
/*
//#property strict
// Input parameters
input double Lots = 0.1;              // Lot size
input double HedgeDistance = 12;      // Distance in pips for hedge
input double StopLoss = 25;           // Stop loss in pips
input double TakeProfit = 115;        // Take profit in pips
input string NewsUrl = "https://www.forexfactory.com/news"; // URL for news data
// Variables to manage news data and hedging
datetime nextNewsTime = 0;
bool newsHighImpact = false;
bool manualHedge = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create button for manual hedging
    CreateHedgeButton();
    // Fetch initial news data
    FetchAndUpdateNewsData();
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Remove objects from the chart
    ObjectsDeleteAll();
    // Close any pending orders
    ClosePendingOrders();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    datetime currentTime = TimeCurrent();
    // Check for news event and take hedge position if necessary
    if (newsHighImpact && nextNewsTime > 0 && currentTime >= nextNewsTime && currentTime <= nextNewsTime + PeriodSeconds())
    {
        PlaceHedgeOrders();
        newsHighImpact = false; // Reset the flag
    }
    // Check for manual hedge button press
    if (manualHedge)
    {
        PlaceHedgeOrders();
        manualHedge = false;
    }
    // Fetch and update news data periodically
    static datetime lastUpdate = 0;
    if (currentTime > lastUpdate + 3600) // Update every hour
    {
        FetchAndUpdateNewsData();
        lastUpdate = currentTime;
    }
}
//+------------------------------------------------------------------+
//| Create a button for manual hedging                               |
//+------------------------------------------------------------------+
void CreateHedgeButton()
{
    string buttonName = "HedgeButton";
    if (!ObjectCreate(0, buttonName, OBJ_BUTTON, 0, 0, 0))
    {
        Print("Error creating button: ", GetLastError());
        return;
    }
    ObjectSetInteger(0, buttonName, OBJPROP_XSIZE, 100);
    ObjectSetInteger(0, buttonName, OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, buttonName, OBJPROP_CORNER, 0);
    ObjectSetInteger(0, buttonName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, buttonName, OBJPROP_YDISTANCE, 10);
    ObjectSetString(0, buttonName, OBJPROP_TEXT, "Hedge Now");
    ObjectSetInteger(0, buttonName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, buttonName, OBJPROP_FONTSIZE, 12);
    ObjectSetInteger(0, buttonName, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, buttonName, OBJPROP_BACK, false);
    ObjectSetInteger(0, buttonName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, buttonName, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, buttonName, OBJPROP_BORDER_TYPE, BORDER_RAISED);
}
//+------------------------------------------------------------------+
//| Close all pending orders                                         |
//+------------------------------------------------------------------+
void ClosePendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
            {
                OrderDelete(OrderTicket());
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Fetch and update news data                                       |
//+------------------------------------------------------------------+
void FetchAndUpdateNewsData()
{
    string response = FetchNewsData(NewsUrl);
    if (response != "")
    {
        ParseNewsData(response);
    }
}
//+------------------------------------------------------------------+
//| Fetch News Data                                                  |
//+------------------------------------------------------------------+
string FetchNewsData(string url)
{
    char post[], result[];
    string headers;
    string result_headers;
    int timeout = 5000; // Timeout in milliseconds
    int res = WebRequest("GET", url, "", "", timeout, post, 0, result, result_headers);
    if (res == -1)
    {
        Print("Error in WebRequest: ", GetLastError());
        return "";
    }
    // Convert the result to a string
    string response = CharArrayToString(result);
    return response;
}
//+------------------------------------------------------------------+
//| Parse News Data                                                  |
//+------------------------------------------------------------------+
void ParseNewsData(string htmlResponse)
{
    // This is a simplified example of parsing
    // Adjust based on actual HTML structure of the news website
    // Find the start of the relevant section
    int startIndex = StringFind(htmlResponse, "<div class=\"calendar__day\"");
    if (startIndex == -1)
    {
        Print("Failed to find the news section in the HTML response.");
        return;
    }
    // Extract a substring containing the relevant section
    string newsSection = StringSubstr(htmlResponse, startIndex, 10000);
    // Extract individual news items
    while (true)
    {
        int newsStart = StringFind(newsSection, "<div class=\"calendar__row\"");
        if (newsStart == -1) break;
        int newsEnd = StringFind(newsSection, "</div>", newsStart);
        if (newsEnd == -1) break;
        string newsItem = StringSubstr(newsSection, newsStart, newsEnd - newsStart);
        Print("News Item: ", newsItem);
        // Parse newsItem to extract date, time, and impact
        // This example assumes a certain format, adjust as necessary
        string timeStr = ExtractBetween(newsItem, "<span class=\"time\">", "</span>");
        string impact = ExtractBetween(newsItem, "impact-", "\"");
        if (StringFind(impact, "high") != -1)
        {
            datetime newsTime = StringToTime(timeStr); // Convert to datetime
            if (newsTime > TimeCurrent())
            {
                nextNewsTime = newsTime;
                newsHighImpact = true;
                break;
            }
        }
        // Move past this news item for the next iteration
        newsSection = StringSubstr(newsSection, newsEnd);
    }
}
//+------------------------------------------------------------------+
//| Extract substring between two markers                            |
//+------------------------------------------------------------------+
string ExtractBetween(string text, string start, string end)
{
    int startIndex = StringFind(text, start);
    if (startIndex == -1) return "";
    startIndex += StringLen(start);
    int endIndex = StringFind(text, end, startIndex);
    if (endIndex == -1) return "";
    return StringSubstr(text, startIndex, endIndex - startIndex);
}
//+------------------------------------------------------------------+
//| Place Hedge Orders                                               |
//+------------------------------------------------------------------+
void PlaceHedgeOrders()
{
    double priceBuy = Ask;
    double priceSell = Bid;
    double slBuy = priceBuy - StopLoss * Point;
    double tpBuy = priceBuy + TakeProfit * Point;
    double slSell = priceSell + StopLoss * Point;
    double tpSell = priceSell - TakeProfit * Point;
    int ticketBuy = OrderSend(Symbol(), OP_BUY, Lots, priceBuy, 3, slBuy, tpBuy, "Hedge Buy Order", 0, 0, clrBlue);
    if (ticketBuy < 0) Print("Error placing buy order: ", GetLastError());
    int ticketSell = OrderSend(Symbol(), OP_SELL, Lots, priceSell, 3, slSell, tpSell, "Hedge Sell Order", 0, 0, clrRed);
    if (ticketSell < 0) Print("Error placing sell order: ", GetLastError());
}
//+------------------------------------------------------------------+
//| Button Click Handler                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == "HedgeButton")
    {
        manualHedge = true;
    }
}

*/
//=============================================================================================================================
//+------------------------------------------------------------------+
//|                                                 Elite Hedger.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include "CJAVal.mqh" // Include the CJAVal class

// Inputs
input double Lots = 0.1;
input int HedgeDistance = 12;
input int StopLoss = 25;
input int TakeProfit = 115;
input string NewsSourceURL = "http://your_server_ip:5000/fetch_news"; // Flask server URL

// Global variables
datetime nextNewsTime = 0;
bool isNewsTime = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    EventSetTimer(60); // Set timer to check news every minute
    CreateHedgeButton();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    CloseAllPendingOrders();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (isNewsTime)
    {
        // Check for existing trades
        if (OrdersTotal() == 0)
        {
            double price = MarketInfo(Symbol(), MODE_BID);
            PlaceHedgeOrders(price);
        }
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Fetch news events and check if it's time to trade
    CheckForNews();
}

//+------------------------------------------------------------------+
//| Place hedge orders                                               |
//+------------------------------------------------------------------+
void PlaceHedgeOrders(double price)
{
    double buyPrice = price + HedgeDistance * Point;
    double sellPrice = price - HedgeDistance * Point;
    
    // Place Buy order
    int buyTicket = OrderSend(Symbol(), OP_BUY, Lots, buyPrice, 3, buyPrice - StopLoss * Point, buyPrice + TakeProfit * Point, "Hedge Buy", 0, 0, Blue);
    
    // Place Sell order
    int sellTicket = OrderSend(Symbol(), OP_SELL, Lots, sellPrice, 3, sellPrice + StopLoss * Point, sellPrice - TakeProfit * Point, "Hedge Sell", 0, 0, Red);
}

//+------------------------------------------------------------------+
//| Check for news events                                            |
//+------------------------------------------------------------------+
void CheckForNews()
{
    char post[], result[];
    string headers = "";
    int timeout = 5000;
    string cookie = "";
    //int res = WebRequest("GET", NewsSourceURL, headers, timeout, post, 0, result, cookie);
    int res = WebRequest("GET", NewsSourceURL, "", 5000, post, result);

    
    if (res == -1)
    {
        Print("WebRequest Error: ", GetLastError());
        return;
    }

    // Parse JSON response
    if (res == 200)
    {
        string jsonString = CharArrayToString(result);
        Print("Response: ", jsonString);

        // Use a JSON library to parse the response
        ParseNewsJSON(jsonString);
    }
    else
    {
        Print("HTTP Error: ", res);
    }
}

//+------------------------------------------------------------------+
//| Parse the JSON response                                          |
//+------------------------------------------------------------------+
bool ParseNewsJSON(string jsonString)
{
    CJAVal jValue;
    if (jValue.Parse(jsonString) && jValue.IsArray())
    {
        int eventsCount = jValue.Size();
        for (int i = 0; i < eventsCount; i++)
        {
            CJAVal event = jValue.GetArrayElement(i);
            datetime eventTime = StringToTime(event.GetObjectValue("event_time"));
            string description = event.GetObjectValue("event_description");
            string impact = event.GetObjectValue("impact");

            // Process the event
            // Set global variables or perform necessary actions
            if (impact == "High")
            {
                nextNewsTime = eventTime;
                isNewsTime = (TimeCurrent() >= nextNewsTime && TimeCurrent() <= nextNewsTime + 60);
                return true;
            }
        }
        return false; // if no high impact event found
    }
    else
    {
        Print("Failed to parse JSON");
        return false;
    }
}

//+------------------------------------------------------------------+
//| Close all pending orders                                         |
//+------------------------------------------------------------------+
void CloseAllPendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderType() <= OP_SELL)
        {
            if (!OrderDelete(OrderTicket()))
            {
                Print("Failed to delete order: ", OrderTicket(), " Error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Create manual hedge button                                       |
//+------------------------------------------------------------------+
void CreateHedgeButton()
{
    if (!ObjectCreate(0, "HedgeButton", OBJ_BUTTON, 0, 0, 0))
    {
        Print("Failed to create button!");
        return;
    }
    ObjectSetInteger(0, "HedgeButton", OBJPROP_XSIZE, 120);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_YSIZE, 60);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_CORNER, 0);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, "HedgeButton", OBJPROP_YDISTANCE, 20);
    ObjectSetString(0, "HedgeButton", OBJPROP_TEXT, "Hedge Now");
    ObjectSetInteger(0, "HedgeButton", OBJPROP_COLOR, clrGreen);
}

//+------------------------------------------------------------------+
//| Event handler for manual hedge button click                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == "HedgeButton")
    {
        double price = MarketInfo(Symbol(), MODE_BID);
        PlaceHedgeOrders(price);
    }
}
