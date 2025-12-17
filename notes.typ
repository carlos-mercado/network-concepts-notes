= Beej's Guide to Network Programming Notes

== Chapter 3

=== _Notes_

*How to connect to another computer:*
+ Ask the operating system for a socket.
+ Perform a DNS lookup.
  - Convert some URL (e.g., `example.com`) $->$ (`198.51.2.451`).
+ Connect to the socket.
+ Send and receive data.
+ Close the connection.

*How to listen for connections from a computer (Server):*
+ Ask the OS for a socket.
+ Bind the socket to a port.
  - This is where the port number is assigned to the server.
  - This is where other clients can connect to.
+ Listen for connections.
+ Accept connections.
+ Send and receive data.
+ Go back to step 3 and repeat.

=== _Questions_

- *What role does `bind()` play server side?* \
  It binds a socket to a port.

- *Would a client ever call `bind()`?* \
  Rarely. The client does not need to call `bind()` since the OS creates a temporary port when the client connects to a server.

- *Speculate on why `accept()` returns a new socket as opposed to just reusing one we called `listen()` with.* \
  Maybe if the server was just limited to the one endpoint, multiple responses at once would not be possible?

- *What would happen if the server didn't loop to another `accept()` call? What would happen when a second client tried to connect?* \
  The client would not be able to connect; the server would just stack incoming connections until the queue filled up.

- *If one computer is using TCP port 3490, can another computer use port 3490?* \
  Yes. Ports are computer specific. Using a specific port on one computer does not disable that port on all other computers.

- *Speculate on why ports exist. What functionality do they make possible that plain IP addresses do not?* \
  A port is like a specific apartment number; the IP is just the address of the apartment building. Without the port number (apartment number), how could the package be sent to the right recipient?

=== _Definitions_

/ Socket: Endpoint for communication. Combines an IP Address and a port number (e.g., `198.51.100.0:8080`).
/ Port: Where data flows out of or into. A point of egress or ingress. Also uniquely identifies processes or programs on a network.
/ Host: Another name for a computer.

#pagebreak()
#line(length: 100%)
== Chapter 4: The Layered Network Model

=== _Notes_

*Example HTTP request:*

When sending a request the HTTP browser builds something like this:
```
http GET / HTTP/1.1
Host: example.com
Connection: close
```
This is all the browser does. It just says "Send this data to that computer on port 80".

Then the OS takes over:

    The browser wants to send this over a stream-oriented socket so the OS decides to use the TCP protocol.
    TCP(HTTP(data))

    The browser wants to send the data to a remote computer with the specified IP address. It uses the IP protocol to do this.
    IP(TCP(HTTP(data)))

    Then the OS uses its routing table to find where to send the data next. Let's say that the destination is somewhere in the LAN. So it uses the Ethernet header.
    Ethernet(IP(TCP(HTTP(data))))

    Finally, the data is put on the wire (if it's WiFi we still say "on the wire").

Stripping layers:
The layers on the destination computer are stripped in reverse order: First Ethernet, then IP, then TCP, then HTTP, until the web server is given the HTTP data.

What if the destination address was an intermediate router?
The router strips off the ethernet frame, looks at the IP address, finds which interface to send the packet from, wraps up the data with another ethernet frame, and sends it to the next router in line.

=== The Internet Layer Model

#table(
columns: (auto, 1fr, 1fr),
inset: 10pt,
align: horizon,
[Layer], [Responsibility], [Example Protocols],
[Application], [Structured application data], [HTTP, FTP, TFTP, TELNET, SSH],
[Transport], [Data Integrity, packet splitting and reassembly], [TCP, UDP],
[Internet], [Routing], [IP, IPv6, ICMP],
[Link], [Physical, Signals on wires], [Ethernet, PPP, Token Ring]
)

=== The ISO OSI Network Layer Model

#link("https://media.geeksforgeeks.org/wp-content/uploads/20250825185948477480/OSI-Model.webp")[Click here to view the OSI Model Diagram]

=== _Questions_


- *When a router sees an IP address, how does it know where to forward it?* \
  The router uses its routing table alongside the given IP address.

- *If an IPv4 address is 4-bytes, roughly how many different computers can that represent in total?* \
  256∗256∗256∗256256∗256∗256∗256

- *Same question but for IPv6?* \
  21282128 possible unique addresses.

