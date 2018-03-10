from scapy.all import *

mypacket = IP(dst="192.168.0.6", src="192.168.0.11")/UDP(dport=53, sport=8000)/DNS(rd=1,qd=DNSQR(qname="www.google.com"))
send(mypacket)

