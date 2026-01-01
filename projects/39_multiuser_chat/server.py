"""
TODO
"""


import sys
import socket
import select
import json

def run_server(port):
    my_socket = socket.socket()
    my_socket.bind(('localhost', port))
    my_socket.listen()

    socket_set = set()
    socket_set.add(my_socket)

    names = {} #(localhost, 20200) => 'bob'

    while True:
        ready_to_read, _, _ = select.select(socket_set, [], [])

        for sock in ready_to_read:
            if sock == my_socket: #this is a new connection
                new_s, _ = my_socket.accept()
                socket_set.add(new_s)

            else: #this is an existing connection
                data = sock.recv(4096)
                sock_info = sock.getpeername()
                if data == b'':
                    broadcast_join_leave(socket_set, my_socket, "leave", names[sock_info]) 
                    socket_set.remove(sock)
                    sock.close();

                else:
                    handle_message(sock_info, data, names, socket_set, my_socket)

def handle_message(sock_info, data, names, socket_set, listener_socket):
    message = json.loads(data.decode())

    if message["type"] == "hello":
        names[sock_info] = message["nick"]
        server_message = {"type" : "join", "nick" : names[sock_info]}
        server_message = json.dumps(server_message).encode()
        length_prefix = len(server_message).to_bytes(2, byteorder='big')

        total_payload = length_prefix + server_message
        broadcast_message(total_payload, socket_set, listener_socket)

    elif message["type"] == "join":
        broadcast_join_leave(socket_set, listener_socket, "join", names[sock_info])

    elif message["type"] == "leave":
        broadcast_join_leave(socket_set, listener_socket, "leave", names[sock_info])

    elif message["type"] == "chat":
        server_message = {"type" : "chat", "nick": f"{names[sock_info]}", "message" : message["message"]}
        server_message = json.dumps(server_message).encode()
        length_prefix = len(server_message).to_bytes(2, byteorder='big')

        total_payload = length_prefix + server_message
        broadcast_message(total_payload, socket_set, listener_socket)



def broadcast_join_leave(sockets, my_socket, join_leave, person):
    for socket in sockets:
        if socket is my_socket:
            continue
        join_payload = {"type" : join_leave, "nick" : person}
        join_payload = json.dumps(join_payload).encode()
        length_prefix = len(join_payload).to_bytes(2, byteorder='big')

        total_payload = length_prefix + join_payload
        socket.send(total_payload)


def broadcast_message(message, sockets, my_socket):
    for socket in sockets:
        if socket is my_socket:
            continue

        socket.send(message)


def main(argv):
    try:
        port = int(argv[1])
    except:
        usage()
        return 1

    run_server(port)

def usage():
    print("usage: server.py port", file=sys.stderr)

if __name__ == "__main__":
    sys.exit(main(sys.argv))

