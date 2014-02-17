BEGIN{
	nums=0;
	numd=0;
}
{
	event = $1;
	pkt_type = $7;
	if (event=="s" && pkt_type=="cbr") 
		nums++;
	if (event=="D" && pkt_type=="cbr")
		numd++;
}
END{
	loss_rate=0;
	loss_rate=numd/nums;
	printf("%.3f\n", loss_rate);
}
