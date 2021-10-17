#
# MAPPING:
# - Join block group shapefile with data about Asian population
#

# Project and make web-friendly
outputs/blkgrp_asians.topojson: outputs/blkgrp_asians.geojson
	mapshaper $< \
	-proj "+proj=laea +lon_0=-73.8555908 +lat_0=40.6825568 +datum=WGS84 +units=m +no_defs" \
	-target 1 name="block_groups" \
	-o $@ width=975

# Filter to only Brooklyn block groups; join it with census data
outputs/blkgrp_asians.geojson: mapping/tl_2021_36_bg.shp outputs/blkgrp_asians.csv
	mapshaper $< \
	-filter "COUNTYFP === '047' && ALAND > 0" \
	-filter-fields GEOID \
	-join $(word 2,$^) keys=GEOID,GEOID string-fields=GEOID \
	-o $@

mapping/tl_2021_36_bg.shp: mapping/tl_2021_36_bg.zip
	unzip -d mapping $<
	touch $@

# Zipfile downloaded from Census TIGER/Line FTP server
mapping/tl_2021_36_bg.zip:
	mkdir -p mapping
	curl -L https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_36_bg.zip -o $@

#
# CROSSWALK
# - Use the NHGIS crosswalk to get 2010 and 2020 data on the same block group geography
# - Helpful resource: https://forum.ipums.org/t/can-i-use-nhgis-crosswalk-for-block-group-level-data/2750
#

# Main target
outputs/blkgrp_asians.csv: crosswalk/census.R
	Rscript crosswalk/census.R $@

# Same as original block crosswalk but filtered down to Brooklyn (FIPS = 36047)
crosswalk/nhgis_blk2010_blk2020_ge_36047.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv filter-crosswalk.py
	cat $< | python3 filter-crosswalk.py > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip
