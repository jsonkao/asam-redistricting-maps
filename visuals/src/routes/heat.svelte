<script context="module">
	import { feature } from 'topojson-client';
	import { base } from '$app/paths';

	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const censusData = await (await fetch(`${base}/census.topojson`)).json();
		const census = feature(censusData, censusData.objects.census);

		return {
			props: {
				census
			}
		};
	}
</script>

<script>
	import { onMount } from 'svelte';
	import { hexToRGB } from '$lib/utils';

	export let census;

	let map, loaded;
	let year = '2000';

	$: console.log(year);

	function color({ properties: d }) {
		const colors = [
			'#d73027',
			'#f46d43',
			'#fdae61',
			'#fee08b',
			'#d9ef8b',
			'#a6d96a',
			'#66bd63',
			'#1a9850'
		];
		const cutoffs = {
			'1990': [-0.88, -0.54, -0.26, 0.03, 0.84, 1.97, 2.68, 3.86],
			'2000': [-2.69, -1.62, -0.85, -0.27, 0.24, 0.76, 1.4, 5.23],
			'2010': [-2.37, -1.43, -0.77, -0.22, 0.28, 0.78, 1.36, 4.9]
		};
		let i;
		for (i = 0; i < colors.length; i++) {
			if (d[year] <= cutoffs[year][i]) break;
		}
		return colors[colors.length - i - 1];
	}

	function getCensusFills() {
		const matchExp = ['match', ['get', 'GEOID']];
		census.features.forEach((f) => {
			matchExp.push(f.properties.GEOID, hexToRGB(color(f)));
		});
		matchExp.push('rgba(0, 0, 0, 0)');
		return matchExp;
	}

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
			map.setPaintProperty('census', 'fill-color', getCensusFills(year));
		}
	}
</script>

<svelte:head>
	<title>Urban Heat</title>
	<link href="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.css" rel="stylesheet" />
	<script src="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.js"></script>
</svelte:head>

<div class="container">
	<div class="controls">
		<select bind:value={year}>
			{#each ['1990', '2000', '2010'] as y}
				<option value={y}>{y}</option>
			{/each}
		</select>
	</div>
	<div id="map" />
</div>

<style>
	:global(body) {
		overflow: hidden;
	}

	.container {
		margin: 0 auto;
		font-size: var(--container-font);
	}

	select {
		font-size: 1em;
		outline: none;
		padding: 3px;
		margin-bottom: 5px;
	}

	.controls {
		position: fixed;
		max-width: var(--control-width);
		top: 22px;
		left: 22px;
		padding: 15px;
		background: #fff;
		z-index: 1;
		box-shadow: 0px 2px 5px #0006;
	}

	#map {
		width: 100vw;
		height: 100vh;
	}
</style>
