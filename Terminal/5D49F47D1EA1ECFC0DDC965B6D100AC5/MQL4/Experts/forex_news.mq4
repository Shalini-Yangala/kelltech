//+------------------------------------------------------------------+
//|                                                 SupraScalper.mq4 |
//|                                               Copyright 2024,NA. |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, NA."
#property link      "N/A"
#property version   "1.00"
#property strict
#define FILE_NAME "ff_calendar_thisweek.csv" //forex factory weekly news csv file
#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>
// Global variables to store news data
datetime highImpactNewsTimes[];
int newsCount = 0;
bool newsFilterActive = false;
// Variables for manage automatic hedging
datetime nextHighImpactEvent = 0;
string eventTitle = "";
string eventCurrency = "";
bool newsFound = false;
// Variable to track the last trade time
datetime lastTradeTime = 0;
// Array to store the ticket numbers of closed trades during each tick iteration
int closedTickets[100]; // Adjust the size as needed
//+-----------------------------------------------------------------------------------------+
//| Function to read CSV file and filter high-impact news along with selected Currency      |
//+-----------------------------------------------------------------------------------------+
bool ReadNewsData()
{
    // Get the current chart's symbol
    string chartSymbol = _Symbol;
    // Extract base and quote currencies dynamically
    string baseCurrency = StringSubstr(chartSymbol, 0, 3);
    string quoteCurrency = StringSubstr(chartSymbol, 3, 3);
    // Open the news event file
    int file_handle = FileOpen(FILE_NAME, FILE_CSV | FILE_READ | FILE_ANSI);
    if (file_handle < 0)
    {
        Print("Error opening file: ", FILE_NAME, " with error: ", GetLastError());
        return (false);
    }
    string line;
    bool isFirstLine = true;
    datetime currentTime = TimeCurrent();
    while (!FileIsEnding(file_handle))
    {
        line = FileReadString(file_handle);
        if (isFirstLine)
        {
            isFirstLine = false;
            continue; // Skip header if there's one
        }
        string data[];
        StringSplit(line, ',', data);
        // Skip if not enough data
        if (ArraySize(data) < 6)
            continue;
        string title = data[0];
        string currency = data[1];
        string date = data[2];
        string time = data[3];
        string impact = data[4];
        // Convert date and time to datetime
        datetime eventTime = StrToTime(date + " " + time);
        // Print debug information
        Print("Comparing currency:", currency, " Base:", baseCurrency, " Quote:", quoteCurrency);
        // Check if the news is high-impact, relevant to the chart's asset, and in the future
        if (StringFind(impact, "High") >= 0 &&
            (currency == baseCurrency || currency == quoteCurrency) &&
            eventTime > currentTime)
        {
            // If this is the first event or it's earlier than the current next event, set it as the next event
            if (nextHighImpactEvent == 0 || eventTime < nextHighImpactEvent)
            {
                nextHighImpactEvent = eventTime;
                eventTitle = title;
                eventCurrency = currency;
            }
            newsFound = true;
        }
        else
        {
            // Handle the case where the news is not high-impact, relevant to the chart's asset, or in the future
            // For example, you can print a message indicating that the news is not relevant
            Comment("News is not high-impact, relevant to the chart's asset, or in the future:", title);
        }
    }
    if (nextHighImpactEvent > 0)
    {
        Print("Next high-impact event loaded: ", eventTitle, " (", eventCurrency, ") at ", TimeToString(nextHighImpactEvent));
        return true;
    }
    else
    {
        Comment("No upcoming high-impact events found.");
    }
    return false;
}
// Function to check if current time is near any high-impact news time
bool IsNewsTime()
{
    datetime now = TimeCurrent();
    datetime newsTime = nextHighImpactEvent;
    if (now >= newsTime - 5 * 60 && now <= newsTime + 5 * 60)
    {
        return true;
    }
    return false;
}
// Function to check buy condition
bool BuyCondition()
{
    double ao = iAO(NULL, 0, 0);
    double stochK = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
    double stochD = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
    if (ao > 0 && stochK > 20 && stochD > 20 && stochK < 80 && stochD < 80 && stochK > stochD)
    {
        return true;
    }
    return false;
}
// Function to check sell condition
bool SellCondition()
{
    double ao = iAO(NULL, 0, 0);
    double stochK = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
    double stochD = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
    if (ao < 0 && stochK > 20 && stochD > 20 && stochK < 80 && stochD < 80 && stochK < stochD)
    {
        return true;
    }
    return false;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("EA Initialized");
    ReadNewsData(); // Read and filter news data
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("EA Deinitialized");
}
//+------------------------------------------------------------------+
//| Main trading logic                                               |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if it's time to avoid trading due to high-impact news
    if (IsNewsTime())
    {
        if (!newsFilterActive)
        {
            newsFilterActive = true;
            // Close all open positions
            int total = OrdersTotal();
            for (int i = total - 1; i >= 0; i--)
            {
                if (OrderSelect(i, SELECT_BY_POS) && OrderType() <= OP_SELL)
                {
                    int ticket = OrderTicket();
                    // Check if the ticket number is already in the closedTickets array
                    bool ticketClosed = ArrayContains(closedTickets, ticket, ArraySize(closedTickets));
                    if (!ticketClosed)
                    {
                        if (!OrderClose(ticket, OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE))
                        {
                            Print("Error closing order: ", GetLastError());
                        }
                        // Add the ticket number to the closedTickets array to mark it as closed
                        for (int j = 0; j < ArraySize(closedTickets); j++)
                        {
                            if (closedTickets[j] == 0)
                            {
                                closedTickets[j] = ticket;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return;
    }
    else
    {
        newsFilterActive = false;
    }
    datetime currentCandleTime = iTime(NULL, 0, 0);
    // Check if a trade was already placed in the current candle
    if (lastTradeTime == currentCandleTime)
    {
        Print("Trade already placed for this candle at time: ", TimeToString(lastTradeTime));
        return;
    }
    // Trade logic
    if (BuyCondition())
    {
        // Open buy order
        int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Buy order", 0, 0, Green);
        if (ticket < 0)
        {
            Print("Error sending buy order: ", GetLastError());
        }
        else
        {
            lastTradeTime = currentCandleTime;
            Print("Buy order placed for symbol: ", Symbol(), " at time: ", TimeToString(lastTradeTime));
        }
    }
    else if (SellCondition())
    {
        // Open sell order
        int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Sell order", 0, 0, Red);
        if (ticket < 0)
        {
            Print("Error sending sell order: ", GetLastError());
        }
        else
        {
            lastTradeTime = currentCandleTime;
            Print("Sell order placed for symbol: ", Symbol(), " at time: ", TimeToString(lastTradeTime));
        }
    }
}
//+------------------------------------------------------------------+
//| Function to check if an array contains a specific value          |
//+------------------------------------------------------------------+
bool ArrayContains(int& array[], int value, int size)
{
    for (int i = 0; i < size; i++)
    {
        if (array[i] == value)
        {
            return true;
        }
    }
    return false;
}