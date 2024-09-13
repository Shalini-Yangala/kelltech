#property copyright "Copyright © 2011, fxprotrader"
#property link      "http://www.fxpro-trader.com"
//----------------------- HISTORY
// v0.1 Initial release(103011)
//----------------------- 

#property indicator_chart_window
extern int NumberOfBars   = 100;  
//determines whether 2 bars next to each other are too close together to constitute a double top/bot
//setting to 0 will show even 2 bars next to each other
//to filter those out set to anything gtr
extern int BarsMinSeparation   = 0;  
extern color TopBarColor    = Red;
extern color BottomBarColor = LimeGreen;
extern int LineWidth = 2;
extern int LineStyle = 2;
datetime thisbartime=0;


double Poin;
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   DeleteObjects();
   return(0);
}
//+----------------------------------------------------------------------------+
//
//+----------------------------------------------------------------------------+
int init() {
   if (Point == 0.00001) Poin = 0.0001;
   else {
      if (Point == 0.001) Poin = 0.01;
      else Poin = Point;
   }
   return (0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int DeleteObjects(){
//---- 
// ObjectDelete("ATLtext1");
// ObjectDelete("ATLtext2");

for (int shift=100; shift>0; shift--) {
  ObjectDelete("DailyRLine1_"+shift);
  ObjectDelete("DailyTrend1_"+shift);
  ObjectDelete("DailyTrend2_"+shift);
  
  }
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

double val1,val2; 
color LineClr;
int x;
int cnt1=0,cnt2=0;
int thissz=0;
double LinePos1,LinePos2,LinePos3;

int ele_indx1=0;
int ele_indx2=0;
double this_ele1,this_ele2;
int Time1,Time2,DistanceTop,DistanceBot;

string sObjName,text;
int Color1,Color2;


if(thisbartime!=Time[0]){
thisbartime=Time[0]; 

// Print("<<<start this compile xx>>>");
//    DeleteObjects();
// 
//  text="50";
//  sObjName="ATLtext1";
//  ObjectCreate(sObjName, OBJ_TEXT, 0, Time[50], High[50]+150*Point);
//  ObjectSetText(sObjName, text, 9, "Arial", Yellow);
// 
// text="100";
// sObjName="ATLtext2";
//  ObjectCreate(sObjName, OBJ_TEXT, 0, Time[100], High[100]+150*Point);
//  ObjectSetText(sObjName, text, 9, "Arial", Yellow);


//using two separate arrays
//one to sort to find highest and lowest
//the other remains unsorted which then is searched
//to find the index of the selected highest and lowest
double myarray1[100];
double myarray2[100];
double myarray3[100];
double myarray4[100];
if(NumberOfBars>100){
NumberOfBars=100;
}

for (int i=0; i<NumberOfBars; i++) {
val1 = High[i];
val2 = Low[i];
if(val1 > 0){
cnt1++;
myarray1[cnt1] = val1;
myarray2[cnt1] = val1;
myarray3[cnt1] = val2;
myarray4[cnt1] = val2;
}
}//for


//top
thissz = ArrayResize(myarray1,NumberOfBars);
ArraySort(myarray1,WHOLE_ARRAY,1,MODE_ASCEND);


 LinePos1 = (myarray1[cnt1-1]);
 LinePos2 = (myarray1[cnt1-4]);
//  LinePos2 = (myarray1[cnt1/2]-8*Poin);
//  LinePos3 = (myarray1[cnt1-1]-8*Poin);

// Alert ("j:"+j+" "+Symbol()+"cnt1:"+cnt1+">> newarray1");
// for ( x=0; x<thissz; x++) {
//  this_ele1 = myarray1[x+1];
//  //Alert (Symbol()+"---myarray2["+x+"] " + myarray2[x]);
// //  }// last_ele = myarray1[x-1];
// if(this_ele1==LinePos1){
// if(last_ele>this_ele){
// // Print ("HIT"+this_ele+"__"+LinePos2+" at "+x);
// ele_indx1=x;
//  }
//  }
for ( x=1; x<thissz; x++) {
 this_ele1 = myarray2[x+1];
 this_ele2 = myarray2[x+1];
 //Alert (Symbol()+"---myarray2["+x+"] " + myarray2[x]);
if(this_ele1==LinePos1){
 //Print ("topHIT1 "+this_ele1+"::"+LinePos1+" at "+x);
ele_indx1=x;
 }
if(this_ele2==LinePos2){
// Print ("topHIT2 "+this_ele2+"::"+LinePos2+" at "+x);
ele_indx2=x;
 }
 }

//orient the line correctly
if(ele_indx2 > ele_indx1){
 DistanceTop=MathAbs(ele_indx1-ele_indx2);

//LineClr=Red;
if(ele_indx2<5){
Time1 = ele_indx1;
Time2 = ele_indx2+5;
}
else{
Time1 = ele_indx1-ele_indx1;
Time2 = ele_indx2+5;
}
}

else{
 DistanceTop=MathAbs(ele_indx2-ele_indx1);

//LineClr=Yellow;
if(ele_indx2<5){
Time1 = ele_indx1+5;
Time2 = ele_indx2;
}

else{
Time1 = ele_indx1+5;
Time2 = ele_indx2-ele_indx2;
}
}
 
//Print (Symbol()+"thissz:"+thissz+"LinePos1:"+LinePos1+"  ele_indx1:"+ele_indx1+"  ele_indx2:"+ele_indx2+" Dis:"+Distance);
//  sObjName="DailyRLine1_"+cnt1;
// ObjectCreate(sObjName,OBJ_HLINE,0,Time[1],LinePos1);        
//  ObjectSet(sObjName,OBJPROP_COLOR,DarkKhaki);
//  ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASH);
//  ObjectSet(sObjName,OBJPROP_WIDTH,1);
//  
if(DistanceTop > BarsMinSeparation){

 sObjName="DailyTrend1_"+cnt1;      
ObjectCreate(sObjName, OBJ_TREND,0,Time[Time1],LinePos2,Time[Time2],LinePos2);
 ObjectSet(sObjName, OBJPROP_WIDTH, LineWidth);
 ObjectSet(sObjName,OBJPROP_RAY,false);
 ObjectSet(sObjName, OBJPROP_STYLE, LineStyle);
 ObjectSet(sObjName, OBJPROP_COLOR, TopBarColor);
}


//bottom
thissz = ArrayResize(myarray3,NumberOfBars);
ArraySort(myarray3,WHOLE_ARRAY,1,MODE_DESCEND);


 LinePos1 = (myarray3[cnt1-1]);
 LinePos2 = (myarray3[cnt1-4]);
//  LinePos2 = (myarray1[cnt1/2]-8*Poin);
//  LinePos3 = (myarray1[cnt1-1]-8*Poin);

// Alert ("j:"+j+" "+Symbol()+"cnt1:"+cnt1+">> newarray1");
// for ( x=0; x<thissz; x++) {
//  this_ele1 = myarray1[x+1];
//  //Alert (Symbol()+"---myarray2["+x+"] " + myarray2[x]);
// //  }// last_ele = myarray1[x-1];
// if(this_ele1==LinePos1){
// if(last_ele>this_ele){
// // Print ("HIT"+this_ele+"__"+LinePos2+" at "+x);
// ele_indx1=x;
//  }
//  }
for ( x=1; x<thissz; x++) {
 this_ele1 = myarray4[x+1];
 this_ele2 = myarray4[x+1];
 //Alert (Symbol()+"---myarray4["+x+"] " + myarray4[x]);
if(this_ele1==LinePos1){
// Print ("botHIT1 "+this_ele1+"::"+LinePos1+" at "+x);
ele_indx1=x;
 }
if(this_ele2==LinePos2){
// Print ("botHIT2 "+this_ele2+"::"+LinePos2+" at "+x);
ele_indx2=x;
 }
 }

//orient the line correctly
if(ele_indx2 > ele_indx1){
 DistanceBot=MathAbs(ele_indx1-ele_indx2);

//LineClr=Blue;
if(ele_indx2<5){
Time1 = ele_indx1;
Time2 = ele_indx2+5;
}
else{
Time1 = ele_indx1-ele_indx1;
Time2 = ele_indx2+5;
}
}

else{
 DistanceBot=MathAbs(ele_indx2-ele_indx1);

//LineClr=LimeGreen;
if(ele_indx2<5){
Time1 = ele_indx1+5;
Time2 = ele_indx2;
}

else{
Time1 = ele_indx1+5;
Time2 = ele_indx2-ele_indx2;
}
}

//Print (Symbol()+"thissz:"+thissz+"LinePos1:"+LinePos1+"  ele_indx1:"+ele_indx1+"  ele_indx2:"+ele_indx2+" Dis:"+Distance);
// sObjName="DailyRLine1_"+cnt1;
//  ObjectCreate(sObjName,OBJ_HLINE,0,Time[1],LinePos1);        
//  ObjectSet(sObjName,OBJPROP_COLOR,DarkKhaki);
//  ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASH);
//  ObjectSet(sObjName,OBJPROP_WIDTH,1);
 
if(DistanceBot > BarsMinSeparation){

 sObjName="DailyTrend2_"+cnt1;      
ObjectCreate(sObjName, OBJ_TREND,0,Time[Time1],LinePos2,Time[Time2],LinePos2);
 ObjectSet(sObjName, OBJPROP_WIDTH, LineWidth);
 ObjectSet(sObjName,OBJPROP_RAY,false);
 ObjectSet(sObjName, OBJPROP_STYLE, LineStyle);
 ObjectSet(sObjName, OBJPROP_COLOR, BottomBarColor);
}

//Print("distance T:"+DistanceTop+" B:"+DistanceBot);

 return(0);
 }
 
}
//+------------------------------------------------------------------+
