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
	import { slide, fade } from 'svelte/transition';
	import { pct, capitalize } from '$lib/utils';

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
		white: '#73B2FF',
		missing: '#ddd'
	}; // from Racial Dot Map, see https://github.com/unorthodox123/RacialDotMap/blob/master/dotmap.pde#L168
	const levels = ['66', '99', 'dd'];
	const groups = ['asian', 'black', 'hispanic', 'white'];

	let period = 'present';
	let variable = 'pop';
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
		!staticVars.includes(metric) ||
		metric === 'asiaentry' || // Don't compute breaks for dynamic variables
		(breaksCache[metric] = ckmeans(data.map((f) => getValue(f.properties)).filter(isNum), 6));

	function color({ properties: d }) {
		const total = d[`${metric}_total`];

		if (metric === 'asiaentry') {
			const periods = ['1990_earlier', '1990_1999', '2000_2009', '2010_later'];
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return colors.missing;
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[5][periods.indexOf(pluralities[0]) + 1];
		} else if (staticVars.includes(metric)) {
			if (!isNum(getValue(d))) return colors.missing;
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
	$: delta = sums.total - data[0].properties.IDEAL_VALU;

	$: console.log(sums);

	const variablesLong = {
		hhlang: 'Proportion of households that speak an Asian language and are LEP',
		income: 'Median household income',
		graduates: 'Proportion of people who graduated >= high school',
		families: "Proportion of families who receive gov't benefits",
		asiaentry: 'Dominant entry period for Asian families',
		cvap: 'Citizen voting age population by race',
		pop: 'Population by race'
	};

	let showStats = false;
	let showPlans = false;
	let showSenatePlans = false;
</script>

<div class="container">
	<div class="controls">
		<select bind:value={variable}>
			<optgroup label="Redistricting data">
				{#each dynamicVars as v}
					<option value={v}>{variablesLong[v] || v}</option>
				{/each}
			</optgroup>
			<optgroup label="American Community Survey data">
				{#each staticVars as v}
					<option value={v}>{variablesLong[v] || v}</option>
				{/each}
			</optgroup>
		</select>

		{#if dynamicVars.includes(variable)}
			<br />
			{#each ['past', 'present'] as p}
				<label>
					<input type="radio" bind:group={period} name="period" value={p} />
					{capitalize(p)}
				</label>
			{/each}

			<div class="legend">
				{#each groups as grp}
					{#each levels as lvl}
						<div style="background-color: {colors[grp] + lvl}" />
					{/each}
					<p class="row-label">{capitalize(grp)}</p>
				{/each}
				<p class="col-head"><span>Weak plurality</span></p>
				<p class="col-head" />
				<p class="col-head">Majority</p>
				<p class="col-head" />
			</div>
		{/if}

		<div class="stats">
			<h3 on:click={() => (showStats = !showStats)}>Redistricting ↓</h3>
			{#if showStats}
				<div in:slide out:slide>
					<p style="text-decoration: underline">Senate District {districtTarget}</p>
					<p>{pct(sums['asian'] / sums.total)}% Asian</p>
					<p>{Math.abs(delta).toLocaleString()} people {delta >= 0 ? 'above' : 'below'}</p>
				</div>
			{/if}
		</div>

		<div class="stats">
			<h3 on:click={() => (showPlans = !showPlans)}>Plans ↓</h3>
			{#if showPlans}
				<div in:slide out:slide>
					<label>
						<input type="checkbox" bind:checked={showSenatePlans} />
						State Senate "Letters" Plan
					</label>
				</div>
			{/if}
		</div>
	</div>

	<svg width="1000" viewBox="0 {yOffset} 975 {1040 - yOffset}">
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
			{#if showSenatePlans}
				<g in:fade out:fade>
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
			{/if}
		</g>
	</svg>
</div>

<style>
	.container {
		margin: 0 auto;
		font-family: Overpass;
		--control-width: 270px;
	}

	select {
		font-family: Overpass;
		font-size: 16px;
		padding: 3px;
		margin-bottom: 5px;
		width: var(--control-width);
	}

	.controls {
		position: sticky;
		max-width: var(--control-width);
		top: 15px;
		padding-left: 15px;
		height: 400px;
	}

	.stats div {
		margin-bottom: 20px;
	}

	.stats h3 {
		font-size: 16px;
		margin-bottom: 4px;
		cursor: pointer;
	}

	.stats p {
		line-height: 1.25;
	}

	svg {
		margin: 20px 0 0 var(--control-width);
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
		margin: 20px 0;
		display: grid;
		grid-template-columns: repeat(3, 50px) 1fr;
		row-gap: 9px;
		grid-template-rows: repeat(5, 14px);
	}

	.row-label {
		line-height: 1;
		margin-left: 5px;
	}

	.col-head {
		text-transform: uppercase;
		font-size: 10.5px;
		line-height: 1.1;
		margin-top: -3px;
	}
</style>
