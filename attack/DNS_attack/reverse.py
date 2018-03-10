# coding: UTF-8

import dns.zone
import dns.ipv4
import os.path
import sys

reverse_map = {}

for filename in sys.argv[1:]:
    zone = dns.zone.from_file(filename, os.path.basename(filename), relativize=False)
    for (name, ttl, rdata) in zone.iterate_rdatas('A'):
        l = reverse_map.get(rdata.address)
        if l is None:
            l = []
            reverse_map[rdata.address] = l
        l.append(name)

keys = reverse_map.keys()
keys.sort(lambda a1, a2: cmp(dns.ipv4.inet_aton(a1), dns.ipv4.inet_aton(a2)))
for k in keys:
    v = reverse_map[k]
    v.sort()
    l = map(str, v)
    printk, l

