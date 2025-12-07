import sys
import socket
import time


# How many bytes is the word length?
WORD_LEN_SIZE = 2

def usage():
    print("usage: wordclient.py server port", file=sys.stderr)

packet_buffer = b''

def get_next_word_packet(s):
    """
    Return the next word packet from the stream.

    The word packet consists of the encoded word length followed by the
    UTF-8-encoded word.

    Returns None if there are no more words, i.e. the server has hung
    up.
    """

    global packet_buffer

    while True:

        #this is the length of the string,
        #which is always the 2-byte prefix of the buffer.
        str_len = int.from_bytes(packet_buffer[:WORD_LEN_SIZE], "big") 

        #if there exists a word packet in the buffer extract it
        #and update the buffer
        if len(packet_buffer) >= str_len + WORD_LEN_SIZE:
            result = packet_buffer[:str_len + WORD_LEN_SIZE]
            packet_buffer = packet_buffer[str_len + WORD_LEN_SIZE:]
            return result

        newData = s.recv(5)

        if newData == b"":
            return None

        packet_buffer += newData



def extract_word(word_packet):
    """
    Extract a word from a word packet.

    word_packet: a word packet consisting of the encoded word length
    followed by the UTF-8 word.

    Returns the word decoded as a string.
    """
    string_part = word_packet[WORD_LEN_SIZE:]
    ret_string = string_part.decode('iso-8859-1')
    return ret_string

# Do not modify:

def main(argv):
    try:
        host = argv[1]
        port = int(argv[2])
    except:
        usage()
        return 1

    s = socket.socket()
    s.connect((host, port))

    print("Getting words:")

    while True:
        word_packet = get_next_word_packet(s)

        if word_packet is None:
            break

        word = extract_word(word_packet)

        print(f"    {word}")

    s.close()

if __name__ == "__main__":
    sys.exit(main(sys.argv))

"""
THIS IS AN ALTERNATE SOLUTION TO get_next_word_packet()
it's not the way the project was meant to be solved. At least
I don't think so. Basically just takes advantage of the fact
that the basic ASCII chars are 1 byte. The packet_buffer will only ever
hold 1 word packet at the end of the fuction, and hold nothing at
the beginning of each call. Nothing less, nothing more.


packet_buffer = b""

data = s.recv(WORD_LEN_SIZE) # this is the number of chars 
                                # to rip from the stream (in hex)
                                # so this has to be converted to
                                # int using .from_bytes

packet_buffer += data

word_len = int.from_bytes(packet_buffer, "big") #convert the bytes to integer
packet_buffer += s.recv(word_len) #take that much chars from the stream

if data == b"":
    return None
return packet_buffer
"""

