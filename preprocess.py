import sys, json

FIPSES = ["36047", "36061", "36081"]


def compress_topojson():
    topo = json.load(sys.stdin)
    geoms = topo["objects"]["census"]["geometries"]
    properties = list(geoms[0]["properties"].keys())
    for g in geoms:
        g["properties"] = {
            i: g["properties"][properties[i]]
            for i in range(len(properties))
            if g["properties"][properties[i]] is not None
        }
    geoms[0]["properties"]["fields"] = properties
    json.dump(topo, sys.stdout)


def filter_cvap():
    sys.stdin.reconfigure(encoding="ISO-8859-1")
    f = sys.stdin
    print(next(f).strip())
    for line in f:
        geoid = line.split(",")[-6].split("US")[1]
        if geoid[:5] in FIPSES:
            print(line.strip())


def filter_crosswalk():
    f = sys.stdin
    print(next(f).strip())
    block_id_len = len("360010001001000")
    for line in f:
        if line[block_id_len + 1 : block_id_len + 6] in FIPSES:
            print(line.strip())


command = sys.argv[1]
{
    "-compress-topo": compress_topojson,
    "-filter-crosswalk": filter_crosswalk,
    "-filter-cvap": filter_cvap,
}[command]()
