<script context="module">
	import { feature, neighbors as topoNeighbors } from 'topojson-client';

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
				neighbors: topoNeighbors(obj.geometries),
				dynamicVars,
				staticVars,
				tractVars: ['asiaentry', 'workers'],
				pluralityVars: ['asiaentry'] // Aside from race
			}
		};
	}
</script>

<script>
	import { mesh as topoMesh } from 'topojson-client';
	import { geoPath } from 'd3-geo';
	import { schemeBlues } from 'd3-scale-chromatic';
	import ckmeans from 'ckmeans';
	import { slide, fade } from 'svelte/transition';
	import { onMount, onDestroy } from 'svelte';
	import * as concaveman from 'concaveman';
	import pointInPolygon from 'point-in-polygon';
	import { pct, capitalize, money, isNum, id, district, xor } from '$lib/utils';
	import { colors, levels, groups, periods, variablesLong } from '$lib/constants';
	import { polygonCentroid } from 'd3-polygon';

	export let topoData, obj, neighbors, data, dynamicVars, staticVars, tractVars, pluralityVars;

	const path = geoPath();
	const mesh = (filterFn) => topoMesh(topoData, obj, filterFn);
	const bgMesh = path(mesh((a, b) => id(a) !== id(b)));
	const tractMesh = path(mesh((a, b) => id(a).substring(0, 11) !== id(b).substring(0, 11)));

	const getDistrict = (i) => data[i].properties.DISTRICT;
	function neighbor(i) {
		const selfD = getDistrict(i);
		const districts = new Set(neighbors[i].map(getDistrict).filter((d) => d !== selfD));
		if (districts.size === 1) {
			obj.geometries[i].properties.DISTRICT = districts.values().next().value;
			obj = obj;
		}
	}

	let period = 'past';
	let variable = 'pop';
	$: metric = staticVars.includes(variable)
		? variable
		: variable + (period === 'past' ? 10 : variable === 'cvap' ? 19 : 20);

	const breaksCache = {};
	$: getValue = {
		income: (d) => d[metric],
		hhlang: (d) => d[`${metric}_asian`] / d[`${metric}_total`],
		graduates: (d) => (d[`${metric}_hs_grad`] + d[`${metric}_ba_above`]) / d[`${metric}_total`],
		families: (d) => d[`${metric}_benefits`] / d[`${metric}_total`],
		workers: (d) => d[`${metric}_publictransport`] / d[`${metric}_total`]
	}[metric];
	$: breaks =
		breaksCache[metric] ||
		!staticVars.includes(metric) ||
		metric === 'asiaentry' || // Don't compute breaks for dynamic and tract variables
		(breaksCache[metric] = ckmeans(data.map((f) => getValue(f.properties)).filter(isNum), 6));

	function color({ properties: d }) {
		const total = d[`${metric}_total`];

		if (pluralityVars.includes(metric)) {
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return '#ddd';
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[periods.length][periods.indexOf(pluralities[0])];
		} else if (staticVars.includes(metric)) {
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

			const pluralities = [...groups].sort((a, b) => p(b) - p(a));
			const distance = p(pluralities[0]) - p(pluralities[1]);
			return colors[pluralities[0]] + levels[distance < 0.093 ? 0 : 1]; // from R, see data/explore.R
		}
	}

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

	let showStats, showPlans, showSenatePlans, showComms, drawing, dragging;
	let draggedBgs = [];
	let drawings = [];
	// onMount(() => {
	// 	if (typeof localStorage !== 'undefined')
	// 		drawings = (JSON.parse(localStorage.getItem('data')) || []).map(({ stats, ...r }) => ({
	// 			r,
	// 			stats: stats(r.indices)
	// 		}));
	// });
	$: {
		if (!dragging && draggedBgs.length > 0) {
			if (draggedBgs[0] === draggedBgs[draggedBgs.length - 1]) {
				const bgs = new Set(draggedBgs);
				const hull = concaveman(
					mesh((a, b) => xor(bgs.has(id(a)), bgs.has(id(b)))).coordinates.flat()
				);
				const indices = data
						.map((f, i) => [pointInPolygon(polygonCentroid(f.geometry.coordinates[0]), hull), i])
						.filter((d) => d[0])
						.map((d) => d[1]),
					drawings = [
						...drawings,
						{
							outline: path({
								type: 'LineString',
								coordinates: hull
							}),
							indices,
							stats: stats(indices)
						}
					];
			}
			draggedBgs = [];
		}
	}

	function stats(indices) {
		const data = indices.map((i) => data[i].properties);
		const sum = (m, w) => data.reduce((a, d) => a + (d[m] || 0) * (w ? d[w] : 1), 0);
		const wMean = (m) => sum(m, 'pop20_total') / sum('pop20_total');
		const prop = (m, subgroup) => sum(`${m}_${subgroup}`) / sum(`${m}_total`);
		const output = {
			income: wMean('income'),
			hhlang: prop('hhlang', 'asian')
		};
		groups.forEach((g) => (output['prop_' + g] = prop('pop20', g)));
		return output;
	}

	const delDrawing = (i) => (drawings = drawings.filter((_, j) => j !== i));

	/* onDestroy(() => {
		if (typeof localStorage !== 'undefined') localStorage.setItem('data', JSON.stringify(drawings));
	}); */
