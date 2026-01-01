"""
TODO
"""

import sys
import socket
import threading
import json
from chatui import init_windows, read_command, print_message, end_windows

THREAD_COUNT = 2
threads = []

def usage():
    print("usage: client.py nickname host port", file=sys.stderr)

def main(argv):
    try:
        nickname = argv[1]
        host = argv[2]
        port = int(argv[3])

    except:
        usage()
        return 1

    init_windows()

    s = socket.socket()
    s.connect((host, port))

    hello_payload = {"type" : "hello", "nick" : nickname}
    s.send(json.dumps(hello_payload).encode())

    readThread = threading.Thread(target=listen_for_server, args=(s,))
    sendThread = threading.Thread(target=send_message, args=(s,))

    readThread.start()
    sendThread.start()

    readThread.join()
    sendThread.join()

    end_windows()
    s.close()

cond = True
def send_message(sock):
    global cond

    while cond:

        message = read_command("Say something> ")

        if message == "/quit" or message == "/q":
            cond = False
            sock.shutdown(socket.SHUT_RDWR)
            return

        if message != "":
            chat_payload = {"type" : "chat", "message" : message}
            sock.send(json.dumps(chat_payload).encode())

def listen_for_server(sock):
    global cond

    while cond:

        data = sock.recv(2)
        if data != b'':
            packet_len = int.from_bytes(data, byteorder="big")
            data = sock.recv(packet_len)
            message = data.decode()
            message = json.loads(message);

            if message["type"] == "join":
                print_message(f"***{message["nick"]} has joined the chat")

            elif message["type"] == "leave":
                print_message(f"***{message["nick"]} has left the chat")

            elif message["type"] == "chat":
                print_message(f"{message["nick"]}: {message["message"]}")


if __name__ == "__main__":
    sys.exit(main(sys.argv))
