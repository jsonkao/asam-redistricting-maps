<script>
	import { onMount } from 'svelte';

	onMount(() => {
		mapboxgl.accessToken =
			'pk.eyJ1IjoiaGFvaGFvbTEiLCJhIjoiY2tlenMwMDdhMDh5dDJxcWk1MXRpNWdrcSJ9.WJ50sc0kycv1demj-0tlMQ';
		const map = new mapboxgl.Map({
			container: 'map', // container ID
			style: 'mapbox://styles/mapbox/light-v10', // style URL
			center: [-73.967, 40.758],
			zoom: 11 // starting zoom
		});

		map.on('load', async () => {
			const req = await fetch('/senate_letters.geojson');
			const data = await req.json();
			map.addSource('senate_letters', {
				type: 'geojson',
				data
			});
			map.addLayer({
				id: 'senate_letters',
				type: 'fill',
				source: 'senate_letters', // reference the data source
				paint: {
					'fill-color': '#0080ff', // blue color fill
					'fill-opacity': 0.2
				}
			});
			map.addLayer({
				id: 'outline',
				type: 'line',
				source: 'senate_letters',
				layout: {},
				paint: {
					'line-color': '#000',
					'line-width': 2
				}
			});
		});
	});
</script>

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
