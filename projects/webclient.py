import requests
import sys
import socket

if len(sys.argv) == 1:
    sys.exit(1)

host = sys.argv[1]
port = 80
if len(sys.argv) > 2:
    port = int(sys.argv[2])


#SEND THE SERVER OUR INFO
data = f"GET / HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\n\r\n"
ready = data.encode('iso-8859-1')
my_socket = socket.socket()
my_socket.connect((host, port))
my_socket.sendall(ready)

#DO SOMETHING WITH THE RESPONSE
byte_responses = "".encode('iso-8859-1')
response = my_socket.recv(4096)
byte_responses += response
while len(response) != 0:
    response = my_socket.recv(4096)
    byte_responses += response;

print(byte_responses.decode('iso-8859-1'))
my_socket.close()

"""
Data is send in encoded bytes here in python
encode on message send, and
decode on message recieve.

\r\n

Add that delimiter after every line in the header
and at the end of the header do i double
like so:

\r\n\r\n

"""
