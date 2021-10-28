<script context="module">
	import { feature, neighbors as topoNeighbors, mesh as topoMesh } from 'topojson-client';
	import { unpackAttributes } from '$lib/utils';
	import { geoPath } from 'd3-geo';

	async function getPoints(fetch) {
		const req = await fetch('/points.topojson');
		const topoData = await req.json();
		return feature(topoData, topoData.objects.layer).features;
	}

	/**
	 * A function that computes all constant data
	 */
	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const req = await fetch('/output.topojson');
		const topoData = await req.json();
		const obj = unpackAttributes(topoData.objects.census);
		const data = feature(topoData, obj).features;

		// Establish the static variables and the variables that change over time
		const dynamicVars = ['cvap', 'pop'];
		const staticVars = [
			...data.reduce((acc, val) => {
				const fields = Object.keys(val.properties)
					.filter(
						(k) =>
							[...dynamicVars, 'GEOID', 'senate', 'assembly', 'congress'].every(
								(v) => !k.includes(v)
							) && k === k.toLowerCase()
					)
					.map((k) => k.split('_')[0]);
				return new Set([...acc, ...fields]);
			}, [])
		];

		const idToIndex = data.reduce((acc, f, i) => {
			acc[f.properties.GEOID] = i;
			return acc;
		}, {});

		// Retrieve boundaries data
		const path = geoPath();
		const plansMeshes = {};
		const D = (x) => Object.values(x.properties)[0];
		Object.keys(topoData.objects).forEach((k) => {
			if (k !== 'census')
				plansMeshes[k] = path(topoMesh(topoData, topoData.objects[k], (a, b) => D(a) !== D(b)));
		});

		return {
			props: {
				topoData,
				obj,
				data,
				neighbors: topoNeighbors(obj.geometries),
				dynamicVars,
				staticVars,
				idToIndex,
				points: await getPoints(fetch),
				path,
				plansMeshes,
				tractVars: ['asiaentry', 'workers'],
				pluralityVars: ['asiaentry'] // Aside from race
			}
		};
	}
</script>

