#
# PLANS
#

plans: clean_plans plans/senate_letters.geojson

clean_plans:
	rm -f plans/*.geojson

plans/%.geojson: mapping/output.geojson plans/%/*.shp
	mapshaper "$(filter-out $<,$^)" \
	-clip bbox=$(shell cat $< | jq -c .bbox | jq -r 'join(",")') \
	-o $@

plans/%.zip:
	curl -L https://www.nyirc.gov/storage/plans/20210915/$(notdir $@) -o $@
	unzip -d $(basename $@) $@

#
# MAPPING:
# - Join block group shapefile with data about Asian population
#

map_output: mapping/output.topojson

# Makes files web-friendly
%.topojson: %.geojson
	mapshaper $< \
	-proj "+proj=laea +lon_0=-73.8555908 +lat_0=40.6825568 +datum=WGS84 +units=m +no_defs" \
	-target 1 name="$(notdir $(basename $@))" \
	-o $@ width=975

# Join with plans
mapping/output.geojson: mapping/census.geojson plans/senate_letters/*.shp
	mapshaper $< \
	-join "$(filter-out $<,$^)" fields=DISTRICT,POPULATION,DEVIATION \
	-o bbox $@

# Filter geography down; join it with census data
mapping/census.geojson: mapping/tl_2021_36_bg/tl_2021_36_bg.shp data/data.csv
	mapshaper $< \
	-filter "['047', '085'].includes(COUNTYFP) && ALAND > 0" \
	-filter-fields GEOID \
	-join $(word 2,$^) keys=GEOID,GEOID string-fields=GEOID \
	-o $@

mapping/tl_2021_36_bg/tl_2021_36_bg.shp: mapping/tl_2021_36_bg.zip
	unzip -d $(dir $@) $<
	touch $@

# Zipfile downloaded from Census TIGER/Line FTP server
mapping/tl_2021_36_bg.zip:
	mkdir -p mapping
	curl -L https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_36_bg.zip -o $@

#
# DATA
# - The data that goes into mapping ifles
#

data/data.csv: data/data.R crosswalk/crosswalk.csv
	Rscript $< $@

#
# CROSSWALK
# - Use the NHGIS crosswalk to get 2010 and 2020 data on the same block group geography
# - Helpful resource: https://forum.ipums.org/t/can-i-use-nhgis-crosswalk-for-block-group-level-data/2750
#

crosswalk/crosswalk.csv: crosswalk/crosswalk.R crosswalk/nhgis_blk2010_blk2020.csv
	Rscript $< $@

# Same as original block crosswalk but filtered down to areas of interest
crosswalk/nhgis_blk2010_blk2020.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv filter.py
	cat $< | python3 filter.py -crosswalk > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip

#
# VOTING AGE POPULATION
#

cvap: cvap/CVAP_2010.csv cvap/CVAP_2019.csv

cvap/CVAP_2010.csv: cvap/CVAP_2010.zip filter.py
	unzip -d cvap $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 filter.py -cvap > $@
	rm -rf "cvap/CVAP Files"
cvap/CVAP_2019.csv: cvap/CVAP_2019.zip filter.py
	unzip -d "cvap/CVAP Files" $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 filter.py -cvap > $@
	rm -rf "cvap/CVAP Files"

cvap/CVAP_2010.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2010/2010-cvap/CVAP_2006-2010_ACS_csv_files.zip
cvap/CVAP_2019.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2019/2019-cvap/CVAP_2015-2019_ACS_csv_files.zip
