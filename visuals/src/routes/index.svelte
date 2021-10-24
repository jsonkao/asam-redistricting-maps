<script context="module">
	export async function load({ fetch }) {
		const data = await fetch('/census.topojson');
		return {
			props: {
				topoData: await data.json()
			}
		};
	}
</script>

<script>
	import { feature, mesh } from 'topojson-client';
	import { geoPath } from 'd3-geo';

	export let topoData;

	const data = feature(topoData, topoData.objects.census);
	const dataMesh = mesh(topoData, topoData.objects.census, (a, b) => a !== b);
	const outline = mesh(topoData, topoData.objects.census, (a, b) => a === b);
	const path = geoPath();

	const colors = {
		black: '#9fd400',
		hispanic: '#ffaa00',
		asian: '#ff0000',
		white: '#73B2FF'
	}; // from Racial Dot Map, see https://github.com/unorthodox123/RacialDotMap/blob/master/dotmap.pde#L168
	const levels = ['66', '99', 'dd'];

	const groups = ['asian', 'black', 'hispanic', 'white'];

	function color({ properties: d }, year) {
		const total = d[`cvap${year}_total`];
		if (total <= 10) return '#fff';

		const p = (x) => d[`prop${year}_${x}`];
		const majority = groups.filter((g) => p(g) > 0.5)[0];
		if (majority !== undefined) {
			return colors[majority] + levels[total < 100 ? 0 : total < 200 ? 1 : 2];
		}

		const pluralities = groups.sort((a, b) => p(b) - p(a));
		const distance = p(pluralities[0]) - p(pluralities[1]);
		return colors[pluralities[0]] + levels[distance < 0.093 ? 0 : 1]; // from R, see data/explore.R
	}

	let year = 19;

	let yOffset = 0;
</script>

<div class="container">
	{#each [10, 19] as y}
		<label>
			<input type="radio" bind:group={year} name="year" value={y} />
			{2000 + y}
		</label>
	{/each}

	<div class="legend">
		{#each groups as grp}
			<div class="row">
				{#each levels as lvl}
					<div class="rectangle" style="background-color: {colors[grp] + lvl}" />
				{/each}
			</div>
		{/each}
	</div>

	<div>
		<svg width="700" viewBox="0 {yOffset} 975 {1040 - yOffset}">
			<g>
				{#each data.features as f}
					<path class="block-group" d={path(f)} fill={color(f, year)} />
				{/each}
			</g>
			<g>
				<path class="mesh" d={path(dataMesh)} />
			</g>
			<g>
				<path style="stroke: #bbb; stroke-width: .6; fill: none;" d={path(outline)} />
			</g>
		</svg>
	</div>
</div>

<style>
	.container {
		margin: 0 auto;
		font-family: Overpass;
	}

	svg {
		margin-top: 20px;
	}

	.mesh {
		fill: none;
		stroke: #fff;
		stroke-width: 0.2;
		stroke-linejoin: round;
	}

	.block-group {
		transition-duration: 0.3s;
	}

	.row {
		margin-bottom: 8px;
		display: flex;
	}

	.rectangle {
		width: 50px;
		height: 15px;
	}
</style>
