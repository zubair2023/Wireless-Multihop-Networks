BEGIN {
sendLine = 0;
recvLine = 0;
fowardLine = 0;
	bytes = 0;		#variable for storing number of bytes transmitted
	st = 0;		#variable for start time
	ft = 0;		#variable for end time
	recv = 0;		#variable for storing number of packets received
}
$0 ~/^s.* AGT/ {
sendLine ++ ;
}
$0 ~/^r.* AGT/ {
recvLine ++ ;
}
$0 ~/^f.* RTR/ {
fowardLine ++ ;
}
{ if ( $1 == "s" && $4 == "AGT" && $7 == "cbr")
	{
		if(send == 0)
		{
			st = $2;	#Starting time of packet transmission will be assigned to st
		}
		
		ft = $2;		#End time of packet transmission will be assigned to ft
		st_time[$6] = $2;	#This array holds sending time for each packet and $6 is unique ID such as 0,1,2,3 and so on.	
		send++;
	}
if ( $1 == "r" && $4 == "AGT" && $7 == "cbr")
	{
		recv++;			
		bytes+=$8;  #$8 is packet size and final bytes value is the total number of bytes tranmitted from source to destination.
	}
}
END {
printf " Packets send: %d\n Packets received: %d\n PDR: %.3f\n Packets forwarded: %d\n Number of dropped packets: %d\n Throughput: %.2f Kbps\n", sendLine, recvLine, (recvLine/sendLine),fowardLine, (sendLine-recvLine), bytes*8/(ft-st)/1000;
#printf("Throughput: \t\t\t%.2f Kbps\n",bytes*8/(ft-st)/1000);
}
