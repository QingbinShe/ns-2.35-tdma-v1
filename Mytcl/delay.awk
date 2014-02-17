BEGIN{
	sendnum = 0;
	recvnum = 0;
}
{
	event = $1;
	time = $2;
	uid = $6;
	pkt_type = $7;
	
	if (event=="s" && pkt_type=="cbr") {
		starttime[uid] = time;
		sendnum++;
	}
	if (event=="r" && pkt_type=="cbr") {
		endtime[uid] = time;
		recvnum++;
	}
}
END{
	for (i = 0; i < sendnum; i++) {
		if (endtime[i] != 0) {
			delay = delay + (endtime[i] - starttime[i]);
		}
	}
	if (recvnum == 0) printf("%f\n", 10); #所有的包都丢失了，设为0，因为传输时延只计算包传的时候的时间
	else printf("%f\n", delay/recvnum);
}
