= Project 34 (Answers)


\ *What's the IP address of microsoft.com?*
#align(center, block[
  `13.107.246.69`
])

\ *What's the mail exchange for google.com?*
#align(center, block[
  `smtp.google.com.`
])

\ *What are the name servers for duckduckgo?*
#align(center, block[
  `
  dns1.p05.nsone.net.
  dns2.p05.nsone.net.
  dns3.p05.nsone.net.
  dns4.p05.nsone.net.
  ns01.quack-dns.com.
  ns02.quack-dns.com.
  ns03.quack-dns.com.
  ns04.quack-dns.com.
  `
])

\ *Question four*
#align(center, block[
  `dig @l.root-servers.net www.yahoo.com` \ 
  `dig @d.gtld-servers.net www.yahoo.com` \
  `dig @ns1.yahoo.com www.yahoo.com` \
  `dig @l.root-servers.net me-ycpi-cf-www.g06.yahoodns.net` \
  `dig @d.gtld-servers.net me-ycpi-cf-www.g06.yahoodns.net` \
  `dig @ns5.yahoo.com me-ycpi-cf-www.g06.yahoodns.net` \
  `dig @yf1.a1.b.yahoo.net me-ycpi-cf-www.g06.yahoodns.net` \
  \

])

  `
; <<>> DiG 9.20.15 <<>> @yf1.a1.b.yahoo.net me-ycpi-cf-www.g06.yahoodns.net
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55356
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;me-ycpi-cf-www.g06.yahoodns.net. IN	A
;; ANSWER SECTION:
me-ycpi-cf-www.g06.yahoodns.net. 60 IN	A	69.147.88.8
me-ycpi-cf-www.g06.yahoodns.net. 60 IN	A	69.147.88.7

;; Query time: 45 msec
;; SERVER: 68.142.254.15#53(yf1.a1.b.yahoo.net) (UDP)
;; WHEN: Sun Dec 28 11:20:29 PST 2025
;; MSG SIZE  rcvd: 92
  `
