#
#===============设置默认的参数val(*)===============================
#
set opt(rate)	20                    ;#默认的数据发送速率为30bit/s

set opt(flow)	0			;#flow个数
proc getopt {argc argv} {                      ;#过程geiopt从命令行获取速率参数
    global opt
    set opt(flow) [lindex $argv 0]     
}

set val(chan)    Channel/WirelessChannel      ;#物理信道类型：无线信道
set val(prop)    Propagation/TwoRayGround     ;#无线传输模型：TwoRayGround
set val(netif)   Phy/WirelessPhy              ;#网络接口类型：无线物理层
set val(mac)     Mac/Tdma                     ;#MAC层：Tdma
set val(ifq)     Queue/DropTail/PriQueue      ;#接口队列类型：IFQ队列
set val(ll)      LL                           ;#逻辑链路层类型：LL层
set val(ant)     Antenna/OmniAntenna          ;#天线模型：全向天线
set val(ifqlen)  50                           ;#网络接口队列大小：50
set val(rp)      AODV                         ;#无线路由协议：AODV
set val(nn)      25                           ;#节点数目：9
set val(x)       1000                         ;#仿真区域长度1000m
set val(y)       1000                         ;#仿真区域宽度1000m
set val(stop)    100.0                          ;#设定模拟时间1.0s

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
                -movementTrace OFF \

#定义节点的slot数目
Mac/Tdma set max_slot_num_ 5

#建立节点的位置
set i 0				;#节点数目
while {$i < 5} {		;#第一列
	set n($i) [$ns node]
	$n($i) set X_ 50
	$n($i) set Y_ [expr 50+200*$i]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 10
	
	incr i
}

while {$i < 10} {
	set n($i) [$ns node]
	$n($i) set X_ 250
	$n($i) set Y_ [expr 50+200*($i-5)]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 10
	
	incr i
}

while {$i < 15} {
	set n($i) [$ns node]
	$n($i) set X_ 450
	$n($i) set Y_ [expr 50+200*($i-10)]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 10
	
	incr i
}

while {$i < 20} {
	set n($i) [$ns node]
	$n($i) set X_ 650
	$n($i) set Y_ [expr 50+200*($i-15)]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 10
	
	incr i
}

while {$i < 25} {
	set n($i) [$ns node]
	$n($i) set X_ 850
	$n($i) set Y_ [expr 50+200*($i-20)]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 10
	
	incr i
}


#=====================设置数据流==================================
#
#建立数据流0从节点0到节点2
#set udp(10) [new Agent/UDP]              ;#建立数据发送代理
#$ns attach-agent $n(0) $udp(10)          ;#将数据发送代理绑定到节点0
#set null(10) [new Agent/Null]            ;#建立一个数据接收代理
#$ns attach-agent $n(24) $null(10)         ;#将数据接收代理绑定到节点2
#$ns connect $udp(10) $null(10)            ;#连接两个代理
#set cbr(10) [new Application/Traffic/CBR] ;#在UDP代理上建立CBR流
#$cbr(10) attach-agent $udp(10)

#获得数据流个数
getopt $argc $argv
puts "opt(flow)=$opt(flow)"

#获得随机数
proc RandomRange {min max} {
    #获得[0.0  1.0]之间的随机数
    set rd [expr rand()]

    #将$rd放大到[$min $max]
    set result [expr $rd*($max-$min)+$min]
    
    return $result
}
#获得整数型随机数
proc RandomRangeInt {min max} {
    return [expr int([RandomRange $min $max])]
}

#设置数据流
for {set i 0} {$i < $opt(flow)} {incr i} {
    set node0 [RandomRangeInt 0 24]
    set node1 [RandomRangeInt 0 24]

    while {$node0 == $node1} {
        set node0 [RandomRangeInt 0 24]
        set node1 [RandomRangeInt 0 24]
    }

puts "$i $node0 $node1"

    set udp($i) [new Agent/UDP]
    $ns attach-agent $n($node0) $udp($i)
    set null($i) [new Agent/Null]
    $ns attach-agent $n($node1) $null($i)
    $ns connect $udp($i) $null($i)
    set cbr($i) [new Application/Traffic/CBR]
    $cbr($i) attach-agent $udp($i)
}


for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$n($i) reset"

    #让aodv能够访问tdma
    set rp($i) [$n($i) agent 255]
    $rp($i) set-mac [$n($i) set mac_(0)]
}

#程序中开始时间不要设置一样，会有rreq包冲突造成后面无法发送数据
#$cbr(10) set rate_ $opt(rate)Kb          ;#设定数据流的数据速率
#$ns at 1.0 "$cbr(10) start"              ;#设定数据流的启动时间
#$ns at 20.0 "$cbr(10) stop"               ;#设定数据流的停止时间

#设置数据流开始结束时间
for {set i 0} {$i < $opt(flow)} {incr i} {
    $cbr($i) set rate_ $opt(rate)Kb

    set time0 [RandomRange 0 $val(stop)]
    set time1 [RandomRange 0 $val(stop)]

    #因为在aodv中，对slot的清除最大设置为50s且time0要比time1小
    while {$time0 >= $time1 || [expr $time1 - $time0] > 50} {
        set time0 [RandomRange 0 $val(stop)]
        set time1 [RandomRange 0 $val(stop)]
    }

puts "$time0 $time1"

    $ns at $time0 "$cbr($i) start"
    $ns at $time1 "$cbr($i) stop"
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
