"""
(ok) 1. You can do this however you like, but I recommend this order. Details for each of these steps is included in the following sections.
(ok) 2. Read in the tcp_addrs_0.txt file.
(ok) 3. Split the line in two, the source and destination addresses.
(ok) 4. Write a function that converts the dots-and-numbers IP addresses into bytestrings.
(ok) 5. Read in the tcp_data_0.dat file.
(ok) 6. Write a function that generates the IP pseudo header bytes from 
   the IP addresses from tcp_addrs_0.txt 
   and the TCP length from the tcp_data_0.dat file.

(ok) 7. Build a new version of the TCP data that has the checksum set to zero.
8. Concatenate the pseudo header and the TCP data with zero checksum.
9. Compute the checksum of that concatenation
10. Extract the checksum from the original data in tcp_data_0.dat.
11. Compare the two checksums. If they’re identical, it works!
12. Modify your code to run it on all 10 of the data files. The first 5 files should have matching checksums! The second five files should not! That is, the second five files are simulating being corrupted in transit.
"""


import sys
import os

file_count =  10;

sources = []
destinations = []
packet_lens = []

def load_addresses():
    for i in range(file_count):
        with open(f"./tcp_data/tcp_addrs_{i}.txt", "r") as file:
            content = file.read()
            (src, dst) = content.split(' ');
            sources.append(src);
            destinations.append(dst[:-1])

def read_packet_length():
    for i in range(file_count):
        with open(f"./tcp_data/tcp_data_{i}.dat", "rb") as file:
            tcp_data = file.read()

            packet_lens.append(len(tcp_data))

def build_zeroed_tcp_data(tcp_data_index):
    with open(f"./tcp_data/tcp_data_{tcp_data_index}.dat", "rb") as file:
        tcp_data = file.read()
        zeroed = tcp_data[:16] + b'\x00\x00' + tcp_data[18:]

        return zeroed

def extract_original_checksum(tcp_data_index):
    with open(f"./tcp_data/tcp_data_{tcp_data_index}.dat", "rb") as file:
        tcp_data = file.read()
        tcp_data = tcp_data[16:18]
        new = int.from_bytes(tcp_data, 'big')
        return new

def build_ip_pseudo_header(i):
    header = b""
    header += ip_to_bytes(sources[i]);
    header += ip_to_bytes(destinations[i]);
    header += b"\x00"
    header += b"\x06"
    header += packet_lens[i].to_bytes(2, 'big')

    return header

def ip_to_bytes(user_ip):
    #"198.51.100.77";
    nums = user_ip.split('.')

    byte_strings = [] 
    for num in nums:
        actual_byte = (int(num)).to_bytes(1, byteorder='big')
        byte_strings.append(actual_byte);

    ret = b''
    for byte in byte_strings:
        ret += byte

    return ret

def checksum(pseudo_ip_head, tcp_data):
    if len(tcp_data) % 2 == 1:
        tcp_data += b'\x00'
    data = pseudo_ip_head + tcp_data
    total = 0

    offset = 0;

    while offset < len(data):
        word = int.from_bytes(data[offset:offset + 2], "big")
        total += word
        total = (total & 0xffff) + (total >> 16)
        offset += 2

    return (~total) & 0xffff


load_addresses()
read_packet_length()

for i in range(file_count):
    pseudo_ip_head = build_ip_pseudo_header(i);
    zeroed_tcp = build_zeroed_tcp_data(i);

    actual_checksum = checksum(pseudo_ip_head, zeroed_tcp)
    expected_checksum = extract_original_checksum(i)

    if actual_checksum == expected_checksum:
        print("PASS")
    else:
        print("FAIL")
