import sys, json

FIPSES = ["36047", "36061", "36081"]


def compress_topojson():
    topo = json.load(sys.stdin)
    geoms = topo["objects"]["census"]["geometries"]
    properties = [k for k in list(geoms[0]["properties"].keys()) if k != 'IDEAL_VALU']

    compress_names = False
    if compress_names:
        names = {"senate_names": set(), "assembly_names": set(), "congress_names": set()}
        keys = names.keys()
        for g in geoms:
            for k in keys:
                if g['properties'][k]:
                    names[k].add(g['properties'][k])
        names_index = {}
        for k in keys:
            names[k] = list(names[k])
            names_index[k] = {names[k][i]: i for i in range(len(names[k]))}
        for g in geoms:
            for k in keys:
                g["properties"][k] = names_index[k][g["properties"][k]]
    for g in geoms:
        g["properties"] = {
            "d": ",".join(
                [
                    str(g["properties"][properties[i]] or "")
                    for i in range(len(properties))
                ]
            )
        }
    geoms[0]["properties"]["fields"] = properties
    if compress_names:
        geoms[0]["properties"]["names"] = names
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


def get_ideal_values():
    values = {}
    for scope in ['assembly', 'senate', 'congress']:
        for proposal in ['letters', 'names']:
            plan = f'{scope}_{proposal}'
            with open(f'plans/{plan}.geojson') as f:
                next(f)
                feature = next(f)
            start = feature.find("IDEAL_VALU") + 12
            end = feature.find("}", start)
            values[plan] = int(feature[start:end])
    print(values)

command = sys.argv[1]
{
    "-compress-topo": compress_topojson,
    "-filter-crosswalk": filter_crosswalk,
    "-filter-cvap": filter_cvap,
    "-get-ideals": get_ideal_values,
}[command]()
