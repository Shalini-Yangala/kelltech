<chart>
id=133637051998583838
symbol=AUDUSD
period=5
leftpos=11268
digits=5
scale=8
graph=1
fore=0
grid=1
volume=0
scroll=1
shift=0
ohlc=1
one_click=0
one_click_btn=1
askline=0
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=38
window_top=38
window_right=1374
window_bottom=456
window_type=3
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=100
fixed_height=0
<indicator>
name=main
<object>
type=28
object_name=mainPanel
period_flags=0
create_time=1719231722
description=RectangleLabel
color=8421504
font=Arial
fontsize=10
background=1
filling=0
selectable=0
hidden=1
zorder=0
corner=0
x_distance=30
y_distance=30
size_x=300
size_y=150
bgcolor=65535
border_type=2
</object>
<object>
type=28
object_name=leftPanelBG
period_flags=0
create_time=1719231722
description=RectangleLabel
color=8421504
font=Arial
fontsize=10
background=1
filling=0
selectable=0
hidden=1
zorder=0
corner=0
x_distance=40
y_distance=40
size_x=280
size_y=130
bgcolor=16777184
border_type=2
</object>
<object>
type=23
object_name=SMA_Short_Label
period_flags=0
create_time=1719231722
description=Symbol: EURUSD
color=0
font=Arial
fontsize=10
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=50
y_distance=50
</object>
<object>
type=23
object_name=SMA_Long_Label
period_flags=0
create_time=1719231722
description=Timeframe: PERIOD_M5
color=0
font=Arial
fontsize=10
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=50
y_distance=80
</object>
<object>
type=23
object_name=Crossover_Status_Label
period_flags=0
create_time=1719231722
description=Signal: Neutral
color=0
font=Arial
fontsize=10
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=50
y_distance=110
</object>
<object>
type=23
object_name=Trade_Status_Label
period_flags=0
create_time=1719231722
description=
color=0
font=Arial
fontsize=10
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=50
y_distance=140
</object>
</indicator>
</window>

<expert>
name=CrossTrade2
flags=275
window_num=0
<inputs>
Symbols=EURUSD, USDCAD, GBPUSD, AUDUSD, USDJPY, USDCHF,NZDUSD
Timeframe=5
ShortMAPeriod=9
LongMAPeriod=21
RSIPeriod=14
OverboughtLevel=70.0
OversoldLevel=30.0
MACD_FastEMA=12
MACD_SlowEMA=26
MACD_SignalSMA=9
</inputs>
</expert>
</chart>