- * Speculate on why the IP header wraps up the TCP header in the layered model and not the other way around.* \
  Before the mailman can find a route and mail to your destination, there must be some mail that must be delivered first. i.e., The data must be packaged by the TCP protocol before it can be routed with the IP protocol.

- *If UDP is unreliable and TCP is reliable, speculate on why one might ever use UDP.* \
  If speed is a priority UDP might be the better choice. This is why the UDP protocol is used with many multiplayer games.

=== _Definitions_

/ TCP: Transmission Control Protocol. Reliable in-order data transmission. Uses port numbers to identify senders and receivers of data.
/ UDP: Somewhat of a sibling of TCP. Lighter weight, but cannot guarantee data will arrive, be in-order, or that it won't be duplicated. If it arrives it will be error-free.
/ IPv4: 4-byte identifying number.
/ IPv6: 16-byte identifying number.
/ NAT: Network Address Translation. Gives organizations private subnets with addresses that are not globally unique which can get translated to globally-unique addresses as they pass through the router.
/ Router: A computer that forwards packets through the packet switching network. It inspects addresses to determine which route will get the packet closer to its goal.
/ IP: Internet Protocol. Takes care of identifying computers by using IP addresses and routes data to recipients using those addresses.
/ LAN: Local Area Network. A network of computers connected directly (not by a router).
/ Interface: Networking hardware on a computer. Normal computers might have two: Ethernet and wireless Ethernet interface.
/ Header: Information that prepends data in the body of a message sent via some sort of protocol.
/ Network Adapter: Network card on a computer.
/ MAC Address: Ethernet interfaces have MAC addresses which take the form aa:bb:cc:dd:ee:ff. Any value can be a one-byte hex character. They are 6-bytes long and must be unique on the LAN. When a network adapter is created it is given a MAC Address that it will keep forever.


#pagebreak()

#line(length: 100%)
== Chapter 6: The Internet Protocol (IP)

=== _Notes_

Think of this protocol like the postal office. It takes packages with addresses and sends
the packages there. Instead of physical home addresses the IP protocol uses IP addresses
as its home addresses.

There are two versions of IP:
+ IPv4: 4-byte (198.51.100.0)
+ IPv6: 16-byte (04d3:df2e:8b81:26f6:0121:98a0:04bf:ecf2)

Structure of an IP address (2-parts):
+ The initial bits, which identify individual networks
+ The trailing bits, which identify computers on a network

Consider this example where we have a 8-bit "address"
```
00010111
```
Let's say that the first 6 bits identify the network number (five), and the last 2 are the host number (three). We can extrapolate that this network supports four *hosts* on the network.
```
00
01
10
11
```
But with IP all *hosts* with all-zero and all-one bits are reserved, so there is really only two hosts that are actually supported.

Static vs. Dynamic IP Addresses

Static Addresses don't change Dynamic addresses do. Static addresses are commonly used for servers and websites. Places where address changes are bad for business. They also cost money.

Dynamic Addresses are common for home networks. When you turn off and turn back on your router you might get assigned an address that is different that it was before. When you connect a device to WiFi that device is given a dynamic IP via DHCP.

=== _Questions_

- *How many times more IPv6 addresses are than IPv4 addresses* \
#align(center, block[
  IPv6 = $2^128$\
  IPv4 = $2^32$\
  IPv6 has $2^96$ times more addresses
])
- *Applications commonly also implement their own encryption. Speculate on the advantages or disadvantages for having IPSec at the internet layer instead of doing encryption at the application layer* \
#align(center, block[
  ADVANTAGES:
  Applications do not have to be modified. \
  DISADVANTAGES:
  Greater overhead
])
- *If subnet reserved 5 bits to identify hosts, how many hosts can it support?* \
#align(center, block[
  $2^5$ - 2 = 30 hosts supported.

])

- *What is the benefit to a static IP? How does it relate to DNS?* \
#align(center, block[
  You don't want a server's IP address to change if you are going to constantly SSH into it or if you are hosting a popular website. The DNS would have to change the IP associated with the domain name. If the DNS is not updated immediately after an IP change happens, there would be outages.
])

=== _Definitions_
/ Host: A computer. To be specific, an instance of a computer.

/ Static IP Addresses: Never change. You might use this for a website or a server that users need to constantly access. You don't want that address changing ever couple days.

/ Dynamic IP Addresses: Can change

#pagebreak()

#line(length: 100%)
== Chapter 7: The Internet Protocol version 4
=== _Notes_
Example IPv4 address: `198.51.100.125`

