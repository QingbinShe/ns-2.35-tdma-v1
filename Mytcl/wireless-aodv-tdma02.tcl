#
#===============设置默认的参数val(*)===============================
#
set opt(rate)    30                    ;#默认的数据发送速率为30bit/s
#proc getopt { } {                      ;#过程geiopt从命令行获取速率参数
#    global opt
#    set opt(rate) [lindex $argv 0]     
#}

set val(chan)    Channel/WirelessChannel      ;#物理信道类型：无线信道
set val(prop)    Propagation/TwoRayGround     ;#无线传输模型：TwoRayGround
set val(netif)   Phy/WirelessPhy              ;#网络接口类型：无线物理层
set val(mac)     Mac/Tdma                     ;#MAC层：Tdma
set val(ifq)     Queue/DropTail/PriQueue      ;#接口队列类型：IFQ队列
set val(ll)      LL                           ;#逻辑链路层类型：LL层
set val(ant)     Antenna/OmniAntenna          ;#天线模型：全向天线
set val(ifqlen)  50                           ;#网络接口队列大小：50
set val(rp)      AODV                         ;#无线路由协议：AODV
set val(nn)      6                            ;#节点数目：9
set val(x)       1000                         ;#仿真区域长度1000m
set val(y)       1000                         ;#仿真区域宽度1000m
set val(stop)    20.0                          ;#设定模拟时间1.0s

#
#==============启动实例和文件等===============================
#
#建立simulator实例
set ns [new Simulator]

#开启Trace文件和NAM显示文件
set tracefd [open aodv-tdma.tr w]
set namtrace [open aodv-tdma.nam w]
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#创建topology对象
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#创建God
create-god $val(nn)
set chan_1_ [new $val(chan)]

#
#===============配置无线节点===================================
#
#无线节点配置
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channel $chan_1_ \
                -topoInstance $topo \
                -agentTrace OFF \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF \
		-phyTrace OFF

#定义节点的slot数目
Mac/Tdma set max_slot_num_ 7

#建立节点的位置
set n(0) [$ns node]
$n(0) set X_ 200.0
$n(0) set Y_ 800.0
$n(0) set Z_ 0.0
$ns initial_node_pos $n(0) 10

set n(1) [$ns node]
$n(1) set X_ 200.0
$n(1) set Y_ 570.0
$n(1) set Z_ 0.0
$ns initial_node_pos $n(1) 10

set n(2) [$ns node]
$n(2) set X_ 200.0
$n(2) set Y_ 340.0
$n(2) set Z_ 0.0
$ns initial_node_pos $n(2) 10

set n(3) [$ns node]
$n(3) set X_ 430.0
$n(3) set Y_ 630.0
$n(3) set Z_ 0.0
$ns initial_node_pos $n(3) 10

set n(4) [$ns node]
$n(4) set X_ 550.0
$n(4) set Y_ 630.0
$n(4) set Z_ 0.0
$ns initial_node_pos $n(4) 10

set n(5) [$ns node]
$n(5) set X_ 200.0
$n(5) set Y_ 110.0
$n(5) set Z_ 0.0
$ns initial_node_pos $n(5) 10

#set n(6) [$ns node]
#$n(6) set X_ 660.0
#$n(6) set Y_ 800.0
#$n(6) set Z_ 0.0
#$ns initial_node_pos $n(6) 10

#set n(7) [$ns node]
#$n(7) set X_ 660.0
#$n(7) set Y_ 570.0
#$n(7) set Z_ 0.0
#$ns initial_node_pos $n(7) 10

#set n(8) [$ns node]
#$n(8) set X_ 660.0
#$n(8) set Y_ 340.0
#$n(8) set Z_ 0.0
#$ns initial_node_pos $n(8) 10

#
#=====================设置数据流==================================
#
#从命令行获取数据源速率参数
#getopt $argc $argv
#puts "opt(rate)=$opt(rate)"

#建立数据流0从节点0到节点2
set udp(0) [new Agent/UDP]              ;#建立数据发送代理
$ns attach-agent $n(1) $udp(0)          ;#将数据发送代理绑定到节点0
set null(0) [new Agent/Null]            ;#建立一个数据接收代理
$ns attach-agent $n(0) $null(0)         ;#将数据接收代理绑定到节点2
$ns connect $udp(0) $null(0)            ;#连接两个代理
set cbr(0) [new Application/Traffic/CBR] ;#在UDP代理上建立CBR流
$cbr(0) attach-agent $udp(0)

#建立数据流1从节点3到节点4
set udp(1) [new Agent/UDP]
$ns attach-agent $n(1) $udp(1)
set null(1) [new Agent/Null]
$ns attach-agent $n(2) $null(1)
$ns connect $udp(1) $null(1)
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) attach-agent $udp(1)

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$n($i) reset"

    #让aodv能够访问tdma
    set rp($i) [$n($i) agent 255]
    $rp($i) set-mac [$n($i) set mac_(0)]
}

#程序中开始时间不要设置一样，会有rreq包冲突造成后面无法发送数据
$cbr(0) set rate_ $opt(rate)Kb          ;#设定数据流的数据速率
$ns at 0.1 "$cbr(0) start"              ;#设定数据流的启动时间
$ns at 20.0 "$cbr(0) stop"               ;#设定数据流的停止时间

$cbr(1) set rate_ $opt(rate)Kb
$ns at 7.0 "$cbr(1) start"
$ns at 20.0 "$cbr(1) stop"

#
#======================结束模拟==============================
#
#结束过程，关闭trace文件和nam文件
proc finish { } {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exit 0
}

$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"NS EXISTING...\"; $ns hait"

puts "Start Simulation..."

$ns run
