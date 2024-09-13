//+------------------------------------------------------------------+
//|                                                     HikenFVG.mq4 |
//|                                                   Walker Capital |
//|                                 http://www.walkercapital.com.au/ |
//+------------------------------------------------------------------+
#property copyright "Walker Capital"
#property link      "http://www.walkercapital.com.au/"
#property version   "1.00"

#property description "We recommend next chart settings (press F8 or select menu 'Charts'->'Properties...'):"
#property description " - on 'Color' Tab select 'Black' for 'Line Graph'"
#property description " - on 'Common' Tab disable 'Chart on Foreground' checkbox and select 'Line Chart' radiobutton"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

//--- input parameters
input double Lots = 0.1;            // Initial lot size
input double SLTP_Ratio = 2;        // Stop Loss to Take Profit ratio
input double MartingaleFactor = 1.5; // Martingale factor
int MagicNumber = 12345;            // Magic number for the EA

//--- indicator buffers
double ExtLowHighBuffer[];    // Buffer to store calculated low/high values
double ExtHighLowBuffer[];    // Buffer to store calculated high/low values
double ExtOpenBuffer[];       // Buffer to store Heiken Ashi open values
double ExtCloseBuffer[];      // Buffer to store Heiken Ashi close values

//--- global variables
int buyCount = 0;             // Counter for consecutive bullish signals
int sellCount = 0;            // Counter for consecutive bearish signals
double initialLotSize;        // Stores the initial lot size set by user

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("Heiken Ashi");
    IndicatorDigits(Digits);

    //--- set initial lot size
    initialLotSize = Lots;

    //--- initialize Heiken Ashi indicator buffers
    ArrayResize(ExtLowHighBuffer, Bars);
    ArrayResize(ExtHighLowBuffer, Bars);
    ArrayResize(ExtOpenBuffer, Bars);
    ArrayResize(ExtCloseBuffer, Bars);

    //--- indicator lines
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, Red);
    SetIndexBuffer(0, ExtLowHighBuffer);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, White);
    SetIndexBuffer(1, ExtHighLowBuffer);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, 3, Red);
    SetIndexBuffer(2, ExtOpenBuffer);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, 3, White);
    SetIndexBuffer(3, ExtCloseBuffer);

    SetIndexLabel(0, "Low/High");
    SetIndexLabel(1, "High/Low");
    SetIndexLabel(2, "Open");
    SetIndexLabel(3, "Close");

    SetIndexDrawBegin(0, 10);
    SetIndexDrawBegin(1, 10);
    SetIndexDrawBegin(2, 10);
    SetIndexDrawBegin(3, 10);

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean-up code goes here if needed
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //--- calculate Heiken Ashi values
    int bars = iBars(NULL, 0);
    ArrayResize(ExtLowHighBuffer, bars);
    ArrayResize(ExtHighLowBuffer, bars);
    ArrayResize(ExtOpenBuffer, bars);
    ArrayResize(ExtCloseBuffer, bars);

    for (int i = bars - 1; i >= 0; i--)
    {
        double haOpen, haHigh, haLow, haClose;
        if (i == bars - 1)
        {
            haOpen = (iOpen(NULL, 0, i) + iClose(NULL, 0, i)) / 2;
            haClose = (iOpen(NULL, 0, i) + iHigh(NULL, 0, i) + iLow(NULL, 0, i) + iClose(NULL, 0, i)) / 4;
        }
        else
        {
            haOpen = (ExtOpenBuffer[i + 1] + ExtCloseBuffer[i + 1]) / 2;
            haClose = (iOpen(NULL, 0, i) + iHigh(NULL, 0, i) + iLow(NULL, 0, i) + iClose(NULL, 0, i)) / 4;
        }
        haHigh = MathMax(iHigh(NULL, 0, i), MathMax(haOpen, haClose));
        haLow = MathMin(iLow(NULL, 0, i), MathMin(haOpen, haClose));

        ExtOpenBuffer[i] = haOpen;
        ExtCloseBuffer[i] = haClose;
        ExtLowHighBuffer[i] = haOpen < haClose ? haLow : haHigh;
        ExtHighLowBuffer[i] = haOpen < haClose ? haHigh : haLow;
    }

    //--- trade logic
    if (bars > 3)
    {
        bool isBullish = ExtCloseBuffer[0] > ExtOpenBuffer[0] && ExtCloseBuffer[1] > ExtOpenBuffer[1] && ExtCloseBuffer[2] > ExtOpenBuffer[2];
        bool isBearish = ExtCloseBuffer[0] < ExtOpenBuffer[0] && ExtCloseBuffer[1] < ExtOpenBuffer[1] && ExtCloseBuffer[2] < ExtOpenBuffer[2];

        if (isBullish)
        {
            buyCount++;
            sellCount = 0;
            if (buyCount >= 3)
            {
                double lotSize = initialLotSize;
                for (int i = OrdersTotal() - 1; i >= 0; i--)
                {
                    if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
                    {
                        lotSize = OrderLots() * MartingaleFactor;
                        break;
                    }
                }
                PlaceOrder(OP_BUY, lotSize);
                buyCount = 0;
            }
        }
        else if (isBearish)
        {
            sellCount++;
            buyCount = 0;
            if (sellCount >= 3)
            {
                double lotSize = initialLotSize;
                for (int i = OrdersTotal() - 1; i >= 0; i--)
                {
                    if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
                    {
                        lotSize = OrderLots() * MartingaleFactor;
                        break;
                    }
                }
                PlaceOrder(OP_SELL, lotSize);
                sellCount = 0;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Function to place orders                                         |
//+------------------------------------------------------------------+
void PlaceOrder(int orderType, double lotSize)
{
    double price = 0;
    double sl = 0;
    double tp = 0;

    if (orderType == OP_BUY)
    {
        price = Ask;
        sl = price - (100 * Point);
        tp = price + (SLTP_Ratio * 100 * Point);
    }
    else if (orderType == OP_SELL)
    {
        price = Bid;
        sl = price + (100 * Point);
        tp = price - (SLTP_Ratio * 100 * Point);
    }

    int ticket = OrderSend(Symbol(), orderType, lotSize, price, 3, sl, tp, "Heiken Ashi EA", MagicNumber, 0, Blue);
    if (ticket < 0)
    {
        Print("OrderSend failed with error #", GetLastError());
    }
}

//+------------------------------------------------------------------+


