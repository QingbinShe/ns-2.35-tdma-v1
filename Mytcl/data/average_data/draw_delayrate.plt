#ddddd
set terminal postscript eps color
set output 'delay.eps'
set xlabel "The number of flows"
set ylabel "Average end-to-end delay(s)"
set size 0.8,0.8
set key at 28,0.4
plot "delay_rate5o" title "N-QoS-TDMA slot=5" with linespoints, "delay_rate5" title "D-QoS-TDMA slot=5" with linespoints, "delay_rate7o" title "N-QoS-TDMA slot=7" with linespoints, "delay_rate7" title "D-QoS-TDMA slot=7" with linespoints #, "delay_rate9o" title "Aslot=9" with linespoints, "delay_rate9" title "Bslot=9" with linespoints
