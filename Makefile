#
# MAPPING
# Join block group shapefile with data about Asian population
#

# Filter to only Brooklyn block groups; join it with census data
mapping/bg_brooklyn.topojson: mapping/tl_2021_36_bg.shp data/blkgrp_asians.csv Makefile
	mapshaper $< \
	-filter "COUNTYFP === '047' && ALAND > 0" \
	-filter-fields GEOID \
	-join $(word 2,$^) keys=GEOID,GEOID string-fields=GEOID \
	-o $@ format=topojson

mapping/tl_2021_36_bg.shp: mapping/tl_2021_36_bg.zip
	unzip -d mapping $<
	touch $@

# Zipfile downloaded from Census TIGER/Line FTP server
mapping/tl_2021_36_bg.zip:
	mkdir -p mapping
	curl -L https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_36_bg.zip -o $@

#
# CROSSWALK
# Using the crosswalk to get 2010 and 2020 data on the same block group geography
#

# Main target
data/blkgrp_asians.csv:
	mkdir -p data
	Rscript crosswalk/census.R $@

# Same as original block crosswalk but filtered down to Brooklyn (FIPS = 36047)
crosswalk/nhgis_blk2010_blk2020_ge_36047.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv main.py
	cat $< | python3 main.py -filter-crosswalk > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip
