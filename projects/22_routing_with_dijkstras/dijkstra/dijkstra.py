import sys
import json
import math  # If you want to use math.inf for infinity
import netfuncs as nf

def dijkstras_shortest_path(routers, src_ip, dest_ip):

    source_router = nf.find_router_for_ip(routers, src_ip);
    dest_router = nf.find_router_for_ip(routers, dest_ip);

    if source_router == dest_router:
        return [];

    # TODO Write me!
    dist = {}
    prev = {}
    to_visit = [];

    for router in routers:
        dist[router] = math.inf
        prev[router] = None
        to_visit.append(router);

    dist[source_router] = 0;


    while len(to_visit) > 0:
        currentNode = smallestDist(dist, to_visit)
        to_visit.remove(currentNode)

        for neighbor in routers[currentNode]["connections"]:

            if neighbor not in to_visit:
                continue

            total_dist = dist[currentNode] + routers[currentNode]["connections"][neighbor]["ad"]

            if total_dist < dist[neighbor]:
                dist[neighbor] = total_dist
                prev[neighbor] = currentNode

    path = [];

    curr = dest_router
    while(curr != None):
        path.append(curr);
        curr = prev[curr]

    path.reverse()

    return path


def smallestDist(distDict, q):

    smallestSeen = math.inf
    retRouter = None

    for key, value in distDict.items():
        if value < smallestSeen and key in q:
            retRouter = key
            smallestSeen = value

    return retRouter

#------------------------------
# DO NOT MODIFY BELOW THIS LINE
#------------------------------
def read_routers(file_name):
    with open(file_name) as fp:
        data = fp.read()

    return json.loads(data)

def find_routes(routers, src_dest_pairs):
    for src_ip, dest_ip in src_dest_pairs:
        path = dijkstras_shortest_path(routers, src_ip, dest_ip)
        print(f"{src_ip:>15s} -> {dest_ip:<15s}  {repr(path)}")

def usage():
    print("usage: dijkstra.py infile.json", file=sys.stderr)

def main(argv):
    try:
        router_file_name = argv[1]
    except:
        usage()
        return 1

    json_data = read_routers(router_file_name)

    routers = json_data["routers"]
    routes = json_data["src-dest"]

    find_routes(routers, routes)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    
