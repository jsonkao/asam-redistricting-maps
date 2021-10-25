<script context="module">
	import { feature, neighbors } from 'topojson-client';

	/**
	 * A function that computes all constant data
	 */
	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const req = await fetch('/output.topojson');
		const topoData = await req.json();
		const obj = Object.values(topoData.objects)[0];
		const data = feature(topoData, obj).features;

		// Establish the static variables and the variables that change over time
		const dynamicVars = ['cvap', 'pop'];
		const staticVars = [
			...data.reduce((acc, val) => {
				const fields = Object.keys(val.properties)
					.filter(
						// District plans' fields are all uppercase
						(k) => [...dynamicVars, 'GEOID'].every((v) => !k.includes(v)) && k === k.toLowerCase()
					)
					.map((k) => k.split('_')[0]);
				return new Set([...acc, ...fields]);
			}, [])
		];

		return {
			props: {
				topoData,
				obj,
				data,
				neighbors: neighbors(obj.geometries),
				dynamicVars,
				staticVars
			}
		};
	}
</script>

<script>
	import { mesh } from 'topojson-client';
	import { geoPath } from 'd3-geo';
	import { schemeBlues } from 'd3-scale-chromatic';
	import ckmeans from 'ckmeans';
	import { pct } from '$lib/utils';

	export let topoData, obj, neighbors, data, dynamicVars, staticVars;

	const path = geoPath();
	const bgMesh = path(mesh(topoData, obj, (a, b) => a !== b));

	const getDistrict = (i) => data[i].properties.DISTRICT;
	function neighbor(i) {
		const selfD = getDistrict(i);
		const districts = new Set(neighbors[i].map(getDistrict).filter((d) => d !== selfD));
		if (districts.size === 1) {
			obj.geometries[i].properties.DISTRICT = districts.values().next().value;
			obj = obj;
		}
	}

	const colors = {
		black: '#9fd400',
		hispanic: '#ffaa00',
		asian: '#ff0000',
		white: '#73B2FF'
	}; // from Racial Dot Map, see https://github.com/unorthodox123/RacialDotMap/blob/master/dotmap.pde#L168
	const levels = ['66', '99', 'dd'];
	const groups = ['asian', 'black', 'hispanic', 'white'];

	let period = 'present';
	let variable = 'hhlang';
	$: metric = staticVars.includes(variable)
		? variable
		: variable + (period === 'past' ? 10 : variable === 'cvap' ? 19 : 20);

	const breaksCache = {};
	const isNum = (x) => !isNaN(x) && x !== null;
	$: getValue = {
		income: (d) => d[metric],
		hhlang: (d) => d[`${metric}_asian`] / d[`${metric}_total`],
		graduates: (d) => (d[`${metric}_hs_grad`] + d[`${metric}_ba_above`]) / d[`${metric}_total`],
		families: (d) => d[`${metric}_benefits`] / d[`${metric}_total`]
	}[metric];
	$: breaks =
		breaksCache[metric] ||
		!staticVars.includes(metric) || // Don't compute breaks for dynamic variables
		(breaksCache[metric] = ckmeans(data.map((f) => getValue(f.properties)).filter(isNum), 6));

	function color({ properties: d }) {
		const total = d[`${metric}_total`];

		if (staticVars.includes(metric)) {
			if (!isNum(getValue(d))) return '#ddd';
			for (let i = 1; i < breaks.length; i++) {
				if (getValue(d) < breaks[i]) return schemeBlues[breaks.length][i];
			}
			return schemeBlues[breaks.length][breaks.length - 1];
		} else {
			if (total <= 10) return '#fff';
			const p = (g) => d[`${metric}_${g}`] / d[`${metric}_total`];
			const majority = groups.filter((g) => p(g) > 0.5)[0];
			if (majority !== undefined) {
				return colors[majority] + levels[total < 100 ? 0 : total < 200 ? 1 : 2];
			}

			const pluralities = groups.sort((a, b) => p(b) - p(a));
			const distance = p(pluralities[0]) - p(pluralities[1]);
			return colors[pluralities[0]] + levels[distance < 0.093 ? 0 : 1]; // from R, see data/explore.R
		}
	}

	let yOffset = 0;

	const districtTarget = 'G';
	$: sums = [...groups, 'total'].reduce((acc, g) => {
		if (`pop20_${g}` in data[0].properties) {
			acc[g] = 0;
			obj.geometries.forEach(({ properties: d }) => {
				if (d.DISTRICT === districtTarget) acc[g] += d[`pop20_${g}`];
			});
		}
		return acc;
	}, {});

	$: console.log(sums);
