#!usr/bin/env ruby

# refere:http://qiita.com/dhomma/items/7d058856ed46354920d7

require 'socket'

if ARGV.size == 0
  puts "Usage: ./dnsping.rb <DNS Server IP Address>"
  exit 1
end

SERV = ARGV[0]  # DNS Server Address
PORT = 53       # DNS Port
LEN = 512       # maxLen bytes

# Generate DNS Request
# for a server status request, we only need a header data
# headr format is described in RFC 1035
def dns_request()
  id      = 1

  qr      = 0 << 15 # qr = 0      => query (not response)
  opcode  = 2 << 11 # opcode = 2  => serve status request
  aa      = 0 << 10
  tc      = 0 << 9
  rd      = 0 << 8
  ra      = 0 << 7
  z       = 0 << 4
  rcode   = 0 << 0

  qdcount = 0
  ancount = 0
  nscount = 0
  arcount = 0

  f1 = id
  f2 = (qr + opcode + aa + tc + rd + ra + z + rcode)
  f3 = qdcount
  f4 = ancount
  f5 = nscount
  f6 = arcount

  # 'n*' converts 16bit unsigned array to byte array in network byte order
  header = [f1, f2, f3, f4, f5, f6].pack('n*')

  return header
end

def main()
  # create DNS request message
  req = dns_request()

  # desplay DNS request message
  print " Request: "
  p req

  # create socket
  sock = UDPSocket.new
  sock.connect(SERV, PORT)

  # send the query
  sock.send req, 0

  # receive response
  data = sock.recvfrom(LEN)

  #desplay received data
  # data[0] => received data
  print " Response "
  p data[0]

  # display response code
  # lower 4 bytes of the 4th octet in received data is the response code
  print " RCODE:    "
  p (data[0].unpack('C*')[3] & 0b1111)

end

main()