Always four numbers divided by three dots. 
Each number will range from 0-255, since IPv4 is 4-bytes. \
#align(center, block[
1-byte = $2^8$ = 256
])

IP addresses are split up into subnets. The first part of that IP is the subnet number and the second is the computer on that subnet.

There is not a set amount of bits of an IP address that denote a subnet number. It's variable.

When you set up a network that has a public facing IP address, you are allocated a subnet by the provider. The more hosts the subnet supports, the more expensive.

Let's say you need 180, IP static, IP addresses. That means that in total you will need 182 (the 2 come from the reserved addresses that you need (all zero and all one addresses)).

How much bits are needed to represent the number 182? 8-bits since $2^8$ = 256. Not anything less since $2^7$ = 128.

So we say: \

`Your subet is 198.51.100.0 and there are 24 network bits and 8 host bits.`

Put more succinctly:

`198.51.100.0/24`



=== _Questions_

- *`192.168.262.12` is not a valid IP address. Why?* \
#align(center, block[
  262 > 0-255. This is not within the IPv4 standard.
])

- *Reflect on some advantages of the subnet concept as a way of dividing the global address space* \
#align(center, block[
  Better organization by allowing large networks to be broken up into more manageable segments.
])

- *What is your computer's IPv4 address and subnet mask right now?* \
#align(center, block[
`198.51.100.0/24`
])

- *If an IP address is listed as 10.37.129.212/17, how many bits are used to represent the hosts?* \
#align(center, block[
  32-17 = 15 hosts bits
])

=== _Definitions_

#pagebreak()
#line(length: 100%)
== Chapter 8: The Internet Protocol version 6
=== _Notes_
IPv4 (4-bytes) vs IPv6 (16 bytes) \
\
IPv6 is composed of 8 sets of 4 hex digits (each hex digit is 4bits) so one section of hex digits is 16 bits \
#align(center, block[
  `2001:0db8:6ffa:8939:163b:4cab:98bf:070a`
])

Simplifying IPv6 addresses:

#align(center, block[
  example : `2001:0db8:6ffa:0000:0000:00ab:98bf:070a`
])

First, remove all leading zeroes \n

#align(center, block[
  example : `2001:db8:6ffa:0:0:ab:98bf:70a`
])

Then remove all contiguous sets of zeros, and the colon(s) that connect them.

#align(center, block[
  example : `2001:db8:6ffa::ab:98bf:70a`
])

::1 = localhost
fe80::/10 = link local address
2001:db8::/32 = for documentation


=== _Questions_
- *What are some benefits of IPv6 over IPv4* \
#align(center, block[
  WAY more addresses
])

- *How can the address `2001:0db8:004a:0000:0000:00ab:ab4d:000a` be written more simply?* \
#align(center, block[
2001:db8:004a:0:0:ab:ab4d:a

then,

2001:db8:004a::ab:ab4d:a
])


=== _Definitions_

#pagebreak()
#line(length: 100%)
== Chapter 10: Endianness and Integers

=== _Notes_
How would you send integer data to another computer with the knowledge you have learned so far? I would probably turn the data into a string and send it over using the same process I have learned so far.

Little Endian: Least significant bits come at the front. \
#align(center, block[
e.g. `0x45f2` would be represented as `0xf245`.
])
Big Endian: Most significant bits come at the front *the normal way*. Sometimes called *network byte order*\

All network models are transmitted as big-endian

Converting a base 10 number to a bytestring using python

n = 3490

bytes = n.to_bytes(2, "big")

for byte in bytes:\
print(byte)

COUT:\
13 \
162 \

13 x 256 + 162 = 3490

=== _Questions_

- *Using only the .to_bytes() and .from_bytes() methods, how can you swap the byte order in a 2-byte number? (That is reverse the bytes.) How can you do that without using any loops or other methods? (Hint: "big" and "little"!)* \
#align(center, block[
  n = 0xabcd\
  reg_bytes = n.to_bytes(2, "big") \
  flipped = int.from_bytes(reg_bytes, "little")\
  print(flipped.to_bytes(2, "big")\
])

- *Little-endian vs big-endian* \
#align(center, block[
  Little-endian least significant bits first
  Big-endian most significant bits first
])

- *What is network byte order? * \
#align(center, block[
  Another name for big-endian
])

