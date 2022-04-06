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


main: visuals/static/data.csv visuals/static/points.geojson visuals/static/plans.topojson

#
# SVGs for documentary
#

svg/asians.geojson: mapping/census.geojson mapping/counties.geojson
	mapshaper -i $^ combine-files \
	-target census \
	-each "prop_asian = pop20_asian / pop20_total" \
	-filter "prop_asian >= 0.1" \
	-filter "pop20_total > 0" \
	-colorizer name=getColor colors='#D2A4A3,#D44C46,#A34946,#5A0909' breaks=0.2,0.4,0.6 \
	-style fill='getColor(prop_asian)' \
	-target counties \
	-style fill='#686969' \
	-target "*" \
	-simplify 22% \
	-clean \
	-proj EPSG:3857 \
	-o $@

mapping/counties.geojson:
	curl -L "https://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/NYC_Borough_Boundary/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=pgeojson" -o $@

# For Mapbox

# Non-geographic data source
visuals/static/data.csv: mapping/census.geojson
	mapshaper $< \
	-filter "pop20_total > 0" \
	-drop fields=GEOID,ALAND,IDEAL_VALU \
	-o $@


visuals/static/output_census_wgs84.topojson: mapping/census.geojson
	mapshaper $< \
	-simplify 22% \
	-clean \
	-o - format=topojson \
	| python3 preprocess.py -compress-topo \
	> $@

visuals/static/plans.topojson: plans/senate_letters.geojson plans/senate_names.geojson plans/assembly_letters.geojson plans/assembly_names.geojson plans/senate.geojson plans/assembly.geojson unity/assembly_unity.geojson unity/senate_unity.geojson latfor/assembly_latfor.geojson latfor/senate_latfor.geojson
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
# - Join blocks shapefile with demographic data
#

# Filter geography down; join it with census data
mapping/census.geojson: mapping/tl_2021_36_tabblock20/tl_2021_36_tabblock20.shp data/data.csv
	mapshaper $< \
	-filter "['047', '081', '061', '005', '085'].includes(COUNTYFP20)" \
	-rename-fields GEOID=GEOID20,ALAND=ALAND20 \
	-filter-fields GEOID,ALAND \
	-join $(word 2,$^) keys=GEOID,GEOID string-fields=GEOID \
	-join plans/senate.geojson largest-overlap \
	-join plans/senate_letters.geojson largest-overlap \
	-join plans/senate_names.geojson largest-overlap \
	-join plans/assembly.geojson largest-overlap \
	-join plans/assembly_letters.geojson largest-overlap \
	-join plans/assembly_names.geojson largest-overlap \
	-join unity/assembly_unity.geojson largest-overlap \
	-join unity/senate_unity.geojson largest-overlap \
	-join latfor/assembly_latfor.geojson largest-overlap \
	-join latfor/senate_latfor.geojson largest-overlap \
	-o bbox $@

mapping/tl_2021_36_tabblock20/tl_2021_36_tabblock20.shp: mapping/tl_2021_36_tabblock20.zip
	unzip -d $(dir $@) $<
	touch $@

# Zipfile downloaded from Census TIGER/Line FTP server
mapping/tl_2021_36_tabblock20.zip:
	mkdir -p mapping
	curl -L https://www2.census.gov/geo/tiger/TIGER2021/TABBLOCK20/tl_2021_36_tabblock20.zip -o $@

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
# LATFOR MAPS
#

latfor: latfor/senate_latfor.geojson latfor/assembly_latfor.geojson

latfor/senate_latfor.geojson: latfor/Senate22.shp
	mapshaper $< -rename-fields senate_latfor=DISTRICT -o $@

latfor/assembly_latfor.geojson: latfor/Assembly22.shp
	mapshaper $< -rename-fields assembly_latfor=ID -o $@

latfor/Senate22.shp:
	curl -o latfor/2022senate_shape_file.zip -L https://latfor.state.ny.us/maps/2022senate/2022senate_shape_file.zip
	unzip -d latfor latfor/2022senate_shape_file.zip
	touch $@
	rm latfor/2022senate_shape_file.zip

latfor/Assembly22.shp:
	curl -o latfor/2022assembly_shape_file.zip -L https://latfor.state.ny.us/maps/2022assembly/2022assembly_shape_file.zip
	unzip -d latfor latfor/2022assembly_shape_file.zip
	touch $@
	rm latfor/2022assembly_shape_file.zip

#
# DATA
# - The data that goes into mapping ifles
#

data: data/data.csv
data/data.csv: data/data.R crosswalk/nhgis_blk2010_blk2020.csv
	Rscript $< $@

#
# CROSSWALK
#

# Same as original block crosswalk but filtered down to areas of interest
crosswalk/nhgis_blk2010_blk2020.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv preprocess.py
	cat $< | python3 preprocess.py -filter-crosswalk > $@

# I manually downloaded the zipfile from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip
