#ddddd
set terminal postscript eps color
set output 'throughput.eps'
set xlabel "The number of flows"
set ylabel "Average network throughput(Kb/s)"
set size 1,1
set key at 29,15
plot "throughput_rate5o" title "N-QoS-TDMA slot=5" with linespoints, "throughput_rate5" title "D-QoS-TDMA slot=5" with linespoints, "throughput_rate7o" title "N-QoS-TDMA slot=7" with linespoints, "throughput_rate7" title "D-QoS-TDMA slot=7" with linespoints, "throughput_rate9o" title "N-QoS-TDMA slot=9" with linespoints, "throughput_rate9" title "D-QoS-TDMA slot=9" with linespoints
