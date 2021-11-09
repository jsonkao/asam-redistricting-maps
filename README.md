## What this repo does

First, it interpolates the 2010 Asian population from 2010 block groups to 2020 block groups. The methodology and code for that can be found [here](https://jsonkao.github.io/asam-redistricting-maps/census.html). The block-group-to-block-group crosswalk is at [`crosswalk/crosswalk.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/citywide/crosswalk/crosswalk.csv). The final CSV that compares 2010 demographics data to 2020 demographics data on the same block group geography is at [`data/data.csv`](https://github.com/jsonkao/asam-redistricting-maps/blob/cityside/data/data.csv).

Next, it joins it with block group geographies and Letters plan geographies. The resulting GeoJSON is at [`mapping/output.geojson`](https://github.com/jsonkao/asam-redistricting-maps/blob/main/mapping/output.geojson).

Some exploratory mapping of that data lives on [Observable](https://observablehq.com/@jsonkao/asam-redistricting-maps).

The Makefile directs all the data downloading and transformation.

## TODOS

Mapbox (see [page](https://www.nytimes.com/interactive/2021/upshot/2020-election-map.html))
* The `https://api.mapbox.com/styles/v1/nytgraphics/ckk2oe4ck3n0o17p4lypsp2pu?access_token=pk.eyJ1Ijoibnl0Z3JhcGhpY3MiLCJhIjoiY2pka3N3czNiMDA4NTJxb2Q3Yno3OWl5bSJ9.4-IvzzJoY5grTlfFoukZag` request contains all NYT styles
* `https://api.mapbox.com/v4/mapbox.mapbox-streets-v8.json?secure&access_token=pk.eyJ1Ijoibnl0Z3JhcGhpY3MiLCJhIjoiY2pka3N3czNiMDA4NTJxb2Q3Yno3OWl5bSJ9.4-IvzzJoY5grTlfFoukZag` has other settings
* `https://api.mapbox.com/v4/nytgraphics.precincts2020counties.json?secure&access_token=pk.eyJ1Ijoibnl0Z3JhcGhpY3MiLCJhIjoiY2pka3N3czNiMDA4NTJxb2Q3Yno3OWl5bSJ9.4-IvzzJoY5grTlfFoukZag` seems like polygons are rendered by custom vector tiles

Census blocks
* Data isn't eprfect, but that's how you get the exact data the people are using to draw the maps.