#本awk仅适用于我的实验：1到30flow，1到100实验
BEGIN{
	count = 0;
}
{
	flow_num = $1;
	data = $2;

	sum[flow_num] = sum[flow_num] + data;
	
	ele[count] = data;

	if (count == 99) {
		count = -1;
		#对ele[0-99]排序
		for (i = 0; i < 100; i++) {
			for (j = 99; j > i; j--) {
				if (ele[j] < ele[j-1]) {
					tmp = ele[j-1];
					ele[j-1] = ele[j];
					ele[j] = tmp;
				}
			}
		}
		for (k = 0; k < 5; k++) {
			sum[flow_num] = sum[flow_num] - ele[k];
		}
		for (k = 95; k < 99; k++) {
			sum[flow_num] = sum[flow_num] - ele[k];
		}
	}
	count++;
}
END{
	for (f = 1; f < 31; f=f+2) {
		printf("%d	%f\n", f, sum[f]/80);
	}
}
