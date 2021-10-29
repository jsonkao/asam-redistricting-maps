<script context="module">
	export async function load({ fetch }) {
		const req = await fetch('/plans.topojson');
		return { props: { topoData: await req.json() } };
	}
</script>

<script>
	import { feature } from 'topojson-client';
	import { onMount } from 'svelte';
	import { planDesc } from '$lib/utils';

	export let topoData;

	let map, loaded;

	const plans = [
		'assembly',
		'assembly_letters',
		'assembly_names',
		'senate',
		'senate_letters',
		'senate_names'
	];

	onMount(() => {
		mapboxgl.accessToken =
			'pk.eyJ1IjoiaGFvaGFvbTEiLCJhIjoiY2tlenMwMDdhMDh5dDJxcWk1MXRpNWdrcSJ9.WJ50sc0kycv1demj-0tlMQ';
		map = new mapboxgl.Map({
			container: 'map', // container ID
			style: 'mapbox://styles/mapbox/light-v10', // style URL
			center: [-73.967, 40.72],
			zoom: 12 // starting zoom
		});

		map.on('load', async () => {
			plans.forEach((k) => {
				const data = feature(topoData, topoData.objects[k]);
				map.addSource(k, {
					type: 'geojson',
					data
				});
				map.addLayer({
					id: k + '_fill',
					type: 'fill',
					source: k, // reference the data source
					paint: {
						'fill-color': '#0080ff', // blue color fill
						'fill-opacity': 0.1
					}
				});
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
				map.on('click', k + '_fill', (e) => {
					new mapboxgl.Popup().setLngLat(e.lngLat).setHTML(e.features[0].properties[k]).addTo(map);
				});
			});
			loaded = true;
		});
	});

	let plan = plans[0];

	$: {
		if (loaded) {
			plans.forEach((p) => {
				const visibility = p === plan ? 'visible' : 'none';
				map.setLayoutProperty(`${p}_fill`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_outline`, 'visibility', visibility);
				console.log(p, visibility);
			});
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
