#when the program is up and running use
#the shell redirection operator `>` to output to another file
#then if everything is good 2 go just `diff your_out.txt example1_output.txt`
#to see if there is any differences between the files

import sys
import json

def ipv4_to_value(ipv4_addr):
    """
    Convert a dots-and-numbers IP address to a single 32-bit numeric
    value of integer type. Returns an integer type.
    """

    if(type(ipv4_addr) != str):
       return ipv4_addr
    split_ip_string = ipv4_addr.split('.') #"255.255.0.0" -> ["255", "255", "0", "0"]
    list_of_nums = [int(x) for x in split_ip_string] #["255", "255", "0", "0"] -> [255, 255, 0, 0]
    ret = (list_of_nums[0] << 24 | list_of_nums[1] << 16 | list_of_nums[2] << 8 | list_of_nums[3] << 0) #final operation

    return ret;



def value_to_ipv4(addr):
    """
    Convert a single 32-bit numeric value of integer type to a
    dots-and-numbers IP address. Returns a string type.
    """

    bytes = []
    num = addr
    offset = 8;
    for _ in range(4):
        bytes.insert(0, num & 0x000000ff)
        num = num >> offset

    bytes = [str(byte) for byte in bytes]
    ret_string = ""
    for byte in bytes:
        ret_string += byte + "."

    return ret_string[:-1]

def get_subnet_mask_value(slash):
    """
    Given a subnet mask in slash notation, return the value of the mask
    as a single number of integer type. The input can contain an IP
    address optionally, but that part should be discarded.

    Returns an integer type.
    """
    network_bits = int(slash[slash.index("/") + 1:])
    run_of_ones = (1 << network_bits) - 1
    run_of_ones = run_of_ones << 32-network_bits
    return run_of_ones

def ips_same_subnet(ip1, ip2, slash):
    """
    Given two dots-and-numbers IP addresses and a subnet mask in slash
    notation, return true if the two IP addresses are on the same
    subnet.

    Returns a boolean.
    """
    mask = get_subnet_mask_value(slash)
    ip1_num = ipv4_to_value(ip1)
    ip2_num = ipv4_to_value(ip2)

    return (mask & ip1_num) == (mask & ip2_num)

def get_network(ip_value, netmask):
    """
    Return the network portion of an address value as integer type.

    Example:

    ip_value: 0x01020304
    netmask:  0xffffff00
    return:   0x01020300
    """

    ip_num = ipv4_to_value(ip_value);
    return ip_num & netmask;

def find_router_for_ip(routers, ip):
    """
    Search a dictionary of routers (keyed by router IP) to find which
    router belongs to the same subnet as the given IP.

    Return None if no routers is on the same subnet as the given IP.
    """

    for router_ip, router_info in routers.items():
        if ips_same_subnet(router_ip, ip, router_info["netmask"]):
            return router_ip
    return None

# Uncomment this code to have it run instead of the real main.
# Be sure to comment it back out before you submit!
"""
def my_tests():
    print("-------------------------------------")
    print("This is the result of my custom tests")
    print("-------------------------------------")

    print(x)

    # Add custom test code here
"""

## -------------------------------------------
## Do not modify below this line
##
## But do read it so you know what it's doing!
## -------------------------------------------

def usage():
    print("usage: netfuncs.py infile.json", file=sys.stderr)

def read_routers(file_name):
    with open(file_name) as fp:
        json_data = fp.read()
        
    return json.loads(json_data)

def print_routers(routers):
    print("Routers:")

    routers_list = sorted(routers.keys())

    for router_ip in routers_list:
        # Get the netmask
        slash_mask = routers[router_ip]["netmask"]
        netmask_value = get_subnet_mask_value(slash_mask)
        netmask = value_to_ipv4(netmask_value)

        # Get the network number
        router_ip_value = ipv4_to_value(router_ip)
        network_value = get_network(router_ip_value, netmask_value)
        network_ip = value_to_ipv4(network_value)

        print(f" {router_ip:>15s}: netmask {netmask}: " \
            f"network {network_ip}")

def print_same_subnets(src_dest_pairs):
    print("IP Pairs:")

    src_dest_pairs_list = sorted(src_dest_pairs)

    for src_ip, dest_ip in src_dest_pairs_list:
        print(f" {src_ip:>15s} {dest_ip:>15s}: ", end="")

        if ips_same_subnet(src_ip, dest_ip, "/24"):
            print("same subnet")
        else:
            print("different subnets")

def print_ip_routers(routers, src_dest_pairs):
    print("Routers and corresponding IPs:")

    all_ips = sorted(set([i for pair in src_dest_pairs for i in pair]))

    router_host_map = {}

    for ip in all_ips:
        router = str(find_router_for_ip(routers, ip))
        
        if router not in router_host_map:
            router_host_map[router] = []

        router_host_map[router].append(ip)

    for router_ip in sorted(router_host_map.keys()):
        print(f" {router_ip:>15s}: {router_host_map[router_ip]}")