</script>

<div class="container">
	<div class="controls">
		{#each [...staticVars, ...dynamicVars] as v, i}
			{#if i === staticVars.length} <br /> {/if}
			<label>
				<input type="radio" bind:group={variable} name="variable" value={v} />
				{v}
			</label>
		{/each}
		{#if dynamicVars.includes(variable)}
			<br />
			{#each ['past', 'present'] as p}
				<label>
					<input type="radio" bind:group={period} name="period" value={p} />
					{p}
				</label>
			{/each}

			<div class="legend">
				{#each groups as grp}
					<div class="row">
						{#each levels as lvl}
							<div class="rectangle" style="background-color: {colors[grp] + lvl}" />
						{/each}
						<p class="row-label">{grp}</p>
					</div>
				{/each}
			</div>
		{/if}

		<div class="stats">
			<p style="font-weight: 600">Senate District {districtTarget}</p>
			<p>Percent Asian: {pct(sums['asian'] / sums.total)}%</p>
			<p>Deviation: {sums.total - data[0].properties.IDEAL_VALU}</p>
		</div>
	</div>

	<svg width="800" viewBox="0 {yOffset} 975 {1040 - yOffset}">
		<g>
			{#each data as f, i (f.properties.GEOID)}
				<path
					class="block-group"
					d={path(f)}
					fill={color(f, metric, period)}
					on:click={() => neighbor(i)}
				/>
			{/each}
		</g>
		<g class="meshes">
			<path class="mesh-bg" d={bgMesh} />
			<path
				class="mesh-district"
				d={path(mesh(topoData, obj, (a, b) => a.properties.DISTRICT !== b.properties.DISTRICT))}
			/>
			<path
				class="mesh-target"
				d={path(
					mesh(
						topoData,
						obj,
						(a, b) =>
							(a.properties.DISTRICT === districtTarget ||
								b.properties.DISTRICT === districtTarget) &&
							a.properties.DISTRICT !== b.properties.DISTRICT
					)
				)}
			/>
		</g>
	</svg>
</div>

<style>
	.container {
		margin: 0 auto;
		font-family: Overpass;
	}

	.controls {
		position: sticky;
		top: 5px;
		left: 5px;
		pointer-events: none;
	}

	.controls > * {
		pointer-events: all;
	}

	.stats {
		/* box-shadow: 0px 2px 4px rgba(0,0,0,0.3);
		background: #fff;
		margin: 5px;
		padding: 6px;
		display: inline-block; */
		pointer-events: none;
	}

	svg {
		margin: 20px auto 0;
		display: block;
	}

	.meshes path {
		fill: none;
		stroke-linejoin: round;
	}

	.mesh-bg {
		stroke: #fff;
		stroke-width: 0.2;
	}
	.mesh-district {
		stroke: black;
		stroke-width: 0.5;
	}
	.mesh-target {
		stroke: black;
		stroke-width: 1.5;
	}

	.block-group {
		transition-duration: 0.2s;
	}

	.legend {
		pointer-events: none;
	}

	.row {
		display: flex;
		align-items: center;
	}

	.row-label {
		margin-left: 5px;
	}

	.rectangle {
		width: 50px;
		height: 15px;
	}
</style>
