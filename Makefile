

#
# CROSSWALK
#

# Main block 2010 -> block 2020 crosswalk target. Same as original but only Brooklyn
crosswalk/nhgis_blk_weights.csv: crosswalk/nhgis_blk2010_blk2020_ge_36.csv main.py
	cat $< | python3 main.py -filter-crosswalk > $@

# Zipfile downloaded from https://www.nhgis.org/geographic-crosswalks
crosswalk/nhgis_blk2010_blk2020_ge_36.csv:
	unzip -d crosswalk crosswalk/nhgis_blk2010_blk2020_ge_36.zip
