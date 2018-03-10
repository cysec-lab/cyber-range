# coding: UTF-8

import dns.name

n = dns.name.from_text('www.dnspython.org')
o = dns.name.from_text('dnspython.org')

print n.is_subdomain(o)
print n.is_superdomain(o)
print n > o

rel = n.relativize(o)
n2 = rel + o
print n2 == n
print n.labels

print n

