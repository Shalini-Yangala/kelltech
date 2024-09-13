//+------------------------------------------------------------------+
//|                                                      AlphaTrend.mq4|
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                        https://www.mql5.com      |
//+------------------------------------------------------------------+
#property strict
#property  indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//--- input parameters
input double coeff = 1.0;  // Multiplier
input int AP = 14;         // Common Period
input bool showsignalsk = true; // Show Signals?
input bool novolumedata = false; // Change calculation (no volume data)?

//--- indicator buffers
double AlphaTrendBuffer[];
double AlphaTrendPrevBuffer[];

//--- indicator handles
//int handleATR;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, AlphaTrendBuffer);
    SetIndexBuffer(1, AlphaTrendPrevBuffer);
    
    //--- create handle for ATR
    //handleATR = iATR(NULL, 0, AP,0);
    
    //--- set indicator properties
    IndicatorShortName("AlphaTrend");
    
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
    if (rates_total < AP) return(0);
    
    int start = prev_calculated > 0 ? prev_calculated - 1 : AP;
    
    //double ATRArray[];
    //CopyBuffer(handleATR, 0, 0, rates_total, ATRArray);
    
    double handleATR = iATR(NULL, 0, AP,0);
    
    for (int i = start; i < rates_total; i++)
    {
        double upT = low[i] - handleATR * coeff;
        double downT = high[i] + handleATR * coeff;
        
        if (novolumedata ? iRSI(NULL, 0, AP, PRICE_CLOSE, i) >= 50 : iMFI(NULL, 0, AP, i) >= 50)
        {
            AlphaTrendBuffer[i] = upT < AlphaTrendPrevBuffer[i-1] ? AlphaTrendPrevBuffer[i-1] : upT;
        }
        else
        {
            AlphaTrendBuffer[i] = downT > AlphaTrendPrevBuffer[i-1] ? AlphaTrendPrevBuffer[i-1] : downT;
        }
        
        AlphaTrendPrevBuffer[i] = AlphaTrendBuffer[i];
    }
    
    return(rates_total);
}
