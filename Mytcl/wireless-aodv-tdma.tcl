Class TestSuite

#wireless model using aodv
Class Test/aodv -superclass TestSuite

proc usage { } {
    global argv0
    puts stderr "usage: ns $argv0 <tests>"
    puts "Valid Tests: aodv"
    exit 1
}

proc default_options { } {
    global opt
    set opt(chan)  Channel/WirelessChannel
    set opt(prop)  Propagation/FreeSpace ;#the propagation is ideal model
    set opt(netif) Phy/WirelessPhy
    set opt(mac)   Mac/Tdma
    set opt(ifq)   Queue/DropTail/PriQueue ;#queue model
    set opt(ll)    LL
    set opt(ant)   Antenna/OmniAntenna
    set opt(x)     670 ;#x dimension of the topography
    set opt(y)     670 ;#y dimension of the topography
    set opt(ifqlen) 50 ;#max packet in ifq
    set opt(seed)  0.0
    set opt(tr)    temp.rands ;#trace file
    set opt(lm)    "off" ;#log movement
    set opt(energy) EnergyModel ;#energymodel
}


#======================================================
#Other default settings

set AgentTrace    ON
set RouterTrace   OFF
set MacTrace      OFF

#Mac/Tdma set slot_packet_len_ 512
#Mac/Tdma set max_node_num_ 50

LL set mindelay_ 50us
LL set delay_ 25us
LL set bandwidth_ 0 ;#not used

Agent/Null set sport_ 0
Agent/Null set dport_ 0
Agent/CBR set sport_ 0
Agent/CBR set dport_ 0

Queue/DropTail/PriQueue set Prefer_Routing_Protocols 1

#unity gain, omni-directional antennas
#set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

#Initialize the ShareMedia interface with parameters to make
#it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.28183815
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0

#======================================================

TestSuite instproc init { } {
    global opt tracefd topo chan prop
    global node_ god_
    $self instvar ns_ testName_
    set ns_  [new Simulator]
    if { string compare $testName_ "aodv" } {
        $ns_ set-address-format hierarchical
        AddrParams set domain_num_ 3
        lappend cluster_num 2 1 1
        AddrParams set cluster_num_ $cluster_num
        lappend eilastlevel 1 1 4 1
        AddrParams set nodes_num_ $eilastlevel
    }
    set topo [new Topography]
    set tracefd [open $opt(tr) w]

    $topo load_flatgrid $opt(x) $opt(y)
    $ns_ trace-all $tracefd

    #create God
    $self create-god $opt(nn)

    #log the mobile nodes movements if desired
    if { $opt(lm) == "on" } {
        $self log-movement
    }
    
    puts $tracefd "M 0.0 nn:$opt(nn) x:$opt(x) y:$opt(y) rp:$opt(rp)"
    puts $tracefd "M 0.0 sc:$opt(sc) cp:$opt(cp) seed:$opt(seed)"
    puts $tracefd "M 0.0 prop:$opt(prop) ant:$opt(ant)"
}

Test/aodv instproc init { } {
    global opt node_ god_ chan topo
    $self instvar ns_ testName_
    set testName_ aodv
    set opt(rp) aodv
    set opt(cp) "../mobility/scene/cbr-50-20-4-512"
    set opt(sc) "../mobility/scene/scen-670x670-50-600-20-0"
    set opt(nn) 50
    set opt(stop) 1000.0

    $self next

    #create God
    set god_ [create-god $opt(nn)]

    $ns_ node-config -adhocRouting AODV \
            -llType $opt(ll) \
            -macType $opt(mac) \
            -ifqType $opt(ifq) \
            -ifqLen $opt(ifqlen) \
            -antType $opt(ant) \
            -propType $opt(prop) \
            -phyType $opt(netif) \
            -channel [new $opt(chan)] \
            -topoInstance $topo \
            -agentTrace ON \
            -routerTrace ON \
            -macTrace OFF \
            -toraDebug OFF \
            -movementTrace OFF

    for {set i 0} {$i < $opt(nn)} {incr i} {
        set node_($i) [$ns_ node]
        $node_($i) random-motion 0
    }

    puts "Loading connection pattern..."
    source $opt(cp)

    puts "Loading scenario file..."
    source $opt(sc)
    puts "Load complete..."

    $ns_ at $opt(stop) "puts \"NS EXITING...\";"
    $ns_ at $opt(stop).1 "$self finish-aodv"
}

Test/aodv instproc run { } {
    $self instvar ns_
    puts "Starting Simulation..."
    $ns_ run
}

TestSuite instproc finish-aodv { } {
    $self instvar ns_
    global quiet opt tracefd
    $ns_ flush-trace
    close $tracefd
    puts "finish..."
    exit 0
}

TestSuite instproc finish { } {
    $self instvar ns_
    global quiet

    $ns_ flush-trace
    puts "finishing.."
    exit 0
}
