# coding: UTF-8

import dns.name
import dns.message
import dns.query
import dns.flags

domain = 'google.com'
name_server = '8.8.8.8'
#ADDITIONAL_RDCLASS = 65535
ADDITIONAL_RDCLASS = 4096

domain = dns.name.from_text(domain)
if not domain.is_absolute():
    domain = domain.concatenate(dns.name.root)

request = dns.message.make_query(domain, dns.rdatatype.ANY)
request.flags |= dns.flags.AD
request.find_rrset(request.additional, dns.name.root, ADDITIONAL_RDCLASS,
            dns.rdatatype.OPT, create=True, force_unique=True)
response = dns.query.udp(request, name_server)


print response.answer
print response.additional
print response.authority

