import sys

BROOKLYN_FIPS = "36047"
QUEENS_FIPS = "36081"


def filter_crosswalk():
    f = sys.stdin
    print(next(f).strip())
    block_id_len = len("360010001001000")
    for line in f:
        if line[block_id_len + 1 : block_id_len + 6] == BROOKLYN_FIPS:
            print(line.strip())


command = sys.argv[1]
{"-filter-crosswalk": filter_crosswalk}[command]()
