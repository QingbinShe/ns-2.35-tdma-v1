BEGIN {
	init=0;
	i=0;
}
{
	event = $1;
	time = $2;
	node = $3;
	
	len = length(node);
	if(len == 3) {
		node_ = substr(node,2,1);
		trace_type = $4;
		flag = $5;
		uid = $6;
		pkt_type = $7;
		pkt_size = $8;
	}else {
		from_node = $3;
		to_node = $4;
		pkt_type = $5;
		pkt_size = $6;
		flag = $7;
		uid = $12;
	}
	if(len == 1) {
		if(event=="r" && to_node==0&& pkt_type=="cbr") {
			pkt_byte_sum[i+1]=pkt_byte_sum[i]+(pkt_size-20);
			if(init==0) {
				start_time=time;
				init=1;
			}
			end_time[i]=time;
			i++;
		}
	}
}

END {
	th = (8*pkt_byte_sum[i-1])/(end_time[i-1]-start_time)/1000;
	#th = 8*pkt_byte_sum[i-1];
	printf("%.2f\n", th);
}