- *Why not just send an entire number at once instead of breaking it up into bytes?* \
#align(center, block[
  A lot of computer storage is byte-based and memory stuff usually happens bytes at a time. It's kind of the standard unit
])


- *Little-endian seems backwards. Why does it even exist? Do a little internet searching* \
#align(center, block[
  It's for making certain operations easier. For example, doing a carry operation from adding two numbers is way easier in little endian.
])

#pagebreak()
#line(length: 100%)
== Chapter 11: Parsing Packets
=== _Notes_
We've been calling recv() with some number to get that amount of bytes back. The thing is we don't really know how long the message is so rec(4096) might only get 10 bytes back as a message. And rec(10) might be missing 4086 bytes. A little wasteful no?

With a little abstraction this is possible:

`
global buffer = b''    # Empty bytestring

function get_packet():
    while True:
        if buffer starts with a complete packet
            extract the packet data
            strip the packet data off the front of the buffer
            return the packet data

        receive more data

        if amount of data received is zero bytes
            return connection closed indicator

        append received data onto the buffer
`
=== _Questions_
- *Describe the advantages from a Programming perspective to abstracting packets out of a string of data?*
#align(center, block[
Less verbose, more intuitive when reading the code?  
])


#pagebreak()
#line(length: 100%)
== Chapter 14: Transmission Control Protocol
=== _Notes_

Kinda the doomer protocol, assumes the worst all the time.

The Goals of TCP:
- Reliable Communication
- Simulate a circuit-like connection on a packet-switched network
- Provide flow control
- Provide congestion control.
- Support out-of-band data.

TCP happens at the transport layer.

TCP does three main things:
- Make the connection
- Transmit data
- Close the connection

The three way handshake: Occurs at the start of each TCP connection.

`
1. `*`SYN`*`: the client send a SYN (synchronize) packet to the server.
2. `*`SYN-ACK`*`: The server responds with a SYN-ACK (synchronize acknowledge) packet back to the client.
3. `*`ACK`*`: The client responds with an ACK (acknowledge) packet back to the server.
`

If the handshake does not complete within a normal amount of time the packet is resent.

*Data Transmission with TCP*

Streams of data are given to TCP. TCP splits up the data in to chunks. TCP then slaps a header on each chunk as well as a number (to they can be put back together later).

These chunks that TCP produces are called TCP segments.

When we send TCP segments we expect an *`ACK`* response. If we don't get an *`ACK`* response obviously something might have gone wrong, send again.

If a either side of a connection wants to close the connection, they send a *`FIN`* packet.

#align(center, block[
  `SENDER`
#text("        ")
  `RECIVER` \

  *`can you hear me?`* $arrow.r$ *`*receiver receives*`* \ syn
  \
  *`*sender receives*`* $arrow.l$ *`I can hear you, what's up?`* \ syn-ack
  \
  *`You can hear me? Perfect.`* $arrow.r$ *`*receiver receives*`* \ ack

])

*Segment Misorderings/Defects*

If segment come misordered they can be reordered because they are labeled with numbers so they can be put back together later should this exact situation come up.

If segments come through the system can find that out using the numbers also. Just find out what numbers you've seen before.

If segments are missing TCP asks for re-transmission, which is achieved by *`ACK`* ing the previous segment. 

What if a segment is corrupted?  \
Before a segment is sent a checksum is computed for that specific segment, when this segment arrives to the reciever. The reciever also computes the checksum for the segment that is recieved. If the checksums do not match the sender must timeout and retransmit the segment.


*Flow Control* \
As part of the receiver's ACK packet, the receiver can put some data called a sliding window in the header to tell the sender how much more data(bytes) that they are willing to receive. Giving the receiver the power to only receive as much as they can handle. 

*Congestion Control* \
Look up slow start algo

=== _Questions_

- *Name a few protocols that rely on TCP for data integrity* \
#align(center, block[
  HTTP, FTP, IMAP, TELNET, SSH
])

- *Why is there a three-way handshake to set up a connection? Why not just start transmitting* \
#align(center, block[
  Setting up the handshake makes the communication between two computers more reliable. It's like making sure that the friend that you are talking to on the other line is on other side of the call is ready to receive information
])


- *How does a checksum protect against data corruption?* \
#align(center, block[
  If the checksum of the received segment does not match the checksum of the sent segment something went wrong. 
])

- *What's the main difference between flow control and congestion control?* \
#align(center, block[
Flow control manages the rate of data transmission between COMPUTERS to prevent overwhelming the receiver. Congestion control manages overall NETWORK traffic to prevent the NETWORK from becoming overloaded.
])

