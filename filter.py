import sys

BROOKLYN_FIPS = "36047"
QUEENS_FIPS = "36081"
RICHMOND_FIPS = "36085"

def filter_cvap():
    sys.stdin.reconfigure(encoding="ISO-8859-1")
    f = sys.stdin
    print(next(f).strip())
    for line in f:
        geoid = line.split(',')[-6].split('US')[1]
        if geoid.startswith(BROOKLYN_FIPS) or geoid.startswith(RICHMOND_FIPS):
            print(line.strip())


def filter_crosswalk():
    f = sys.stdin
    print(next(f).strip())
    block_id_len = len("360010001001000")
    for line in f:
        if line[block_id_len + 1 : block_id_len + 6] in [BROOKLYN_FIPS, RICHMOND_FIPS]:
            print(line.strip())


command = sys.argv[1]
{"-crosswalk": filter_crosswalk, "-cvap": filter_cvap}[command]()
