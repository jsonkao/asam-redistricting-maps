<script>
  import { feature } from 'topojson-client';
	import { onMount } from 'svelte';
	import { planDesc } from '$lib/utils';

	export let viewBox,
		census,
		plansTopo,
		labelSize,
		draggedBgs,
		data,
		path,
		color,
		changingLines,
		neighbor,
		showPluralities,
		metric,
		period,
		tractVars,
		drawings,
		panels,
		plan,
		// points = [],
		tractMesh,
		bgMesh,
		mesh,
		aggregates,
		obj,
		handleLabelClick,
		congressPlans,
		// plans,
		startDrag,
		endDrag,
		handleMouseMove,
		viewCutoff,
		showOnlyFocusDistricts,
		showStreets,
		presentationMode,
		streets;

	let map, loaded;

	const allPlans = [
		'assembly',
		'assembly_letters',
		'assembly_names',
		'assembly_unity',
		'senate',
		'senate_letters',
		'senate_names',
		'senate_unity'
	];

	onMount(() => {
		mapboxgl.accessToken =
			'pk.eyJ1IjoianNvbmthbyIsImEiOiJjanNvM2U4bXQwN2I3NDRydXQ3Z2kwbWQwIn0.JWAoBlcpDJwkzG-O5_r0ZA';
		map = new mapboxgl.Map({
			container: 'map',
			style: 'mapbox://styles/jsonkao/ckvnu5tpy6coj14uizvyf1wuf/draft',
			center: [-73.967, 40.72],
			zoom: 12
		});

		map.on('load', async () => {
			map.addSource('census', { type: 'geojson', data: census });
			const matchExp = ['match', ['get', 'GEOID']];
			census.features.forEach((f) => {
				matchExp.push(f.properties.GEOID, color(f, metric, period, showPluralities));
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

			allPlans.forEach((k) => {
				const data = feature(plansTopo, plansTopo.objects[k]);
				map.addSource(k, {
					type: 'geojson',
					data
				}); /*
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
				}); /*
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

	$: console.log(census);

	$: {
		if (loaded) {
			allPlans.forEach((p) => {
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
				matchExp.push(f.properties.GEOID, color(f, metric, period, showPluralities));
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

<style>
	:global(body) {
		overflow: hidden;
	}

	#map {
		width: 100vw;
		height: 100vh;
	}
</style>