- *What is the purpose of flow control* \
#align(center, block[
managing transmission between computers (senders and receivers) to make sure that the receiver is not overwhelmed by to much segments.
])




#pagebreak()
#line(length: 100%)
== Chapter 15: User Datagram Protocol (UDP)
=== _Notes_

Simple in comparison to TCP, which is very important for lightweight transfer of data over the internet.

The protocol launches packets, hopes they arrive.

The Protocol does *NOT* guarantee:
- That the data will come in order
- That packets will not be lost.
- That the packets might not be duplicated

If these things are important to you use TCP.

These is ONE guarantee that the protocol has:


#align(center, block[
  `IF the data does arrive, it WILL be correct.`
])

The lack of guarantees  = low overhead. less stuff to do. stuff takes time.

TCP and UDP can use the same port. This makes sense. A port is like an extension to an IP addresse that further specifies where data should go. How an apartment complex has a address, but there is also apartment numbers which are more specific numbers to use when finding out where a package should go. 

UDP does not establish a connection before sending data. This why UDP described as connectionless.

TCP delivers a package by hand, asks for your signature, and takes a picture on the way out.

UDP throws your package out of the window while driving by, but it puts the package in a lot of bubble wrap so that nothing can break inside.

For error detection TCP also uses checksums.


=== _Questions_

- *What does TCP provide that UDP does not in terms of delivery guarantees.* \
#align(center, block[ Flow control, congestion control, reliable communication. ])

- *Why do people recommend keeping UDP packets small?* \
#align(center, block[
  So that they aren't split up by protocols down the line
])

- *Why is the UDP header so much smaller than the TCP header?* \
#align(center, block[
  UDP doesn't have to label the index of the packet on each header, it also doesn't try to control flow to the reciever, as well as not having to consider congestion control.
])


- *`sendto()` requires you specify a destination IP and port. Why does the TCP-oriented send() function not require those arguments.* \
#align(center, block[
 Because with TCP, you establish a connection (specifying IP and port) before sending data, so `send()` already knows the destination. UDP does not establish a connection, so `sendto()` needs the destination each time.
])


- *Why would people use UDP over TCP if it's relatively unreliable? * \
#align(center, block[
  If your use-case does not mind if a couple packets are dropped here and then.
])


#pagebreak()
#line(length: 100%)
== Chapter 17: IP Subnets and Subnet Masks
=== _Notes_

IP string to IP number : \
#align(center, block[
`"192.51.100.10"` \
])

*Step One:* \
Split the string on '.'

#align(center, block[
`["198", "51", "100", "10"]` \
])

*Step Two:* \
Convert Strings to Integers

#align(center, block[
`[198, 51, 100, 10]` \
])

*Step Three:* \
Use this neat little bitwise shift and bitwise or operator trick

#align(center, block[
`(198 << 24) | (51 << 16) | (100 << 8) | (10 << 0)` \
  Decimal : *3325256714* \
  Hex: *0xc633640a*
])

Do you see how this rebuilds the 32bit IPv4 number? \
194 will occupy the first 8 bits, \
51 the next 8, \
100 the next 8, \
and 10 the final 8. \

IP NUMBER to String: \
#align(center, block[
`"0xabcd1234"` \
])

#align(center, block[
`
>>> hex(0xabcd1234 >> 0)
0xabcd12 `*34*`
>>> hex(0xabcd1234 >> 8)
'0x00abcd `*12*`'
>>> hex(0xabcd1234 >> 16)
'0x0000ab `*cd*`'
>>> hex(0xabcd1234 >> 24)
'0x000000 `*ab*`'
>>> #see how I got was able to get all 4 bytes there ?
`
])

The problem is obviously those leading bytes. We don't need those so how should we deal with them?

Notice:

#align(center, block[
` 0x00ABCD12 AND 0x000000ff = 0x00000012`
])

#pagebreak()

This is called an *AND mask*. Using this tool  extracting is as easy as:

#align(center, block[
`
>>> hex(0xabcd1234 >> 0 & 0x000000ff)
'0x34'
>>> hex(0xabcd1234 >> 8 & 0x000000ff)
'0x12'
>>> hex(0xabcd1234 >> 16 & 0x000000ff)
'0xcd'
>>> hex(0xabcd1234 >> 24 & 0x000000ff)
'0xab'
`
])

