#
# TODO: GET UNITY FILES FROM REDISTRICTINGANDYOU
#


PLANS = senate_letters senate_names congress_letters congress_names assembly_letters assembly_names
PLANS_GEOJSON = $(PLANS:%=plans/%.geojson)

# xmin, ymin, xmax, ymax
FIRST_VIEWRECT = $(shell node visuals/src/lib/constants.js)

#
# PLANS for web
#


main: visuals/static/output_census_wgs84.topojson visuals/static/points.geojson visuals/static/plans.topojson


# For Mapbox

visuals/static/output_census_wgs84.topojson: mapping/census.geojson
	mapshaper $< \
	-simplify 22% \
	-clean \
	-o - format=topojson \
	| python3 preprocess.py -compress-topo \
	> $@

visuals/static/plans.topojson: plans/senate_letters.geojson plans/senate_names.geojson plans/assembly_letters.geojson plans/assembly_names.geojson plans/senate.geojson plans/assembly.geojson unity/assembly_unity.geojson unity/senate_unity.geojson
	mapshaper -i $^ combine-files \
	-clean \
	-simplify 22% \
	-o $@ quantization=1e5

visuals/static/points.geojson: visuals/static/plans.topojson
	mapshaper $< \
	-merge-layers force target=* \
	-points inner \
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
	-filter-fields DISTRICT,IDEAL_VALU \
	-rename-fields $(notdir $(basename $@))=DISTRICT \
	-o $@

plans/%.zip:
	curl -L https://www.nyirc.gov/storage/plans/20210915/$(notdir $@) -o $@
	unzip -d $(basename $@) $@

#
# CURRENT PLANS
#

current_plans: plans/senate.geojson plans/assembly.geojson plans/congress.geojson

plans/%.geojson:
	mapshaper plans/current/NYS-$(shell python3 -c 'print("$(notdir $(basename $@))".capitalize().replace("Congress","Congressional"))')-Districts.shp \
	-filter-fields DISTRICT \
	-rename-fields $(notdir $(basename $@))=DISTRICT \
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

# Filter geography down; join it with census data
# TODO: join with plans
# -join "$(filter-out $<,$^)" fields=DISTRICT largest-overlap
mapping/census.geojson: mapping/tl_2021_36_bg/tl_2021_36_bg.shp data/data.csv
	mapshaper $< \
	-filter "['047', '081', '061', '005', '085'].includes(COUNTYFP)" \
	-filter-fields GEOID,ALAND \
	-join $(word 2,$^) keys=GEOID,GEOID string-fields=GEOID \
	-join plans/senate.geojson largest-overlap \
	-join plans/senate_letters.geojson largest-overlap \
	-join plans/senate_names.geojson largest-overlap \
	-join plans/assembly.geojson largest-overlap \
	-join plans/assembly_letters.geojson largest-overlap \
	-join plans/assembly_names.geojson largest-overlap \
	-join plans/congress.geojson largest-overlap \
	-join plans/congress_letters.geojson largest-overlap \
	-join plans/congress_names.geojson largest-overlap \
	-join unity/assembly_unity.geojson largest-overlap \
	-join unity/senate_unity.geojson largest-overlap \
	-o bbox $@

mapping/tl_2021_36_bg/tl_2021_36_bg.shp: mapping/tl_2021_36_bg.zip
	unzip -d $(dir $@) $<
	touch $@

# Zipfile downloaded from Census TIGER/Line FTP server
mapping/tl_2021_36_bg.zip:
	mkdir -p mapping
	curl -L https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_36_bg.zip -o $@

#
# UNITY MAPS
# - "unity/UnityMappingAssemblyDistrict 2021-11-04.json" was manually downloaded; spaces manually replaced with underscores

unity/senate_unity.geojson: unity/um_senate_1118.json
	jq 'del(.name, .map_layer_type, .bounds, .center, .zoom, .median_zoom, .count, .property_names)' $< \
	| mapshaper -i - \
	-filter 'District !== null' \
	-filter-fields District \
	-rename-fields senate_unity=District \
	-o $@

