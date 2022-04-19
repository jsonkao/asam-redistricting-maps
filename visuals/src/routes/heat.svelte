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
	let metric = 'tree';

	function color({ properties: d }) {
		/* const colors = [
			'#d73027',
			'#f46d43',
			'#fdae61',
			'#fee08b',
			'#d9ef8b',
			'#a6d96a',
			'#66bd63',
			'#1a9850'
		]; */
		if (!d[year]) return 'rgba(0, 0, 0, 0)';
		const colors = [
			'#22e4e5',
			'#67ecec',
			'#aef4f3',
			'#f3f3af',
			'#eded66',
			'#e5e521',
			'#2fb0e6',
			'#6ab0ed',
			'#b2b0f4',
			'#f4afb1',
			'#edaf6a',
			'#e7b02a',
			'#386ae7',
			'#6f69ed',
			'#b368ec',
			'#ed67b1',
			'#ee686c',
			'#e96932',
			'#3b2de5',
			'#702be5',
			'#b427e6',
			'#e525b2',
			'#e6286c',
			'#e72934'
		].map(hexToRGB);
		const cutoffs = {
			'1990': [-0.88, -0.54, -0.26, 0.03, 0.84, 1.97, 2.68, 3.86],
			'2000': [-2.69, -1.62, -0.85, -0.27, 0.24, 0.76, 1.4, 5.23],
			'2010': [-2.37, -1.43, -0.77, -0.22, 0.28, 0.78, 1.36, 4.9],
			'1990': [56.59, 58.93, 60.82, 62.82, 68.38, 76.16, 81.03, 89.09],
			'2000': [71.37, 75.14, 77.88, 79.95, 81.76, 83.59, 85.89, 99.54],
			'2010': [78.96, 82.16, 84.39, 86.24, 87.96, 89.67, 91.64, 103.63],
			'1990': [58.29, 60.6, 62.77, 71.22, 80.85, 89.09],
			'2000': [75.14, 78.58, 80.94, 83.03, 85.42, 99.54],
			'2010': [82.87, 85.3, 87.27, 89.13, 91.09, 103.63],
			tree: [0.04278385197645081, 0.14645235069885643, 0.35050369685767097, 0.8286626506024096],
			income: [49896.0, 78194.0, 120580.0, 250001.0]
		};
		let y, m;
		for (y = 0; y < cutoffs[year].length; y++) {
			if (d[year] <= cutoffs[year][y]) break;
		}
		if (metric === 'None') {
			m = 0;
		} else {
			for (m = 0; m < cutoffs[metric].length; m++) {
				if (d[metric] <= cutoffs[metric][m]) break;
			}
		}
		return colors[Math.min(y + m * 6, 23)];
	}

	function getCensusFills() {
		const matchExp = ['match', ['get', 'GEOID']];
		census.features.forEach((f) => {
			matchExp.push(f.properties.GEOID, color(f));
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
			map.setPaintProperty('census', 'fill-color', getCensusFills(year, metric));
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
		<select bind:value={metric}>
			{#each ['None', 'tree', 'income'] as m}
				<option value={m}>{m}</option>
			{/each}
		</select>

		<div id="legend-container">
			<div id="x-axis-labels" style="height: 210px">
				<p class="halo">Hotter</p>
				<p class="halo">Colder</p>
			</div>
			<div id="x-axis" style="height: 240px; width: 16px;">
				<svg viewBox="-8 0 16 240">
					<defs>
						<marker
							id="arrowhead"
							markerWidth="10"
							markerHeight="6"
							refX="0"
							refY="3"
							orient="auto"
						>
							<polygon points="0 0, 6 3, 0 6" />
						</marker>
					</defs>
					<line x1="0" y1="120" x2="0" y2="16" marker-end="url(#arrowhead)" />
					<line x1="0" y1="120" x2="0" y2="224" marker-end="url(#arrowhead)" />
				</svg>
			</div>
			<div id="legend">
				<div
					id="legend-temp"
					style="position: absolute;
				width: 100%;
				height: 100%;
				mix-blend-mode: darken;background: linear-gradient(0deg, rgb(34, 229, 229) 0%, rgb(34, 229, 229) 16.6667%, rgb(102, 236, 236) 16.6667%, rgb(102, 236, 236) 33.3333%, rgb(174, 243, 243) 33.3333%, rgb(174, 243, 243) 50%, rgb(243, 243, 174) 50%, rgb(243, 243, 174) 66.6667%, rgb(236, 236, 102) 66.6667%, rgb(236, 236, 102) 83.3333%, rgb(229, 229, 34) 83.3333%, rgb(229, 229, 34) 100%);"
				>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
					<div style="height: 30px;">
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
						<div style="width: 30px; height: 30px;" class="" />
					</div>
				</div>
				<div
					id="legend-imp"
					style="background: linear-gradient(90deg, rgb(250, 250, 250) 0%, rgb(250, 250, 250) 25%, rgb(243, 174, 243) 25%, rgb(243, 174, 243) 50%, rgb(236, 102, 236) 50%, rgb(236, 102, 236) 75%, rgb(229, 34, 229) 75%, rgb(229, 34, 229) 100%);"
				/>
			</div>
			<div id="y-axis" class="visible" style="color: #d73027;">
				<svg viewBox="0 0 160 16">
					<defs>
						<marker
							id="arrowhead"
							markerWidth="10"
							markerHeight="6"
							refX="0"
							refY="3"
							orient="auto"
						>
							<polygon points="0 0, 6 3, 0 6" />
						</marker>
					</defs>
					<line x1="0" y1="8" x2="151" y2="8" marker-end="url(#arrowhead)" />
				</svg>
			</div>
			<div id="y-axis-label"><p class="halo">{metric}</p></div>
		</div>
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
		z-index: 1;
		/* background: #fff;
		box-shadow: 0px 2px 5px #0006; */
	}

	#map {
		width: 100vw;
		height: 100vh;
	}

	#legend-container {
		padding: 6px;
		display: grid;
		grid-template-columns: repeat(3, auto);
		grid-template-rows: repeat(3, auto);
	}

	#x-axis-labels {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		align-self: center;
	}

	#x-axis-labels p {
		padding: 0;
		text-align: right;
	}

	#x-axis {
		margin-right: 9px;
	}

	#y-axis {
		grid-column: 3;
		grid-row: 2;
		margin-top: 9px;
		transition-duration: 0.3s;
	}

	#y-axis-label {
		grid-column: 3;
		grid-row: 3;
		transition-duration: 0.3s;
	}
	#legend-temp {
		box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.5);
		display: flex;
		flex-direction: column-reverse;
	}

	#legend-temp > div > div {
		display: inline-block;
		box-sizing: border-box;
	}

	#legend > div {
		position: absolute;
		width: 100%;
		height: 100%;
		mix-blend-mode: darken;
	}

	#legend {
		width: 160px;
		height: 240px;
		position: relative;
	}

	line {
		stroke-width: 1.5px;
		stroke: #121212;
	}
</style>