How to get the Subnet of an IP address:

Given an ip address with slash nonation like 

#align(center, block[
  `198.51.100.10/24` 
])
How can we extract the just the subnet bits:

#align(center, block[ `198.51.100.0` ])

Since we know the subnet spans 24 bits from the slash notation. The subnet mask will be

#align(center, block[ `255.255.255.0`\ or\ `11111111.11111111.11111111.00000000`])

Note that there is no rule that a subnet must only span a length of bits divisible by eight. For example, consider 

#align(center, block[
  `198.51.100.10/28` 
])

The subnet mask would look like this

#align(center, block[ `11111111.11111111.11111111.11110000`])

Use this subnet mask and AND them with the IP address to get the network number.


#pagebreak()
=== _Questions_
- *What is the 32bit (4 byte) representation of 10.100.30.90 in hex? in decimal? in binary?* \

#align(center, block[ 
  `
  decimal = 174333530
  binary = 0b1010011001000001111001011010
  hex = 0xa641e5a
  `
])

- *What is the dots-and-numbers IP address represented by the 32-bit numbers 0xc0a88225* \
#align(center, block[ 
  `
>>> h = 0xc0a88225
>>> and_mask = 0x000000ff
>>> h >> 0 & and_mask
37
>>> h >> 8 & and_mask
130
>>> h >> 16 & and_mask
168
>>> h >> 24 & and_mask
192

  `*`192.168.130.37`*`
  `
])


- *What is the dots-and-numbers IP address represented by the 32-bit decimal number 180229186* \

#align(center, block[ 
  `
>>> h = 180229186
>>> h >> 0 & and_mask
66
>>> h >> 8 & and_mask
20
>>> h >> 16 & and_mask
190
>>> h >> 24 & and_mask
10
  `*`10.190.20.66`*`
  `
])

- *What bitwise operation do you need to extract the second byte from the left of the number 0x12ff5678?* \

#align(center, block[ 
  `
>>> hex(h >> 16 & and_mask)
'0xff'
  `
])

- *What is the slash notation for the subnet mask 255.255.0.0* \

#align(center, block[ 
  255.255.0.0/16
])

- *What is the subnet mask for the network 192.168.1.12/24* \
#align(center, block[ 
  `0xffffff00`
])

- *What are the numeric operations necessary to convert a slash subnet mask to a binary value?*\
#align(center, block[ 
  `
  BITWISE NOT
  BITWISE SHIFT LEFT
  `
])

- *Given an IP address value and a subnet mask value, what bitwise operation do you need to perform to get the subnet number from the IP address *\
#align(center, block[ 
  `BITWISE AND`
]);

#pagebreak()
#line(length: 100%)
== Chapter 18: IP Routing
=== _Notes_

_The internet_. Clumps of loosely connected networks.

Goal for Routing Protocols: give routers enough information to make routing decisions.

*Interior Gateway Protocols*: Routing protocol that is optimized for smaller networks with a small amount of subnets.

#align(center, block[
= Interior Gateway Protocols
])

#table(
  columns: (auto, auto, 1fr),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Abbreviation*], [*Name*], [*Notes*],
  ),
  [OSPF], [Open Shortest Path First], [Most commonly used, IP layer],
  [IS-IS], [Intermediate System to Intermediate System], [Link layer],
  [EIGRP], [Enhanced Interior Gateway Routing Protocol], [Cisco semi-proprietary],
  [RIP], [Routing Information Protocol], [Old, rarely used],
)

It's not really feasible to give all routers a map of the internet. It's way to big, and it's always changing. So what is the approach we should take?

*Exterior Gateway Protocols*: Routing protocol that is used to make routing decisions for the wider internet.

Each autonomous system on the internet is assigned an autonomous system number (ASN) that is used by the border Gateway protocol to help determine where to route packets.

#align(center, block[
= Exterior Gateway Protocols
])

#table(
  columns: (auto, auto, 1fr),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Abbreviation*], [*Name*], [*Notes*],
  ),
  [BGP], [Border Gateway Protocol], [Used everywhere],
  [EGP], [Exterior Gateway Protocol], [Obsolete],
)

Note that BGP has two modes. _Internal_ BGP and _External_ BGP. \
In _Internal_ mode it acts as an interior gateway protocol. \
In _External_ mode it acts as an exterior gateway protocol.


*Routing Tables* \
Table that stores information on where to store packets.

