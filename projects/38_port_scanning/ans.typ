*Run `nmap localhost` what is the output?*

`
Starting Nmap 7.98 ( https://nmap.org ) at 2025-12-31 13:34 -0800
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00033s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 998 closed tcp ports (conn-refused)
PORT    STATE SERVICE
22/tcp  open  ssh
631/tcp open  ipp

Nmap done: 1 IP address (1 host up) scanned in 0.12 seconds
`

\ *Run `nmap -p0-` what is the output?*

`
Starting Nmap 7.98 ( https://nmap.org ) at 2025-12-31 13:46 -0800
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00011s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 65531 closed tcp ports (conn-refused)
PORT      STATE SERVICE
22/tcp    open  ssh
631/tcp   open  ipp
34359/tcp open  unknown
35307/tcp open  unknown
40799/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 2.52 seconds
`

\ *Run a server and port-scan. What is the output?*

`
Starting Nmap 7.98 ( https://nmap.org ) at 2025-12-31 13:48 -0800
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00015s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 65530 closed tcp ports (conn-refused)
PORT      STATE SERVICE
22/tcp    open  ssh
631/tcp   open  ipp
14111/tcp open  unknown *THIS IS MY SERVER PORT*
34359/tcp open  unknown
35307/tcp open  unknown
40799/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 2.49 seconds
`


\ *Does your server crash with a "Connection reset" error? If not speculate on why this might happen*

My server did not crash, but it might if the port-scanner sends a RST instead of an ACK. An ACK would complete the handshake but we don't need to complete the handshake if we already know the port is open.