<script>
	import { schemeBlues } from 'd3-scale-chromatic';
	import ckmeans from 'ckmeans';
	import { slide, fade } from 'svelte/transition';
	import * as concaveman from 'concaveman';
	import pointInPolygon from 'point-in-polygon';
	import {
		pct,
		capitalize,
		money,
		isNum,
		id,
		district,
		xor,
		planTitle,
		planDesc
	} from '$lib/utils';
	import { colors, levels, groups, periods, variablesLong, seqColors } from '$lib/constants';
	import { polygonCentroid } from 'd3-polygon';
	import { onMount } from 'svelte';

	export let topoData,
		obj,
		neighbors,
		data,
		points,
		dynamicVars,
		staticVars,
		tractVars,
		pluralityVars,
		plansMeshes,
		path,
		idToIndex;

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

	let period = 'present';
	let variable = 'pop';
	$: metric = staticVars.includes(variable)
		? variable
		: variable + (period === 'past' ? 10 : variable === 'cvap' ? 19 : 20);

	const breaksCache = {
		pop: [0, 0.06, 0.15, 0.25, 0.4, 0.6],
		cvap: [0, 0.05, 0.14, 0.26, 0.41, 0.6]
	};
	$: getValue = {
		income: (d) => d[metric],
		hhlang: (d) => d[`${metric}_asian`] / d[`${metric}_total`],
		graduates: (d) => (d[`${metric}_hs_grad`] + d[`${metric}_ba_above`]) / d[`${metric}_total`],
		families: (d) => d[`${metric}_benefits`] / d[`${metric}_total`],
		workers: (d) => d[`${metric}_publictransport`] / d[`${metric}_total`]
	}[metric];
	$: breaks =
		dynamicVars.includes(variable) && !showPluralities
			? breaksCache[variable]
			: breaksCache[metric] ||
			  !staticVars.includes(metric) ||
			  metric === 'asiaentry' || // Don't compute breaks for dynamic and tract variables
			  (breaksCache[metric] = ckmeans(data.map((f) => getValue(f.properties)).filter(isNum), 6));

	let showPluralities = true;

	function color({ properties: d }) {
		if (d.ALAND === 0) return '#fff';
		const total = d[`${metric}_total`];

		if (pluralityVars.includes(metric)) {
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return '#ddd';
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[periods.length][periods.indexOf(pluralities[0])];
		} else if (staticVars.includes(metric)) {
			if (!isNum(getValue(d))) return '#ddd';
			if (total <= 10) return '#fff';
			for (let i = 1; i < breaks.length; i++) {
				if (getValue(d) < breaks[i]) return schemeBlues[breaks.length][i];
			}
			return schemeBlues[breaks.length][breaks.length - 1];
		} else {
			if (total <= 10) return '#fff';
			const p = (g) => d[`${metric}_${g}`] / d[`${metric}_total`];

			if (showPluralities) {
				const majority = groups.filter((g) => p(g) > 0.5)[0];
				if (majority !== undefined) {
					return colors[majority] + levels[total < 130 ? 0 : total < 200 ? 1 : 2];
				}

				const pluralities = [...groups].sort((a, b) => p(b) - p(a));
				const distance = p(pluralities[0]) - p(pluralities[1]);
				return colors[pluralities[0]] + levels[distance < 0.093 ? 0 : 1]; // from R, see data/explore.R
			} else {
				const breaks = breaksCache[variable];

				for (let i = 1; i < breaks.length; i++) {
					if (p('asian') < breaks[i]) return seqColors[i - 1];
				}
				return seqColors[breaks.length - 1];
			}
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

	let showStats, showPlans, showComms, drawing, dragging;
	let draggedBgs = [];
	let drawings = [];
	$: {
		if (!dragging && draggedBgs.length > 0) {
			if (draggedBgs[0] === draggedBgs[draggedBgs.length - 1]) {
				const bgs = new Set(draggedBgs);
				const hull = concaveman(
					mesh((a, b) => xor(bgs.has(id(a)), bgs.has(id(b)))).coordinates.flat()
				);
				const ids = data
					.map((f) => [pointInPolygon(polygonCentroid(f.geometry.coordinates[0]), hull), id(f)])
					.filter((d) => d[0])
					.map((d) => d[1]);
				drawings = [
					...drawings,
					{
						outline: path({
							type: 'LineString',
							coordinates: hull
						}),
						ids,
						stats: getStats(ids)
					}
				];
			}
			draggedBgs = [];
		}
	}

	function getStats(input) {
		let data1;
		if (typeof input[0] === 'string') data1 = input.map((id) => data[idToIndex[id]].properties);
		else data1 = input.map((f) => f.properties);
		const sum = (m, w) => data1.reduce((a, d) => a + (d[m] || 0) * (w ? d[w] || 1 : 1), 0);
		const wMean = (m) => sum(m, 'pop20_total') / sum('pop20_total');
		const prop = (m, subgroup) => sum(`${m}_${subgroup}`) / sum(`${m}_total`);
		const output = {
			income: wMean('income'),
			hhlang: prop('hhlang', 'asian'),
			benefits: prop('families', 'benefits')
		};
		['pop20', 'cvap19'].forEach((m) => groups.forEach((g) => (output[m + g] = prop(m, g))));
		return output;
	}

	const delDrawing = (i) => (drawings = drawings.filter((_, j) => j !== i));

	async function save() {
		await fetch(`/data.json`, { method: 'POST', body: JSON.stringify(drawings) });
	}

	onMount(async () => {
		const req = await fetch(`/data.json`);
		drawings = (await req.json()).map((r) => ({
			...r,
			stats: getStats(r.ids)
		}));
	});

	const views = {
		Manhattan: [80, 430, 500, 440],
		Brooklyn: [20, 550, 600, 600],
		Full: [0, 0, 975, 1420]
	};
	let viewBox = views['Manhattan'];
	let clientWidth;
	$: labelSize = 16 / ((clientWidth - 410) / viewBox[2]);

	let plan = 'assembly_letters';

	let aggregates = [];/*[
		'assembly,65',
		'assembly_letters,BM',
		'assembly_names,STHMNHTN',
		'senate,26',
		'senate_letters,BH',
		'senate_names,DWNTNBRKLN'
	];*/
	let stats = {};

	$: {
		for (let i = 0; i < aggregates.length; i++) {
			const [aPlan, aDistrict] = aggregates[i].split(',');
			if (aPlan === plan && !(aggregates[i] in stats)) {
				stats[aggregates[i]] = getStats(
					data.filter(({ properties: d }) => aDistrict === '' + d[plan])
				);
			}
		}
	}
	$: {
		['pop10', 'pop20', 'cvap10', 'cvap19'].forEach((m) => {
			console.log(
				m,
				ckmeans(
					data.map((f) => f.properties[`${m}_asian`] / f.properties[m + '_total']).filter(isNum),
					5
				)
			);
		});
	}


	function handleLabelClick(id) {
		if (aggregates.includes(id)) aggregates = aggregates.filter((a) => a !== id);
		else aggregates = [...aggregates, id];
	}
</script>

<div class="container" style="cursor: {drawing ? 'crosshair' : 'auto'}" bind:clientWidth>
	<div class="controls">
		<select
			bind:value={variable}
			style="width: {staticVars.includes(variable) ? 'auto' : 'calc(var(--control-width) - 20px)'}"
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
		{/if}

		{#if dynamicVars.includes(variable)}
			<button class="plurality-toggle" on:click={() => (showPluralities = !showPluralities)}>
				Show {showPluralities ? 'pct. asian' : 'pluralities'}
			</button>
		{/if}

		{#if dynamicVars.includes(variable) && showPluralities}
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
					<div
						style="background-color: {dynamicVars.includes(variable)
							? seqColors[i]
							: schemeBlues[breaks.length][i]}"
					/>
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
			<h3 on:click={() => (showPlans = !showPlans)}>Plans ↓</h3>
			{#if showPlans}
				<div in:slide out:slide>
					<div class="plan-selector">
						<select bind:value={plan}>
							<optgroup label="Current districts">
								{#each ['assembly', 'senate', 'congress'] as p}
									<option value={p}>{planDesc(p)}</option>
								{/each}
							</optgroup>
							<optgroup label="Proposed districts">
								{#each ['assembly_letters', 'assembly_names', 'senate_letters', 'senate_names', 'congress_letters', 'congress_names'] as p}
									<option value={p}>{planDesc(p)}</option>
								{/each}
							</optgroup>
						</select>
					</div>
					{#each aggregates as a}
						{#if a.split(',')[0].split('_')[0] === plan.split('_')[0]}
							<div class="district-aggregate">
								<p on:click={() => handleLabelClick(a)}><i>{planTitle(a)}</i></p>
								<table>
									<tr>
										<th />
										<th>CVAP</th>
										<th>Pop.</th>
									</tr>
									{#each groups as g}
										<tr>
											<td>{capitalize(g)}</td>
											<td>{pct(stats[a]['cvap19' + g])}</td>
											<td>{pct(stats[a]['pop20' + g])}</td>
										</tr>
									{/each}
								</table>
								<p>Income: {money(stats[a].income)}</p>
							</div>
						{/if}
					{/each}
				</div>
			{/if}
		</div>

		<div class="stats">
			<h3 on:click={() => (showStats = !showStats)}>Redistricting ↓</h3>
			{#if showStats}
				<div in:slide out:slide>
					<p><i>Senate District {districtTarget}</i></p>
					<p>Pct. Asian: {pct(sums['asian'] / sums.total, 2)}</p>
					<p>{Math.abs(delta).toLocaleString()} people {delta >= 0 ? 'above' : 'below'}</p>
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
					{#each drawings as { name, stats }, i}
						<div>
							<p>
								<i>{name || 'COI' + (i + 1)}</i> <button on:click={() => delDrawing(i)}>🗑</button>
							</p>
							{#each ['asian'] as grp}
								<p>Pct. {capitalize(grp)}: {pct(stats[`prop_${grp}`])}</p>
							{/each}
							<p>Income: {money(stats.income)}</p>
							<p>Asian and LEP: {pct(stats['hhlang'])}</p>
							<p>Pct. gov't benefits: {pct(stats['benefits'])}</p>
						</div>
					{/each}

					<button on:click={save} style="font-size: 13px;">
						<b>[SAVE]</b>
					</button>
				</div>
			{/if}
		</div>
	</div>

	<svg
		viewBox={viewBox.join(' ')}
		on:mousedown={() => (dragging = true)}
		on:mouseup={() => (dragging = drawing = false)}
		style="--font-size: {labelSize}px"
	>
		<g>
			{#each data as f, i (id(f))}
				<path
					class="block-group"
					class:head={draggedBgs[0] === id(f)}
					d={path(f)}
					fill={color(f, metric, period, showPluralities)}
					on:click={() => false && neighbor(i)}
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

			{#if showComms}
				<g in:fade out:fade>
					{#each drawings as { outline }}
						<path class="mesh-target" d={outline} />
					{/each}
				</g>
			{/if}

			{#if showPlans}
				<g in:fade out:fade>
					<path class="mesh-district" class:showPluralities d={plansMeshes[plan]} />
				</g>
			{/if}

			{#if false}
				<g in:fade out:fade>
					<path
						class="mesh-district"
						d={path(
							mesh(
								(a, b) => a.properties.DISTRICT !== b.properties.DISTRICT || id(a) === id(b),
								obj
							)
						)}
					/>
					<path
						class="mesh-target"
						d={path(
							mesh((a, b) =>
								xor(district(a) === districtTarget, district(b) === districtTarget, obj)
							)
						)}
					/>
				</g>
			{/if}

			{#if showPlans}
				<g class="labels" in:fade out:fade>
					{#each points as { properties: p, geometry: { coordinates: [x, y] } }}
						{#if plan in p}
							<text
								{x}
								{y}
								class:chosen={aggregates.includes(`${plan},${p[plan]}`)}
								on:click={() => handleLabelClick(`${plan},${p[plan]}`)}
							>
								{p[plan]}
							</text>
						{/if}
					{/each}
				</g>
			{/if}
		</g>
	</svg>

	<div class="views">
		<h3>Views</h3>
		{#each Object.keys(views) as v}
			<button on:click={() => (viewBox = views[v])}>{v}</button>
		{/each}
	</div>
</div>

<style>
	.container {
		margin: 0 auto;
		--control-width: 270px;
	}

	select {
		font-size: 16px;
		outline: none;
		padding: 3px;
		margin-bottom: 5px;
	}

	.controls {
		position: fixed;
		max-width: var(--control-width);
		top: 22px;
		padding-left: 15px;
	}

	.views {
		position: fixed;
		right: 25px;
		top: 22px;
	}

	.views h3 {
		font-size: 16px;
	}
	.views button {
		display: block;
		font-size: 16px;
		text-align: right;
		line-height: 1.3;
		text-decoration: underline;
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
		margin-left: var(--control-width);
		display: block;
		width: calc(100% - var(--control-width) - 150px);
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

	.mesh-district:not(.showPluralities) {
		stroke: #f9b964;
		stroke-width: 1.8;
	}

	.mesh-district.showPluralities {
		stroke: black;
		stroke-width: 1.1;
	}

	.mesh-target {
		stroke: black;
		stroke-width: 1.1;
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

	.plurality-toggle {
		text-decoration: underline;
		margin-left: 7px;
		font-size: 14px;
		line-height: 1;
		/* text-transform: uppercase; */
	}

	.col-head {
		text-transform: uppercase;
		font-size: 11px;
		line-height: 1.1;
		margin-top: -3px;
	}

	.color-legend {
		margin: 19px 0;
		display: grid;
		grid-template-rows: 12px 1fr;
		row-gap: 4px;
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

	.labels {
		--shadow: #ffff;
	}

	.labels text {
		font-size: var(--font-size);
		text-anchor: middle;
		cursor: pointer;
		text-shadow: 0px 1px 1px var(--shadow), 0px -1px 1px var(--shadow), 1px 0px 1px var(--shadow),
			-1px 0px 1px var(--shadow), -1.5px 0px 2px var(--shadow), 1.5px 0px 2px var(--shadow),
			0 1.5px 2px var(--shadow), 0 -1.5px 2px var(--shadow);
	}

	.labels text.chosen {
		font-weight: 700;
	}

	table {
		border-collapse: collapse;
		margin: 4px 0;
		min-width: 200px;
	}

	table th {
		text-align: left;
		border-spacing: 0;
		font-weight: 600;
	}

	table td,
	th {
		line-height: 1;
		margin: 0;
		font-size: 15px;
	}

	table td {
		padding: 3px 0;
	}

	tr td:not(:last-child) {
		padding-right: 9px;
	}

	table tr {
		border-bottom: 1px solid #ddd;
	}

	.stats .district-aggregate {
		margin-bottom: 11px;
	}

	.district-aggregate p:first-child {
		cursor: pointer;
	}

	.stats .plan-selector {
		margin-bottom: 10px;
	}
</style>