*Infinite Loops When Routing* \
In the IP header there is a counter (1-byte) that starts at 255 and counts down every time a router forwards a packet. When the counter gets to zero, the packet is discarded, and a "Time Exceeded" message is returned to the sender.

The most times a packet can be _routed_ is 255 times.

=== _Questions_

- *What is the difference between an interior gateway protocol and an external gateway protocol?* \
#align(center, block[
IGP is used for routing within a sincular autonomous system. EGP used for routing packets throughout the wider multi-autonomous-system internet.
])

- *What is the goal of a routing protocol in general* \
#align(center, block[
  The goal is to give routers information, and enough of it, to make routing decisions.
])

- *What's an example of a place where an interior gateway protocol would be used? And exterior?* \
#align(center, block[
  IGP: Asking for a resource on a LAN.\
  EGP: Sending a packet to a computer that is outside of your current autonomous system 
])

- *What does a router use its routing table to determine* \
#align(center, block[
  where to route packets next
])

- *What does an IP router do next with a packet if the destination IP address is not on one of it's local subnets. * \
#align(center, block[
  The router checks the routing table for the destination subnet. 
])

- *Why would a process send anything to the broadcast address?* \
#align(center, block[
  After first connecting a device to a network that device can send a DHCP packet to the broadcast address to get it's IP, subnet mask, default gateway
])

#pagebreak()
#line(length: 100%)
== Chapter 20: The Link Layer and Ethernet
=== _Notes_
\
The Link Layer is where bytes turn to electricity.

_A Note on Octets_ \ 
Bytes didn't always mean 8 bits. So some implementations can be a little weird. So to be absolutely sure that you are communicating 8-bytes. We can say _octet_. 
 \ \
_Frames vs Packets_ \
Data sent out over the Ethernet: packets.

Within packets there are things called *_frames_*.\

Frames are like sub-packets. But sometimes frames and packets are used interchangeably.

 \ \
_MAC Addresses_ \
Any device that can connect to a network has a MAC Address cooked on to the device from the factory.
\ \

#align(center, block[
  Example ethernet MAC Addresses: \
  *`ac:d1:b8:df:20:85`* \
  *`ac-d1-b8-df-20-85`* \
  *`acd1.b8df.2085`* \
])\

Note that you can get unlucky and get network cards that have the same MAC address. In that case, you would want to change the address of one device. 

The first three bytes are called the OUI (Organizationally unique Identifier). This is a number that is assigned to the manufacturer. Kind of like a 3-byte combo that represents the company.

This means that the company another 3 bytes to work with (16,777,216 combos).

 \ \
_Multiple Access Method_ \

Problem: Let's say that there is a set of computers that share a WIRED Ethernet connection. How can each computer communicate on that wire without stepping on another computer's toes?

Wired Ethernet's Solution (CSMA/CD or Carrier-Sense Multiple Access with Collision Detection) \
`
Step 1: Wait for quiet in the room (no network card is transmitting)
Step 2: It starts sending.
Step 3: It also starts listening.
Step 4: If it receives the same thing that is sent. OK, all good. If it doesn't that means that another card tried to transmitt at the same time.
Step 5: The network card transmitts a "jam signal". This tell the other network card to stop transmitting because a collision has occurred. The card then waits a small, partly random amounts of time and then goes back to step 1 to try transmission again.
`
\ \ Wireless Ethernet's (WiFi) Solution (CSMA/CA or Carrier-Sense Multiple Access with Collision Avoidance) \
`
Step 1: Ethernet card waits for quiet in the room, when there is nobody transmitting.
Step 2: If the channel is not quiet, the card waits a small, random amount of time and then goes back to step 1 to retry.
`
 \ \
_Ethernet_

To reiterate, the data that is transmitted is an Ethernet packet, but within that exists an Ethernet frame. \ 
Here is the structure of an Ethernet packet: \
`
The packet:
- 7 octets: Preamble (in hex: AA AA AA AA AA AA AA)
- 1 octet: Start frame delimiter (in hex: AB)
- The Frame:
    - 6 Octets: Destination mac address
    - 6 Octets: Source MAC address
    - 4 Octets: "Dot1q" tag for virtual LAN differentiation.
    - 2 Octets: Payload length/ethertype
    - 46-1500 Octets: Payload
    - 4 Octets: CRC-32 Checksum
    - 2 Octets: Payload length/ethertype
