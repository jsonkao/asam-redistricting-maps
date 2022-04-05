<script>
	import { feature } from 'topojson-client';
	import { onMount } from 'svelte';
	import { hexToRGB } from '$lib/utils';

	export let census,
		plansTopo,
		color,
		showPluralities,
		metric,
		period,
		panels,
		plan,
		plan2,
		points,
		isolate,
		pointing,
		opacity,
		handleLabelClick,
		togglePointing;

	let map, loaded;

	const allPlans = [
		'assembly',
		'assembly_letters',
		'assembly_names',
		'assembly_unity',
		'assembly_latfor',
		'senate',
		'senate_letters',
		'senate_names',
		'senate_unity',
		'senate_latfor'
	];

	function getCensusFills() {
		if (metric === null) return 'rgba(0, 0, 0, 0)';
		const matchExp = ['match', ['get', 'GEOID']];
		census.features.forEach((f) => {
			matchExp.push(f.properties.GEOID, color(f));
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
			style: 'mapbox://styles/jsonkao/cl1f4e52k000t15p9pvoqwiwl/draft',
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

			const plansGeojsons = {};
			allPlans.forEach((k) => {
				const data = feature(plansTopo, plansTopo.objects[k]);
				plansGeojsons[k] = {
					type: 'FeatureCollection',
					features: data.features.map((f) => {
						return { ...f, id: f.properties[k] };
					})
				};
			});

			allPlans.forEach((k) => {
				map.addSource(k, {
					type: 'geojson',
					data: plansGeojsons[k],
					promoteId: k
				});
				map.addLayer(
					{
						id: k + '_outline',
						type: 'line',
						source: k,
						layout: {},
						paint: {
							'line-color': '#e2c169',
							'line-width': defaultLineWidth
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
						features: points.features
							.filter((p) => p.properties[k])
							.map((f) => ({
								type: f.feature,
								id: f.properties[k],
								geometry: f.geometry,
								properties: f.properties
							}))
					}
				});
				map.addLayer({
					id: k + '_labels',
					type: 'symbol',
					source: k + '_labels',
					layout: {
						'text-justify': 'auto',
						'text-allow-overlap': true,
						'text-variable-anchor': [
							'center',
							'left',
							'right',
							'top',
							'bottom',
							'top-left',
							'top-right',
							'bottom-left',
							'bottom-right'
						],
						'text-radial-offset': 1,
						'text-field': ['format', ['get', k], { 'font-scale': 1.2 }] /*
						'text-font': [
							'case',
							['boolean', ['feature-state', 'pointing'], false],
							['Arial Unicode MS Bold',],
							['Arial Unicode MS Regular'],
						] */
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
				if (pointing) {
					togglePointing();
					const features = map
						.queryRenderedFeatures(e.point)
						.filter((f) => allPlans.some((p) => p === f.source));
					pointingOn = features.map((f) => {
						map.setFeatureState(
							{ source: f.source, id: f.properties[f.source] },
							{ pointing: true }
						);
						/* map.setFeatureState(
							{ source: f.source + '_labels', id: f.properties[f.source] },
							{ pointing: true }
						); */
						handleLabelClick(`${f.source},${f.properties[f.source]}`, true);
						return { source: f.source, id: f.properties[f.source] };
					});
				} else {
					const features = map
						.queryRenderedFeatures(e.point)
						.filter((f) => f.source.endsWith('_labels'));
					features.forEach((f) => {
						const scope_proposal = f.source.replace('_labels', '');
						const feature = { source: scope_proposal, id: f.properties[scope_proposal] };
						map.setFeatureState(
							feature,
							{ pointing: !map.getFeatureState(feature).pointing }
						);
						handleLabelClick(`${scope_proposal},${f.properties[scope_proposal]}`);
					});
				}
			});
		});
	});

	let pointingOn = [];

	$: {
		if (loaded) {
			allPlans.forEach((p) => {
				const isPlan2 = panels.includes('plan2') && p === plan2;
				const visibility = (panels.includes('plan') && p === plan) || isPlan2 ? 'visible' : 'none';
				map.setLayoutProperty(`${p}_outline`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_fill`, 'visibility', visibility);
				map.setLayoutProperty(`${p}_labels`, 'visibility', visibility);

				const color = '#e2c169' // isPlan2 ? /* '#8856a7' */ '#121212' : '#121212';
				map.setPaintProperty(`${p}_outline`, 'line-color', color);
				map.setPaintProperty(`${p}_labels`, 'text-color', '#121212');
			});
		}
	}

	$: {
		if (loaded) {
			map.getCanvas().style.cursor = pointing ? 'crosshair' : 'pointer';

			if (pointing && pointingOn.length > 0) {
				pointingOn.forEach((fs) => {
					map.setFeatureState(fs, { pointing: false });
					// map.setFeatureState({ source: fs.source + '_labels', id: fs.id }, { pointing: false });
					handleLabelClick(`${fs.source},${fs.id}`, false, true);
				});
			}
		}
	}

	$: {
		if (loaded) {
			if (panels.includes('plan2')) {
				let cap = (x) => Math.max(0, Math.min(x, 1));
				const maxSum = 1; // 1.5;
				map.setPaintProperty(`${plan}_outline`, 'line-opacity', cap(maxSum - opacity));
				map.setPaintProperty(`${plan2}_outline`, 'line-opacity', cap(opacity));

				cap = (x) => {
					return Math.max(0, Math.min(x, 1));
					if (x > 0.6 && x < 0.8) return 1;
					return x < 0.35 ? 0.35 : x > 0.75 ? 1 : x;
				};
				map.setPaintProperty(`${plan}_labels`, 'text-opacity', cap(maxSum - opacity));
				map.setPaintProperty(`${plan2}_labels`, 'text-opacity', cap(opacity));
			} else {
				map.setPaintProperty(`${plan}_outline`, 'line-opacity', 1);
				map.setPaintProperty(`${plan2}_outline`, 'line-opacity', 1);
				map.setPaintProperty(`${plan}_labels`, 'text-opacity', 1);
				map.setPaintProperty(`${plan2}_labels`, 'text-opacity', 1);
			}
		}
	}

	$: {
		if (loaded) {
			const applicablePlans = [plan];
			if (panels.includes('plan2')) applicablePlans.push(plan2);
			applicablePlans.forEach((p) => {
				map.setPaintProperty(
					`${p}_outline`,
					'line-width',
					isolate
						? ['case', ['boolean', ['feature-state', 'pointing'], false], 2, 0]
						: defaultLineWidth
				);
			});
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
