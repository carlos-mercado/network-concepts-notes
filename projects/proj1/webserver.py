import requests
import sys
import socket

if len(sys.argv) == 1:
    sys.exit(1)

port = int(sys.argv[1])


my_socket = socket.socket()

my_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
my_socket.bind(('', port))

my_socket.listen()

response_string = "simple server response".encode('iso-8859-1')
stop_sign_string = "\r\n\r\n".encode('iso-8859-1')


while True:
    #the second value in this tuple has address
    #info on the computer that connnected
    #it's a tuple of (IP Address, PORT)

    (new_socket, _) = my_socket.accept()

    buffer = b""

    while True:
        chunk = new_socket.recv(4096)
        buffer += chunk
        if stop_sign_string in buffer:
            break

    #print(buffer.decode('iso-8859-1'))
    new_socket.sendall(response_string)
    new_socket.close()
