BEGIN {
	pkt_byte_sum = 0;
}
{
	event = $1;
	time = $2;
	node_ = $3;
	uid = $6;
	pkt_type = $7;
	pkt_size = $8;

	node = substr(node_,2,1);
	if (event=="r" && pkt_type=="cbr") {
		pkt_byte_sum = pkt_byte_sum + (pkt_size - 20);
		
		if (init[node] == 0) {
			start_time[node] = time;
			init[node] = 1;
		}
		end_time[node] = time;
	}
	
}

END {
	start = 0;
	end = 0;
	for (i = 0; i < 25; i++) {
		start = start + start_time[i];
		end = end + end_time[i];
	}
	if (end == 0) printf("%f\n", 0); #所有包丢失，设为0
	else printf("%f\n", 8 * pkt_byte_sum / (end - start) / 1000);
}
