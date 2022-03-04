<script context="module">
	import { base } from '$app/paths';
	import { feature } from 'topojson-client';
	import { unpackAttributes } from '$lib/utils';

	export async function load({ fetch }) {
		const req = await fetch(`${base}/plans.topojson`);
		const req1 = await fetch(`${base}/output_census_wgs84.topojson`);

		const topo = await req1.json();
		const obj = unpackAttributes(topo.objects.census);
		const census = feature(topo, obj);

		return { props: { topoData: await req.json(), census, /*points: req2*/ } };
	}
</script>

<script>
	import { onMount } from 'svelte';
	import { planDesc } from '$lib/utils';
	import { seqColors } from '$lib/constants';

	export let topoData, census, points;

	let map, loaded;

	const plans = [
		'assembly',
		'assembly_letters',
		'assembly_names',
		'assembly_unity',
		'senate',
		'senate_letters',
		'senate_names',
		'senate_unity'
	];
	const breaksCache = {
		pop: [0, 0.1, 0.2, 0.4, 0.6],
		cvap: [0, 0.1, 0.2, 0.4, 0.6]
	};

	const metric = 'pop20';
	const variable = 'pop';
	function color({ properties: d }) {
		if (!d.ALAND) return 'rgba(0, 0, 0, 0)';
		const total = d[`${metric}_total`];

		if (total <= 10) return 'rgba(0, 0, 0, 0)';
		const p = (g) => d[`${metric}_${g}`] / d[`${metric}_total`];

		const breaks = breaksCache[variable];
		for (let i = 1; i < breaks.length; i++) {
			if (p('asian') < breaks[i]) return seqColors[i - 1];
		}
		return seqColors[breaks.length - 1];
	}

	onMount(() => {
		mapboxgl.accessToken =
			'pk.eyJ1IjoianNvbmthbyIsImEiOiJjanNvM2U4bXQwN2I3NDRydXQ3Z2kwbWQwIn0.JWAoBlcpDJwkzG-O5_r0ZA';
		map = new mapboxgl.Map({
			container: 'map',
			style: 'mapbox://styles/jsonkao/ckvnu5tpy6coj14uizvyf1wuf/draft',
			center: [-73.967, 40.72],
			zoom: 12 // starting zoom
		});

		map.on('load', async () => {
			const layers = map.getStyle().layers;
			map.addSource('census', { type: 'geojson', data: census });
			const matchExp = ['match', ['get', 'GEOID']];
			census.features.forEach((f) => {
				matchExp.push(f.properties.GEOID, color(f));
			});
			matchExp.push('rgba(0, 0, 0, 0)');
			map.addLayer(
				{
					id: 'census',
					type: 'fill',
					source: 'census',
					paint: {
						'fill-color': matchExp
					}
				},
				'parks'
			);

			plans.forEach((k) => {
				const data = feature(topoData, topoData.objects[k]);
				map.addSource(k, {
					type: 'geojson',
					data
				});/*
				map.addSource(k + '_labels', {
					type: 'geojson',
					data: {
						type: 'FeatureCollection',
						features: points.filter(p => p.properties[k])
					}
				});*/
				map.addLayer({
					id: k + '_outline',
					type: 'line',
					source: k,
					layout: {},
					paint: {
						'line-color': '#000',
						'line-width': 1
					}
				});
				map.addLayer({
					id: k + '_fill',
					type: 'fill',
					source: k,
					layout: {},
					paint: {
						'fill-color': '#000000',
						'fill-opacity': 0
					}
				});/*
				map.addLayer({
					id: k + '_labels',
					type: 'symbol',
					source: k + '_labels',
					layout: {
						'text-justify': 'auto',
					}
				});*/
				map.on('click', k + '_fill', (e) => {
					new mapboxgl.Popup().setLngLat(e.lngLat).setHTML(e.features[0].properties[k]).addTo(map);
				});
			});
			loaded = true;
		});
	});

	let plan;

	$: {
		if (loaded) {
			plans.forEach((p) => {
				const visibility = p === plan ? 'visible' : 'none';
				map.setLayoutProperty(`${p}_outline`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_fill`, 'visibility', visibility);
				// map.setLayoutProperty(`${p}_fill`, 'visibility', visibility);
			});
		}
	}

	$: {
		if (loaded) {
			const matchExp = ['match', ['get', 'GEOID']];
			census.features.forEach((f) => {
				matchExp.push(f.properties.GEOID, color(f, metric));
			});
			matchExp.push('rgba(0, 0, 0, 0)');
			map.setPaintProperty("census", "fill-color", matchExp);
		}
	}
</script>

<svelte:head>
	<link href="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.css" rel="stylesheet" />
	<script src="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.js"></script>
</svelte:head>

<div id="map" />

{#if loaded}
	<div class="controls">
		{#each plans as p}
			<label>
				<input type="radio" bind:group={plan} name="plans" value={p} />
				{planDesc(p)}
			</label>
		{/each}
	</div>
{/if}

<style>
	:global(body) {
		overflow: hidden;
	}

	#map {
		width: 100vw;
		height: 100vh;
	}

	.controls {
		position: fixed;
		top: 20px;
		left: 20px;
		background: #fff;
		z-index: 1;
		padding: 6px 10px;
		box-shadow: 0px 2px 5px #0006;
	}

	.controls label {
		display: block;
	}
</style>
