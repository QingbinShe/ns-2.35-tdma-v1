#先在terminal输入gnuplot
#然后载入文件用load "filename"
set terminal postscript eps color
set output 'drop.eps'
set xlabel "The number of flows"
set ylabel "Packet loss radio"
set size 0.8,0.8
set key at 29,0.25
plot "drop_rate5o" title "N-QoS-TDMA slot=5" with linespoints, "drop_rate5" title "D-QoS-TDMA slot=5" with linespoints, "drop_rate7o" title "N-QoS-TDMA slot=7" with linespoints, "drop_rate7" title "D-QoS-TDMA slot=7" with linespoints, "drop_rate9o" title "N-QoS-TDMA slot=9" with linespoints, "drop_rate9" title "D-QoS-TDMA slot=9" with linespoints #, "drop_rate13o" title "Aslot=13" with linespoints, "drop_rate13" title "Bslot=13" with linespoints
