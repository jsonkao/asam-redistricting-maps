

#
# Using the crosswalk to get 2010 and 2020 data on the same block group geography
#

# Main target
data/blkgrp_asians.csv: crosswalk/nhgis_blk2010_blk2020_ge_36047.csv
	Rscript crosswalk/census.R $@

# Same as original block crosswalk but filtered down to Brooklyn (FIPS = 36047)
crosswalk/nhgis_blk2010_blk2020_ge_36047.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv main.py
	cat $< | python3 main.py -filter-crosswalk > $@

# Zipfile downloaded from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip
