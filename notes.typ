= Beej's Guide to Network Programming Notes

== Chapter 3

=== Notes

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

=== Questions

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

=== Definitions

/ Socket: Endpoint for communication. Combines an IP Address and a port number (e.g., `192.168.1.53:8080`).
/ Port: Where data flows out of or into. A point of egress or ingress. Also uniquely identifies processes or programs on a network.
/ Host: Another name for a computer.

#pagebreak()
#line(length: 100%)
== Chapter 4: The Layered Network Model

=== Notes

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

=== Questions


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

=== Definitions

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

=== Notes

Think of this protocol like the postal office. It takes packages with addresses and sends
the packages there. Instead of physical home addresses the IP protocol uses IP addresses
as its home addresses.

There are two versions of IP:
+ IPv4: 4-byte (192.168.1.53)
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

=== Questions

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

=== Definitions
/ Host: A computer. To be specific, an instance of a computer.

/ Static IP Addresses: Never change. You might use this for a website or a server that users need to constantly access. You don't want that address changing ever couple days.

/ Dynamic IP Addresses: Can change

#pagebreak()

#line(length: 100%)
== Chapter 7: The Internet Protocol version 4

=== Notes
=== Questions
=== Definitions
