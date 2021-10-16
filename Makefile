

#
# CROSSWALK
#

# Main block 2010 -> block 2020 crosswalk target. Same as original but only Brooklyn
crosswalk/block-crosswalk.csv: crosswalk/nhgis_blk2010_blk2020_gj_36.csv
	cat $< | \
	python3 main.py -filter-crosswalk > \
	$@

# Original zipfile downloaded from https://nhgis.org/geographic-crosswalks (NY)
crosswalk/nhgis_blk2010_blk2020_gj_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_gj_36.zip
