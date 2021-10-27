#
# PLANS for web
#

# TODO: add ismplify 22% somewhere again

PLANS = senate_letters senate_names congress_letters congress_names assembly_letters assembly_names
PLANS_GEOJSON = $(PLANS:%=plans/%.geojson)

web_plans: visuals/static/senate_letters.topojson

visuals/static/%.topojson: Makefile plans/%/*.shp
	mapshaper "$(filter-out $<,$^)" -target 1 name="$(notdir $(basename $@))" -o $@

# Export plans I only need
plans/plans.topojson: senate_letters senate_names $(PLANS_GEOJSON)
	mapshaper -i $^ combine-files \
	-o $@

#
# PROPOSED PLANS
#

plans: clean_plans $(PLANS_GEOJSON)
clean_plans:
	rm -f $(PLANS_GEOJSON)
proposed_plans: $(PLANS:%=plans/%.zip) $(PLANS:%=plans/%.geojson)

clean_plans_artifacts:
	find plans -type f -name "*.png" -exec rm -rf {} \;
	find plans -type f -name "*.csv" -exec rm -rf {} \;
	find plans -type f -name "*.pdf" -exec rm -rf {} \;

plans/%.geojson: plans/%/*.shp
	mapshaper "$^" \
	-filter-fields DISTRICT \
	-rename-fields $(shell python3 -c 'print({"assembly":"AD","senate":"SD","congress":"CD"}["$@"[6:-8].split("_")[0]])')=DISTRICT \
	-o $@

plans/%.zip:
	curl -L https://www.nyirc.gov/storage/plans/20210915/$(notdir $@) -o $@
	unzip -d $(basename $@) $@

#
# CURRENT PLANS
#

current_plans: plans/senate.geojson plans/assembly.geojson plans/congress.geojson

plans/%.geojson: Makefile
	mapshaper plans/current/NYS-$(shell python3 -c 'print("$(notdir $(basename $@))".capitalize().replace("Congress","Congressional"))')-Districts.shp \
	-filter-fields DISTRICT \
	-rename-fields $(shell python3 -c 'print({"assembly":"AD","senate":"SD","congress":"CD"}["$@"[6:-8]])')=DISTRICT \
	-proj wgs84 \
	-o $@

plans/current.zip:
	curl -o $@ -L https://gis.ny.gov/gisdata/data/ds_1360/NYS-Legislative-Boundaries-shp.zip
	unzip -d plans/current $@
	touch plans/current/*

#
# MAPPING:
# - Join block group shapefile with data about Asian population
#

map_static: visuals/static/output.topojson
visuals/static/%: mapping/% preprocess.py
	cat $< | python3 preprocess.py -compress-topo > $@

# Project and make web-friendly
# -proj "+proj=laea +lon_0=-73.8555908 +lat_0=40.6825568 +datum=WGS84 +units=m +no_defs"
%.topojson: %.geojson
	mapshaper $< \
	-proj aea \
	-target 1 name="$(notdir $(basename $@))" \
	-o $@ width=975

# Join with plans
mapping/output.geojson: mapping/census.geojson plans/senate_letters/*.shp
	mapshaper $< \
	-join "$(filter-out $<,$^)" fields=DISTRICT largest-overlap \
	-rename-fields NEIGHBORHOOD=ntaname \
	-o bbox $@

# Filter geography down; join it with census data
mapping/census.geojson: mapping/tl_2021_36_bg/tl_2021_36_bg.shp data/data.csv
	mapshaper $< \
	-filter "['047', '081', '061'].includes(COUNTYFP)" \
	-filter-fields GEOID,ALAND \
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

data: data/data.csv
data/data.csv: data/data.R crosswalk/crosswalk.csv cvap/CVAP_2010.csv cvap/CVAP_2019.csv
	Rscript $< $@

#
# CROSSWALK
# - Use the NHGIS crosswalk to get 2010 and 2020 data on the same block group geography
# - Helpful resource: https://forum.ipums.org/t/can-i-use-nhgis-crosswalk-for-block-group-level-data/2750
#

crosswalk: crosswalk/crosswalk.csv
crosswalk/crosswalk.csv: crosswalk/crosswalk.R crosswalk/nhgis_blk2010_blk2020.csv
	Rscript $< $@

# Same as original block crosswalk but filtered down to areas of interest
crosswalk/nhgis_blk2010_blk2020.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv
	cat $< | python3 preprocess.py -filter-crosswalk > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip

#
# CITIZEN VOTING AGE POPULATION
#

cvap/CVAP_2010.csv: cvap/CVAP_2010.zip
	unzip -d cvap $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 preprocess.py -filter-cvap > $@
	rm -rf "cvap/CVAP Files"
cvap/CVAP_2019.csv: cvap/CVAP_2019.zip
	unzip -d "cvap/CVAP Files" $<
	cat "cvap/CVAP Files/BlockGr.csv" | python3 preprocess.py -filter-cvap > $@
	rm -rf "cvap/CVAP Files"

cvap/CVAP_2010.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2010/2010-cvap/CVAP_2006-2010_ACS_csv_files.zip
cvap/CVAP_2019.zip:
	curl -o $@ -L https://www2.census.gov/programs-surveys/decennial/rdo/datasets/2019/2019-cvap/CVAP_2015-2019_ACS_csv_files.zip