</script>

<div class="container" style="cursor: {drawing ? 'crosshair' : 'auto'}">
	<div class="controls">
		<select
			bind:value={variable}
			style="width: {staticVars.includes(variable) ? 'auto' : 'var(--control-width)'}"
		>
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
		{:else if pluralityVars.includes(metric)}
			<div class="color-legend plurality-legend">
				{#each periods as p, i}
					<div style="background-color: {schemeBlues[periods.length][i]}" />
				{/each}
				{#each periods as p}
					<p>{p.replace('_', '-')}</p>
				{/each}
			</div>
		{:else}
			<div class="color-legend">
				{#each breaks as b, i}
					<div style="background-color: {schemeBlues[breaks.length][i]}" />
				{/each}
				{#each breaks as b}
					<p>
						{breaks[breaks.length - 1] < 1
							? pct(b, 0)
							: breaks[breaks.length - 1] > 1000
							? money(b)
							: b}
					</p>
				{/each}
			</div>
		{/if}

		<div class="stats">
			<h3 on:click={() => (showStats = !showStats)}>Redistricting ↓</h3>
			{#if showStats}
				<div in:slide out:slide>
					<p style="text-decoration: underline">Senate District {districtTarget}</p>
					<p>{pct(sums['asian'] / sums.total)} Asian</p>
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
						State Senate, "Letters"
					</label>
				</div>
			{/if}
		</div>

		<div class="stats">
			<h3>
				<button on:click={() => (showComms = !showComms)}>Communities ↓</button>
				<button on:click={() => (drawing = true)}>+</button>
			</h3>
			{#if showComms}
				<div in:slide out:slide>
					{#each drawings as { stats }, i}
						<div>
							<p><i>COI {i + 1}</i> <button on:click={() => delDrawing(i)}>🗑</button></p>
							{#each ['asian'] as grp}
								<p>Pct. {capitalize(grp)}: {pct(stats[`prop_${grp}`])}</p>
							{/each}
							<p>Income: {money(stats.income)}</p>
							<p>Asian and LEP: {pct(stats['hhlang'])}</p>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	</div>

	<svg
		width="1000"
		viewBox="0 0 975 1040"
		on:mousedown={() => (dragging = drawing)}
		on:mouseup={() => (dragging = drawing = false)}
	>
		<g>
			{#each data as f, i (id(f))}
				<path
					class="block-group"
					class:head={draggedBgs[0] === id(f)}
					d={path(f)}
					fill={color(f, metric, period)}
					on:click={() => showSenatePlans && neighbor(i)}
					on:contextmenu|preventDefault={() => console.log(f.properties)}
					on:mousemove|preventDefault={() =>
						drawing &&
						dragging &&
						(draggedBgs.length === 0 ? (draggedBgs = [id(f)]) : draggedBgs.push(id(f)))}
				/>
			{/each}
		</g>
		<g class="meshes">
			<path class="mesh-bg" d={tractVars.includes(metric) ? tractMesh : bgMesh} />

			{#each drawings as { outline }}
				<path class="mesh-target" d={outline} />
			{/each}

			{#if showSenatePlans}
				<g in:fade out:fade>
					<path
						class="mesh-district"
						d={path(mesh((a, b) => a.properties.DISTRICT !== b.properties.DISTRICT))}
					/>
					<path
						class="mesh-target"
						d={path(
							mesh((a, b) => xor(district(a) === districtTarget, district(b) === districtTarget))
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
		--control-width: 270px;
	}

	select {
		font-size: 16px;
		padding: 3px;
		margin-bottom: 5px;
	}

	.controls {
		position: fixed;
		max-width: var(--control-width);
		top: 22px;
		padding-left: 15px;
	}

	.stats div {
		margin-bottom: 20px;
	}

	.stats h3 {
		font-size: 16px;
		margin-bottom: 4px;
		cursor: pointer;
		width: 124px;
	}

	.stats p {
		line-height: 1.25;
	}

	svg {
		margin: 20px 0 0 var(--control-width);
		display: block;
	}

	svg path.head {
		stroke: black;
		stroke-width: 2;
		stroke-dasharray: 4;
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
		margin: 23px 0;
		display: grid;
		grid-template-columns: repeat(3, 53px) 1fr;
		row-gap: 9px;
		grid-template-rows: repeat(5, 14px);
	}

	.row-label {
		line-height: 1;
		margin-left: 5px;
	}

	.col-head {
		text-transform: uppercase;
		font-size: 11px;
		line-height: 1.1;
		margin-top: -3px;
	}

	.color-legend {
		margin: 23px 0;
		display: grid;
		grid-template-rows: 12px 1fr;
		row-gap: 5px;
		grid-template-columns: repeat(6, 40px);
	}

	.color-legend p {
		font-size: 13px;
		text-align: center;
		line-height: 1;
		position: relative;
		right: 13px;
	}

	.plurality-legend {
		grid-template-columns: repeat(4, 40px);
	}

	.plurality-legend p {
		right: 0;
		word-break: break-all;
	}
</style>
