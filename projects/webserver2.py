"""
GOALS:
1. Parse that request header to get the file name. *DONE*
2. Strip the path off for security reasons. *DONE*
3. Read the data from the named file. *DONE*
4. Determine the type of data in the file, HTML or text. *DONE*
5. Build an HTTP response packet with the file data in the payload.
6. Send that HTTP response back to the client.
"""
import sys
import socket
import os

if len(sys.argv) == 1:
    port = 28333
else:
    port = int(sys.argv[1])


my_socket = socket.socket()

my_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
my_socket.bind(('', port))

my_socket.listen()

response_string = "simple server response".encode('iso-8859-1')
stop_sign_string = "\r\n\r\n".encode('iso-8859-1')


while True:
    #the second value in this tuple has address \
    #info on the computer that connnected \
    #it's a tuple of (IP Address, PORT)

    (new_socket, _) = my_socket.accept()

    buffer = b""

    while True:
        chunk = new_socket.recv(4096)
        buffer += chunk
        if stop_sign_string in buffer:
            break


    undecoded_request_string = buffer.split(b"\r\n")
    undecoded_get_line = undecoded_request_string[0]
    undecoded_deconstructed_get_line = undecoded_get_line.split(b" ")
    undecoded_file_path = undecoded_deconstructed_get_line[1]
    undecoded_file_name = undecoded_file_path.split(b"/")[-1]

    file_name = undecoded_file_name.decode('iso-8859-1')
    (f_name, f_type) = os.path.splitext(file_name)

    mapper = {".html" : "text/html", ".txt" : "text/plain", ".pdf" : "application/pdf"}

    data = b""
    byte_count = 0;

    try:
        with open(file_name, "r") as fp:
            data = fp.read()
            byte_count = len(data)
            good_response = f"HTTP/1.1 200 OK\r\nContent-Type:{mapper[f_type]}\r\nContent-Length: {byte_count}\r\nConnection: close\r\n\r\n{data}"
            new_socket.sendall(good_response.encode('iso-8859-1'))
            new_socket.close()
    except:
        print("404 file not found.")
        bad_response = b"HTTP/1.1 404 Not Found \r\nContent-Type: text/plain\r\nContent-Length: 13\r\nConnection: close\r\n\r\n404 Not Found"
        new_socket.sendall(bad_response)
        new_socket.close()
        continue;

