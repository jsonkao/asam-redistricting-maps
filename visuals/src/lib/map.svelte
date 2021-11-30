<script>
	import { feature } from 'topojson-client';
	import { onMount } from 'svelte';
	import { hexToRGB } from '$lib/utils';

	export let viewBox,
		census,
		plansTopo,
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
		plan2,
		points,
		pointing,
		tractMesh,
		bgMesh,
		mesh,
		aggregates,
		obj,
		handleLabelClick,
		congressPlans,
		togglePointing,
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

	function getCensusFills() {
		if (metric === null) return 'rgba(0, 0, 0, 0)';
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
			zoom: 12
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

			allPlans.forEach((k) => {
				const data = feature(plansTopo, plansTopo.objects[k]);
				map.addSource(k, {
					type: 'geojson',
					data: {
						type: 'FeatureCollection',
						features: data.features.map((f) => ({ ...f, id: f.properties[k] }))
					}
				});
				map.addLayer(
					{
						id: k + '_outline',
						type: 'line',
						source: k,
						layout: {},
						paint: {
							'line-color': '#121212',
							'line-width': [
								'case',
								['boolean', ['feature-state', 'pointing'], false],
								5,
								2,
							]
						}
					},
					'road-label-small'
				);
				map.addLayer({
					id: k + '_fill',
					type: 'fill',
					source: k,
					layout: {},
					paint: {
						'fill-color': '#000000',
						'fill-opacity': 0
					}
				});
				map.addSource(k + '_labels', {
					type: 'geojson',
					data: {
						type: 'FeatureCollection',
						features: points.features.filter((p) => p.properties[k])
					}
				});
				map.addLayer({
					id: k + '_labels',
					type: 'symbol',
					source: k + '_labels',
					layout: {
						'text-justify': 'auto',
						'text-field': ['format', ['get', k], { 'font-scale': 1.35 }]
					},
					paint: {
						'text-color': '#121212',
						'text-halo-color': '#fff',
						'text-halo-width': 1.2
					}
				});
			});
			loaded = true;

			map.on('click', (e) => {
				if (!pointing) return;
				togglePointing();
				const features = map
					.queryRenderedFeatures(e.point)
					.filter((f) => allPlans.some((p) => p === f.source));
				features.forEach((f) => {
					map.setFeatureState({ source: f.source, id: f.properties[f.source] }, { pointing: true });
				});
				console.log(features);
			});
		});
	});

	$: {
		if (loaded) {
			allPlans.forEach((p) => {
				const isPlan2 = panels.includes('plan2') && p === plan2;
				const visibility = p === plan || isPlan2 ? 'visible' : 'none';
				map.setLayoutProperty(`${p}_outline`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_fill`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_labels`, 'visibility', visibility);

				const color = isPlan2 ? '#8856a7' : '#121212';
				map.setPaintProperty(`${p}_outline`, 'line-color', color);
				map.setPaintProperty(`${p}_labels`, 'text-color', color);
			});
		}
	}

	$: {
		if (loaded) {
			map.getCanvas().style.cursor = pointing ? 'crosshair' : 'pointer';
		}
	}

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
