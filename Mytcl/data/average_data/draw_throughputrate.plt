#ddddd
set terminal postscript eps color
set output 'throughput.eps'
set xlabel "The number of flows"
set ylabel "Average network throughput"
set size 0.7,0.7
set key at 15,20.5
plot "throughput_rate7o" title "N-QoS-Tdma slot=7" with linespoints, "throughput_rate7" title "D-QoS-Tdma slot=7" with linespoints #, "throughput_rate7o" title "Aslot=7" with linespoints, "throughput_rate7" title "Bslot=7" with linespoints #, "throughput_rate9o" title "Aslot=9" with linespoints, "throughput_rate9" title "Bslot=9" with linespoints
