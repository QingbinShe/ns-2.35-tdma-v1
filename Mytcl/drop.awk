BEGIN{
	fsDrops=0;
	numfs2=0;
	numfs0=0;
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
	}
	if (len == 3) {
		if (event=="s" && node_==1 && trace_type=="AGT" &&pkt_type=="cbr") 
			numfs2++;
	}
}
END{
	loss_rate=0;
	fsDrops=numfs2-numfs0;
	loss_rate=fsDrops/numfs2;
	printf("%d	%.3f", numfs2, loss_rate);
}
