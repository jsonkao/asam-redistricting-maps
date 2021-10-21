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
crosswalk/nhgis_blk2010_blk2020_ge_36047.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv filter.py
	cat $< | python3 filter.py -crosswalk > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip

#
# VOTING AGE POPULATION
#

cvap/CVAP_2010.csv: cvap/CVAP_2010.zip
	unzip -d cvap $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 filter.py -cvap > $@
	rm -rf "cvap/CVAP Files"
cvap/CVAP_2019.csv: cvap/CVAP_2019.zip
	unzip -d "cvap/CVAP Files" $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 filter.py -cvap > $@
	rm -rf "cvap/CVAP Files"

cvap/CVAP_2010.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2010/2010-cvap/CVAP_2006-2010_ACS_csv_files.zip
cvap/CVAP_2019.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2019/2019-cvap/CVAP_2015-2019_ACS_csv_files.zip