- End of frame marker, loss of carrier signal
- Interpacket gap, enough time to transmit 12 octets
`

\ The Payload length/ethertype field is normally used for just the payload len, but other values can be inserted to indicate an alternate payload structure.



=== _Questions_

- *What's you MAC address on your computer? Do an internet search to find how to look it up.* \
#align(center, block[
    f0:6e:0b:dd:92:2a
])

- *What's the deal with frames versus packets in Ethernet? Where in the ISO OSI network stack do they live?* \
#align(center, block[
  Frames are a specific part of the Ethernet packet. Ethernet packets lie on the Physical layer of the network stack, and frames lie on the Data link layer.
])


- *What's the difference between a byte and an octet* \
#align(center, block[
  An octet always means eight bits. That is has not always been the case with byte. So to be completely sure you are referring to 8 bits use the word octet
])


- *What's the man difference between CSMA/CD and CSMA/CA?* \
#align(center, block[
  CSMA/CD is used for wired ethernet, and CSMA/CA is used for wireless. CSMA/CA makes sure that there is no other network cards transmitting before transmitting and if there is it waits a bit. Also, CD has a procedure that it follows in case of a collision. CA does not
])


#pagebreak()
#line(length: 100%)
== Chapter 21: ARP - The Address Resolution Protocol

=== _Notes_

Problem: How do we send data over LAN to another computer on the same subnet?

What we *NEED* to build an Ethernet Frame:
- The data that we want to send and it's length.
- Our source MAC Address
- The destination MAC Address

Here's what we *DO* know:
- The data we want to send and it's length.
- The source MAC address.
- The source IP Address
- The destination IP address

Do you see the issue? We don't know the destination MAC Address. 

\ _Recall_ \
Network cards only listen for Ethernet frames addressed specifically to them. So any frames that are not addressed to them are ignored.

But we can override this behavior with the *broadcast frame*. This is a frame that has a destination MAC Address of ff:ff:ff:ff:ff:ff.

ARP makes use of this fact.

\ _The Address Resolution Protocol_ \
We need the receiving computer's MAC Address, how is this done?

Here are the steps:
1. The source computer will broadcast the Ethernet frame that contains the destination IP address. This is the ARP request.

2. All computers on the LAN get the ARP request. All the computers on the LAN will examine it. But only the computer with the IP address specified in the ARP request will continue. The other computers get discard the packet.

3. The destination computer with the specified IP addresse builds an ARP response. This Ethernet frame contains the destination computer's MAC address.

4. The destination computer sends that ARP response back to the source computer.

5. The source computer receives the ARP response, and now it knows the destination computer's MAC address.

\ _ARP Caching_ \
Would it not be annoying going through that entire ARP protocol every time that you needed to send Ethernet frames to another computer?

We can cache the MAC Address for a little bit.

\ _ARP Structure_ \
(Total fixed length of 28 octets)
`
The payload:
- 2 octets: Hardware Type (Ethernet is 0x0001)
- 2 octets: Protocol Type (IPv4 is 0x8000)
- 1 octets: Hardware address length in octets (Ethernet is 0x06)
- 1 octets: Protocol address length in octets (IPv4 is 0x04)
- 2 octets: Operation (0x01 for request, 0x02 for reply)
- 6 octets: Sender hardware address (Sender MAC Address)
- 4 octets: Sender protocol address (Sender IP Address)
- 6 octets: Target hardware address (Target MAC Address)
- 4 octets: Target protocol address (Target IP Address)
`


=== _Questions_

- *Describe the problem that ARP is solving.* \
#align(center, block[
  When I try to send a Ethernet packet to another network card on the same network, a problem comes up. I need to know the MAC address of the receiving network card to send the packet, so how do I get that? That is where ARP comes in and gives us a way of getting the hardware address of the receiving network card that was previously unknown.
])

- *Why do entries in ARP caches has to expire* \
#align(center, block[
  They have to expire because it is possible they can go stale. The info that is stored in the ARP cache is a IP Address => MAC address MAP. So if a computer disconnects from a network and another new computer connect to the same network and is assigned that old computer's IP address the data would be send to the new computer's hardware address. Which is not the behavior that we want.
])

- *Why can't IPv6 use ARP* \
#align(center, block[
  The target and sender addresses only numbers of at most 4-bytes or 4 octets, IPv6 addresses are 16 bytes.
])

/*
These are my questions for this chapter

If you have the destination computer's IP address, why do you have to broadcast the ARP packet to everybody?

*/
