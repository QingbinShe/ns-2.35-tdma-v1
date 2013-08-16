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
set val(nn)      3                            ;#节点数目：3
set val(x)       1000                         ;#仿真区域长度160m
set val(y)       1000                         ;#仿真区域宽度100m
set val(stop)    2.1                          ;#设定模拟时间50s

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
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace OFF \
                -movementTrace OFF

#建立节点的位置
set n(0) [$ns node]
$n(0) set X_ 50.0
$n(0) set Y_ 500.0
$n(0) set Z_ 0.0
$ns initial_node_pos $n(0) 10

set n(1) [$ns node]
$n(1) set X_ 50.0
$n(1) set Y_ 300.0
$n(1) set Z_ 0.0
$ns initial_node_pos $n(1) 10

set n(2) [$ns node]
$n(2) set X_ 150.0
$n(2) set Y_ 400.0
$n(2) set Z_ 0.0
$ns initial_node_pos $n(2) 10

#
#=====================设置数据流==================================
#
#从命令行获取数据源速率参数
#getopt $argc $argv
#puts "opt(rate)=$opt(rate)"

#建立数据流0从节点0到节点2
set udp(0) [new Agent/UDP]              ;#建立数据发送代理
$ns attach-agent $n(0) $udp(0)          ;#将数据发送代理绑定到节点0
set null(0) [new Agent/Null]            ;#建立一个数据接收代理
$ns attach-agent $n(2) $null(0)         ;#将数据接收代理绑定到节点2
$ns connect $udp(0) $null(0)            ;#连接两个代理
set cbr(0) [new Application/Traffic/CBR] ;#在UDP代理上建立CBR流
$cbr(0) attach-agent $udp(0)

#建立数据流1从节点2到节点0
set udp(1) [new Agent/UDP]
$ns attach-agent $n(1) $udp(1)
set null(1) [new Agent/Null]
$ns attach-agent $n(2) $null(1)
$ns connect $udp(1) $null(1)
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) attach-agent $udp(1)

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$n($i) reset"
}

for {set i 0} {$i < 2} {incr i} {
    $cbr($i) set rate_ $opt(rate)Kb          ;#设定数据流的数据速率
    $ns at 0.1 "$cbr($i) start"              ;#设定数据流的启动时间
    $ns at 2.0 "$cbr($i) stop"               ;#设定数据流的停止时间
}

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
