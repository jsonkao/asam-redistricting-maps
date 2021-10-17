## What this repo does

First, it interpolates the 2010 Asian population from 2010 block groups to 2020 block groups. The methodology and code for that can be found [here](https://jsonkao.github.io/asam-redistricting-maps/census.html). The block-group-to-block-group crosswalk is at [`crosswalk/bg2010_bg2020.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/crosswalk/bg2010_bg2020.csv). The final CSV that compares 2010 demographics data to 2020 demographics data on the same block group geography is at [`outputs/blkgrp_asians.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/outputs/blkgrp_asians.csv).

Next, it joins it with block group geographic data. The resulting GeoJSON is at [`outputs/blkgrp_asians.geojson`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/outputs/blkgrp_asians.geojson).

Some exploratory mapping of that data lives on [Observable](https://observablehq.com/@jsonkao/asam-redistricting-maps).
