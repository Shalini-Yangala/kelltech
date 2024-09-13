
//+------------------------------------------------------------------+
//|                                                ShalluGannFan.mq4 |
//|                       Copyright 2024, Kelltech digital solutions |
//|                                                              N/A |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kelltech digital solutions"
#property link      "N/A"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
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
   
   //calculate the number for the visible candles
   int CandlesOnChart=WindowFirstVisibleBar();
   //Find the highest candle on the chart
   int HighestCandle=iHighest(_Symbol,_Period,MODE_HIGH,CandlesOnChart,0);
   
   //Delete the object
   ObjectDelete("SimpleHighGannFan");
   
   //Create Object
   ObjectCreate(
                     0,                   //for the current cart
                     "SimpleHighGannFan",  //object name
                     OBJ_GANNFAN,        //Object type
                     0,                   //In the Main chart
                     Time[HighestCandle], //from the highest candle
                     High[HighestCandle],   //from the highest price
                     Time[0],               // to the current candle
                     High[0]                //for the highest price
                    );
                     
         
      //Set the object color
         
         ObjectSetInteger(0,"SimpleHighGannFan",OBJPROP_COLOR,Orange);
         
         //set the object prediction
         ObjectSetInteger(0,"SimpleHighGannFan",OBJPROP_RAY,true);
         
                     
  }
//+------------------------------------------------------------------+
















