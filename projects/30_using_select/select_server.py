# Example usage:
#
# python select_server.py 3490
# python select_client.py alice localhost 3490

import sys
import socket
import select

def run_server(port):
    my_socket = socket.socket();
    my_socket.bind(('localhost', port))
    my_socket.listen()

    socket_set = set()
    socket_set.add(my_socket)

    while True:
        ready_to_read, _, _ = select.select(socket_set, [], [])

        for sock in ready_to_read:
            if sock == my_socket:
                new_s, connection_info = my_socket.accept()
                socket_set.add(new_s)
                print(str(connection_info) + ": connected");
            else:
                data = sock.recv(4096)
                sock_info = sock.getpeername()
                if data == b'':
                    print(f"{sock_info}: disconnected");
                    socket_set.remove(sock)
                    sock.close();
                else:
                    print(f"{sock_info} {len(data)} bytes: {data}")



#--------------------------------#
# Do not modify below this line! #
#--------------------------------#

def usage():
    print("usage: select_server.py port", file=sys.stderr)


def main(argv):
    try:
        port = int(argv[1])
    except:
        usage()
        return 1

    run_server(port)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
