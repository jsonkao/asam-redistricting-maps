<script context="module">
	export async function load({ fetch }) {
		const data = await fetch('/output.topojson');
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

	const obj = Object.values(topoData.objects)[0];
	const data = feature(topoData, obj).features;
	const path = geoPath();

	const colors = {
		black: '#9fd400',
		hispanic: '#ffaa00',
		asian: '#ff0000',
		white: '#73B2FF'
	}; // from Racial Dot Map, see https://github.com/unorthodox123/RacialDotMap/blob/master/dotmap.pde#L168
	const levels = ['66', '99', 'dd'];

	const groups = ['asian', 'black', 'hispanic', 'white'];

	let period = 'past';
	let metric = 'cvap';
	$: year = period === 'past' ? 10 : metric === 'cvap' ? 19 : 20;

	function color({ properties: d }) {
		const total = d[`${metric}${year}_total`];
		if (total <= 10) return '#fff';

		const p = (g) =>
			metric === 'cvap'
				? d[`prop${year}_${g}`]
				: d[`${metric}${year}_${g}`] / d[`${metric}${year}_total`];

		const majority = groups.filter((g) => p(g) > 0.5)[0];
		if (majority !== undefined) {
			return colors[majority] + levels[total < 100 ? 0 : total < 200 ? 1 : 2];
		}

		const pluralities = groups.sort((a, b) => p(b) - p(a));
		const distance = p(pluralities[0]) - p(pluralities[1]);
		return colors[pluralities[0]] + levels[distance < 0.093 ? 0 : 1]; // from R, see data/explore.R
	}

	let yOffset = 0;

	$: sums = [...groups, 'total'].reduce((acc, g) => {
		acc[g] = 0;
		data.forEach(({ properties: d }) => {
			if (d.DISTRICT === 'G') acc[g] += d[`${metric}${year}_${g}`];
		});
		return acc;
	}, {});
</script>

<div class="container">
	<div class="controls">
		{#each ['past', 'present'] as p}
			<label>
				<input type="radio" bind:group={period} name="period" value={p} />
				{p}
			</label>
		{/each}
		<br />
		{#each ['cvap', 'pop'] as m}
			<label>
				<input type="radio" bind:group={metric} name="metric" value={m} />
				{m}
			</label>
		{/each}
	</div>

	<div class="map-container">
		<svg width="600" viewBox="0 {yOffset} 975 {1040 - yOffset}">
			<g>
				{#each data as f}
					<path class="block-group" d={path(f)} fill={color(f, metric, year)} />
				{/each}
			</g>
			<g class="meshes">
				<path class="mesh" d={path(mesh(topoData, obj, (a, b) => a !== b))} />
				<path
					style="stroke: #bbb; stroke-width: .6;"
					d={path(mesh(topoData, obj, (a, b) => a === b))}
				/>
				<path
					style="stroke: black;"
					d={path(mesh(topoData, obj, (a, b) => a.properties.DISTRICT !== b.properties.DISTRICT))}
				/>
			</g>
		</svg>
	</div>

	<p style="margin: 0;">asian pct: {Math.round(sums['asian'] / sums.total * 1e4) / 1e2}%</p>

	<div class="legend">
		{#each groups as grp}
			<div class="row">
				{#each levels as lvl}
					<div class="rectangle" style="background-color: {colors[grp] + lvl}" />
				{/each}
			</div>
		{/each}
	</div>
</div>

<style>
	.container {
		margin: 0 auto;
		font-family: Overpass;
	}

	.controls {
		position: absolute;
		top: 5px;
		left: 5px;
	}

	svg {
		margin-top: 20px;
	}

	.meshes path {
		fill: none;
		stroke-linejoin: round;
	}

	.mesh {
		stroke: #fff;
		stroke-width: 0.2;
	}

	.block-group {
		transition-duration: 0.2s;
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
