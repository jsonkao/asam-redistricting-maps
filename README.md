## What this repo does

First, it interpolates the 2010 Asian population from 2010 block groups to 2020 block groups. The methodology and code for that can be found [here](https://jsonkao.github.io/asam-redistricting-maps/census.html). The final output CSV is at [`outputs/blkgrp_asians.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/outputs/blkgrp_asians.csv).

Next, it joins it with block group geographic data. The resulting GeoJSON is at [`outputs/blkgrp_asians.geojson`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/outputs/blkgrp_asians.geojson).

Some exploratory mapping of that data is in [Observable](https://observablehq.com/@jsonkao/asam-redistricting-maps).