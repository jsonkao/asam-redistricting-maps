<script>
	import { feature } from 'topojson-client';
	import { onMount } from 'svelte';

	let map, loaded;

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
			const req = await fetch('/senate_letters.topojson');
			const topoData = await req.json();
			const data = feature(topoData, topoData.objects.senate_letters);
			map.addSource('senate_letters', {
				type: 'geojson',
				data
			});
			map.addLayer({
				id: 'senate_letters_fill',
				type: 'fill',
				source: 'senate_letters', // reference the data source
				paint: {
					'fill-color': '#0080ff', // blue color fill
					'fill-opacity': 0.1
				}
			});
			map.addLayer({
				id: 'senate_letters_outline',
				type: 'line',
				source: 'senate_letters',
				layout: {},
				paint: {
					'line-color': '#000',
					'line-width': 1
				}
			});
			map.on('click', 'senate_letters_fill', (e) => {
				new mapboxgl.Popup().setLngLat(e.lngLat).setHTML(e.features[0].properties.DISTRICT).addTo(map);
			});
			loaded = true;
		});
	});

	let showSenate = true;

	$: {
		if (loaded) {
			map.setLayoutProperty(
				'senate_letters_outline',
				'visibility',
				showSenate ? 'visible' : 'none'
			);
			map.setLayoutProperty('senate_letters_fill', 'visibility', showSenate ? 'visible' : 'none');
		}
	}
</script>

<div id="map" />

{#if loaded}
	<div class="controls">
		<label>
			<input type="checkbox" bind:checked={showSenate} />
			Senate Letters plan
		</label>
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
</style>
