<script context="module">
	import { feature } from 'topojson-client';

	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const censusData = await (await fetch(`${base}/census.topojson`)).json();
		const census = feature(censusData, censusData.objects.census);

		return {
			props: {
				census
			}
		}
	}
</script>

<script>
	import { onMount } from 'svelte';
	import { hexToRGB } from '$lib/utils';

	export let census;

	let map, loaded;
	let year = '2000';

	function color({ properties: d }) {
		const colors = ['#d73027','#f46d43','#fdae61','#fee08b','#d9ef8b','#a6d96a','#66bd63','#1a9850'];
		const cutoffs = [-4.5, -3, -1.5, 0, 1.5, 3, 4.5, 6];
		let i;
		for (i = 0; i < cutoffs.length; i++) {
			if (d[year] < cutoffs[i]) break;
		}
		return colors[i];
	}

	function getCensusFills() {
		if (metric === null) return 'rgba(0, 0, 0, 0)';
		const matchExp = ['match', ['get', 'GEOID']];
		census.features.forEach((f) => {
			matchExp.push(f.properties.GEOID, hexToRGB(color(f)));
		});
		matchExp.push('rgba(0, 0, 0, 0)');
		return matchExp;
	}

	const defaultLineWidth = ['case', ['boolean', ['feature-state', 'pointing'], false], 2.5, 1.2];

	onMount(() => {
		mapboxgl.accessToken =
			'pk.eyJ1IjoianNvbmthbyIsImEiOiJjanNvM2U4bXQwN2I3NDRydXQ3Z2kwbWQwIn0.JWAoBlcpDJwkzG-O5_r0ZA';
		map = new mapboxgl.Map({
			container: 'map',
			style: 'mapbox://styles/jsonkao/ckvnu5tpy6coj14uizvyf1wuf/draft',
			center: [-73.967, 40.72],
			zoom: 11
		});

		map.on('load', async () => {
			map.addSource('census', { type: 'geojson', data: census });
			map.addLayer(
				{
					id: 'census',
					type: 'fill',
					source: 'census',
					paint: {
						'fill-color': getCensusFills()
					}
				},
				'parks'
			);
			loaded = true;
		});
	});

	$: {
		if (loaded) {
			map.setPaintProperty('census', 'fill-color', getCensusFills(metric, period, showPluralities));
		}
	}
</script>

<svelte:head>
	<link href="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.css" rel="stylesheet" />
	<script src="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.js"></script>
</svelte:head>

<div id="map" />

<style>
	:global(body) {
		overflow: hidden;
	}

	#map {
		width: 100vw;
		height: 100vh;
	}
</style>