unity/assembly_unity.geojson: unity/um_assembly.json
	jq 'del(.name, .map_layer_type, .bounds, .center, .zoom, .median_zoom, .count, .property_names)' $< \
	| mapshaper -i - \
	-filter 'District !== null' \
	-filter-fields District \
	-rename-fields assembly_unity=District \
	-o $@

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
crosswalk/nhgis_blk2010_blk2020.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv preprocess.py
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


# =
# ===
# GARBAGE CAN
# ===
# =

#
# Web stuff
#

visuals/static/points.json: visuals/static/output.topojson Makefile
	mapshaper $< \
	-drop target=census,streets \
	-merge-layers force target=* \
	-points inner \
	-each "this.coordinates = congress_letters === 'J' ? [65, 715] : this.coordinates" \
	-o format=geojson ndjson - \
	| ndjson-map '[...d.geometry.coordinates.map(Math.round), ...Object.entries(d.properties)[0]]' \
	| ndjson-reduce \
	> $@

output_parts: visuals/static/output_assembly_senate.topojson visuals/static/output_congress.topojson

visuals/static/output_assembly_senate_unity.topojson: visuals/static/output.topojson
	mapshaper $< -o $@ target=assembly,assembly_letters,assembly_names,assembly_unity,senate,senate_letters,senate_names,senate_unity

# Prioritizes BGs in initial viewbox
visuals/static/output_census.topojson: visuals/static/output.topojson visuals/src/lib/constants.js
	mapshaper $< \
	-rectangle bbox=$(FIRST_VIEWRECT) name=rect \
	-each view=1 \
	-target census \
	-join rect \
	-sort "fields ? 2 : (view || 0)" descending \
	-filter-fields d,fields \
	-o $@ target=census

visuals/static/output_congress.topojson: visuals/static/output.topojson
	mapshaper $< -o $@ target=congress,congress_letters,congress_names

visuals/static/output_streets.topojson: visuals/static/output.topojson
	mapshaper $< -o $@ target=streets

mapping/output.shp: mapping/census.geojson $(PLANS_GEOJSON) plans/senate.geojson plans/congress.geojson plans/assembly.geojson streets/streets.geojson unity/assembly_unity.geojson
	mapshaper -i $^ combine-files \
	-simplify 22% target=census,assembly,assembly_letters,assembly_names,senate,senate_letters,senate_names,congress,congress_letters,congress_names \
	-target '*' \
	-clean \
	-o $@

visuals/static/output.topojson: mapping/census.geojson $(PLANS_GEOJSON) plans/senate.geojson plans/congress.geojson plans/assembly.geojson streets/streets.geojson unity/assembly_unity.geojson unity/senate_unity.geojson
	mapshaper -i $^ combine-files \
	-clip bbox=$(shell cat $< | jq -c .bbox | jq -r 'join(",")') \
	-proj aea \
	-simplify 22% target=census,assembly,assembly_letters,assembly_names,senate,senate_letters,senate_names,congress,congress_letters,congress_names \
	-target '*' \
	-clean \
	-o - format=topojson width=975 \
	| python3 preprocess.py -compress-topo \
	| mapshaper -i - \
	-clean \
	-o $@


#
# STREETS
#

streets/streets.geojson: streets/SimplifiedStreets.shp/SimplifiedStreetSegmentQrt.shp
	mapshaper $< \
	-filter "LeftCounty =='Kings' || RightCount=='Kings'" \
	-simplify 0.8% \
	-filter-fields Label \
	-clean \
	-o $@

streets/SimplifiedStreets.shp/SimplifiedStreetSegmentQrt.shp:
	curl -o streets/SimplifiedStreets.shp.zip -L "https://gis.ny.gov/gisdata/fileserver/?DSID=932&file=SimplifiedStreets.shp.zip"
	unzip -d streets streets/SimplifiedStreets.shp.zip
	mapshaper streets/SimplifiedStreets.shp/SimplifiedStreetSegmentQrt.shp \
	-filter "LeftCityTo =='New York' || RightCityT=='New York'" \
	-filter "Label.length > 0" \
	-proj wgs84 \
	-clean \
	-filter-fields Label,LeftCounty,RightCount \
	-o streets/SimplifiedStreets.shp/SimplifiedStreetSegmentQrt.shp force
