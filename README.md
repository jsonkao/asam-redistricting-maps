## Documentary

- Color scale red; only in the district we're focusing on
- Same as other maps - just NYC as gray ; and then shade in the red

- At end of the doc, they want to show what happened at the end of the day


## What this repo does

First, it interpolates the 2010 Asian population from 2010 block groups to 2020 block groups. The methodology and code for that can be found [here](https://jsonkao.github.io/asam-redistricting-maps/census.html). The block-group-to-block-group crosswalk is at [`crosswalk/crosswalk.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/citywide/crosswalk/crosswalk.csv). The final CSV that compares 2010 demographics data to 2020 demographics data on the same block group geography is at [`data/data.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/cityside/data/data.csv).

Next, it joins it with block group geographies and Letters plan geographies. The resulting GeoJSON is at [`mapping/output.geojson`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/mapping/output.geojson).

Some exploratory mapping of that data lives on [Observable](https://observablehq.com/@jsonkao/asam-redistricting-maps).

The Makefile directs all the data downloading and transformation.
