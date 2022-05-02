## Intro

## Data preparation

I used Landsat imagery as a source of land surface temperature (LST). I used extensive land use data at the tax lot level compiled by New York City in the Primary Land Use Tax Lot Output (PLUTO) database. PLUTO contains data about the buildings in each tax lot, including zoning information (e.g. maximum allowable floor-to-area ratios), the number of residential units, and the name of the owner (which can reveal important characteristics such as whether the building is public housing). I also used the USGS National Land Cover Database (NLCD) to determine the amount of impervious surfacing in a given region. The NLCD is a raster database at 30m resolution. Each pixel is labelled with the percentage of impervious surfacing within that pixel, as well as the dominant type of surfacing within it. Surfacing classes include different kinds of roads, buildings, energy production sites (e.g. road vs. building). I also use the layer of NLCD that details the percentage of each pixel covered by trees.

## Research workflow

I built an interactive website to visualize the data, as well as to explain to local communities why their neighborhoods could experience higher or lower temperatures. The website is built with Svelte, a JavaScript framework commonly used for interactive graphics, and SvelteKit, a full stack toolbox for Svelte websites. The website lets you visualize two metrics at once.

![images/South_Bronx.png]
An example of using the visualization to find a story is in the south Bronx. I had the impervious surfacing metric toggled on, in combination with the temperature map. was curious about what a strip

Multiple interstate highways, power plants, and trucking operations are there.

/* TODO: this is what i did, why, and what id do next */

/* TODO: primer on heat */

/* Jupyter noteebok */

/* Have the Colab run on local VM; Have someone local be able to run it like Hong */

due 5/6

just send her an email with url, repo