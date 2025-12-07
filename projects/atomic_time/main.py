import sys
import socket
import time
def system_seconds_since_1900():
    """
    The time server returns the number of seconds since 1900, but Unix
    systems return the number of seconds since 1970. This function
    computes the number of seconds since 1900 on the system.
    """
    # Number of seconds between 1900-01-01 and 1970-01-01
    seconds_delta = 2208988800

    seconds_since_unix_epoch = int(time.time())
    seconds_since_1900_epoch = seconds_since_unix_epoch + seconds_delta

    return seconds_since_1900_epoch
host = "time-a-b.nist.gov"
port = 37 #this is the time protocol port

#my_request = f"GET / HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\n\r\n"
#prepared_request = my_request.encode('iso-8859-1')
my_socket = socket.socket()
my_socket.connect((host, port))
#my_socket.sendall(prepared_request)

response = my_socket.recv(4)

num = int.from_bytes(response, "big")

print(f"NIST TIME: {num}")
print(f"SYSTEM TIME: {system_seconds_since_1900()}")
    
print(f"DIFF: {num - system_seconds_since_1900()}")
