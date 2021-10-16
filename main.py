import sys

BROOKLYN_FIPS = "3600470"  # State FIPS, '0', County FIPS, '0'
QUEENS_FIPS = "3600810"


def filter_crosswalk():
    f = sys.stdin
    print(next(f).strip())
    block_len = len("G36000100001001014")
    for line in f:
        if line[block_len + 2 : block_len + 9] == BROOKLYN_FIPS:
            print(line.strip())


command = sys.argv[1]
{"-filter-crosswalk": filter_crosswalk}[command]()
