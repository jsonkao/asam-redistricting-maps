<script context="module">
	import { feature, neighbors as topoNeighbors, mesh as topoMesh } from 'topojson-client';
	import { unpackAttributes, reduceCoordinatePrecision, D } from '$lib/utils';
	import { base } from '$app/paths';

	/**
	 * A function that computes all constant data
	 */
	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const topoData = await (await fetch(`${base}/output_census.topojson`)).json();
		const obj = unpackAttributes(topoData.objects.census);
		const data = feature(topoData, obj).features.map(reduceCoordinatePrecision);

		// Establish the static variables and the variables that change over time
		const dynamicVars = ['pop', 'cvap'];
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

		return {
			props: {
				topoData,
				obj,
				data,
				neighbors: topoNeighbors(obj.geometries),
				dynamicVars,
				staticVars,
				idToIndex,
				tractVars: ['asiaentry', 'workers'],
				pluralityVars: ['asiaentry'] // Aside from race
			}
		};
	}
</script>

<script>
	import ckmeans from 'ckmeans';
	import { slide } from 'svelte/transition';
	import concaveman from 'concaveman';
	import pointInPolygon from 'point-in-polygon';
	import { geoPath } from 'd3-geo';
	import {
		pct,
		capitalize,
		money,
		isNum,
		id,
		xor,
		planTitle,
		planDesc,
		deviation
	} from '$lib/utils';
	import {
		colors,
		levels,
		groups,
		periods,
		variablesLong,
		seqColors,
		schemeBlues,
		idealValues
	} from '$lib/constants';
	import { polygonCentroid } from 'd3-polygon';
	import Svg from '$lib/svg.svelte';
	import { onMount } from 'svelte';

	export let topoData,
		obj,
		neighbors,
		data,
		dynamicVars,
		staticVars,
		tractVars,
		pluralityVars,
		idToIndex;

	const path = geoPath();

	const mesh = (filterFn) => topoMesh(topoData, obj, filterFn);
	const tractMesh = path(mesh((a, b) => id(a).substring(0, 11) !== id(b).substring(0, 11)));
	let viewCutoff = 2765; // manually copied from make/mapshaper output
	let plansMeshes, bgMesh, points;

	onMount(async () => {
		bgMesh = path(reduceCoordinatePrecision(mesh((a, b) => id(a) !== id(b))));
		viewCutoff = 6000;

		// Retrieve boundaries data
		const topoData = await (await fetch(`${base}/output_assembly_senate.topojson`)).json();
		plansMeshes = Object.keys(topoData.objects).reduce((acc, k) => {
			acc[k] = path(topoMesh(topoData, topoData.objects[k], (a, b) => D(a) !== D(b)));
			return acc;
		}, {});

		// Retrieve label positions
		const pointsData = await (await fetch(`${base}/points.topojson`)).json();
		points = feature(pointsData, pointsData.objects.layer).features;
	});

	const getDistrict = (i) => data[i].properties[plan];

	let lastDistrict;
	function neighbor(i) {
		const selfD = getDistrict(i);
		const districts = new Set(neighbors[i].map(getDistrict).filter((d) => d !== selfD));
		if (districts.size === 1) {
			const district = districts.values().next().value;
			obj.geometries[i].properties[plan] = district;
			obj = obj;
			lastDistrict = district;
		} else if (districts.has(lastDistrict)) {
			obj.geometries[i].properties[plan] = lastDistrict;
			obj = obj;
		}
	}

	let period = 'present';
	let variable = 'pop';
	$: metric = staticVars.includes(variable)
		? variable
		: variable + (period === 'past' ? 10 : variable === 'cvap' ? 19 : 20);

	const breaksCache = {
		pop: [0, 0.1, 0.2, 0.4, 0.6],
		cvap: [0, 0.1, 0.2, 0.4, 0.6]
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

	let showPluralities = false;

	function color({ properties: d }) {
		if (d.ALAND === 0) return '#fff';
		const total = d[`${metric}_total`];

		if (pluralityVars.includes(metric)) {
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return '#eee';
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[periods.indexOf(pluralities[0])];
		} else if (staticVars.includes(metric)) {
			if (!d.ALAND) return '#fff';
			if (!isNum(getValue(d))) return '#eee';
			if (total <= 10) return '#fff';
			for (let i = 1; i < breaks.length; i++) {
				if (getValue(d) < breaks[i]) return schemeBlues[i];
			}
			return schemeBlues[breaks.length - 1];
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

	let showPlans, showComms, drawing, dragging;
	let changingLines;
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

	let congressMeshes;
	$: {
		if (congressMeshes === undefined && plan.startsWith('congress')) {
			loadCongressMeshes();
		}
	}

	async function loadCongressMeshes() {
		const req = await fetch(`${base}/output_congress.topojson`);
		const topoData = await req.json();
		congressMeshes = Object.keys(topoData.objects).reduce((acc, k) => {
			acc[k] = path(topoMesh(topoData, topoData.objects[k], (a, b) => D(a) !== D(b)));
			return acc;
		}, {});
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
			benefits: prop('families', 'benefits'),
			pop20_total: sum('pop20_total')
		};
		['pop20', 'cvap19'].forEach((m) => groups.forEach((g) => (output[m + g] = prop(m, g))));
		return output;
	}

	const delDrawing = (i) => (drawings = drawings.filter((_, j) => j !== i));

	async function save() {
		try {
			await fetch(`${base}/data.json`, { method: 'POST', body: JSON.stringify(drawings) });
		} catch (e) {
			console.error(e);
		}
	}

	let fetchedDrawings;
	$: {
		if (showComms && !fetchedDrawings) {
			fetchDrawings();
			fetchedDrawings = true;
		}
	}

	async function fetchDrawings() {
		try {
			const req = await fetch(`${base}/data.json`);
			drawings = (await req.json()).map((r) => ({
				...r,
				stats: getStats(r.ids)
			}));
		} catch (e) {
			console.error(e);
		}
	}

	const views = {
		Chinatown: [80, 500, 300, 220],
		'Chinatown Wide': [80, 430, 500, 440],
		Brooklyn: [20, 550, 600, 600],
		Full: [0, 0, 975, 1420]
	};
	let viewBox = views['Brooklyn'];
	let clientWidth;
	$: labelSize = (plan.endsWith('_names') ? 13 : 16) / ((clientWidth - 410) / viewBox[2]);

	let plan = 'assembly';

	let aggregates = [];
	let stats = {};

	$: {
		for (let i = 0; i < aggregates.length; i++) {
			const [aPlan, aDistrict] = aggregates[i].split(',');
			if (aPlan === plan /* && !(aggregates[i] in stats) */) {
				stats[aggregates[i]] = getStats(
					obj.geometries.filter(({ properties: d }) => aDistrict === '' + d[plan])
				);
			}
		}
	}

	function handleLabelClick(id) {
		if (aggregates.includes(id)) aggregates = aggregates.filter((a) => a !== id);
		else aggregates = [...aggregates, id];
	}

	const startDrag = () => (dragging = true);
	const endDrag = () => (dragging = drawing = false);
	const handleMouseMove = (f) =>
		drawing &&
		dragging &&
		(draggedBgs.length === 0 ? (draggedBgs = [id(f)]) : draggedBgs.push(id(f)));
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
					<div style="background-color: {schemeBlues[i]}" />
				{/each}
				{#each periods as p}
					<p>{p.replace('_', '-')}</p>
				{/each}
			</div>
		{:else}
			<div
				class="color-legend"
				class:pctasian={dynamicVars.includes(variable)}
				style="grid-template-columns: repeat({dynamicVars.includes(variable) ? 5 : 6}, 40px);"
			>
				{#each breaks as b, i}
					<div
						style="background-color: {dynamicVars.includes(variable)
							? seqColors[i]
							: schemeBlues[i]};"
					/>
				{/each}
				{#each breaks as b, i}
					<p>
						{(breaks[breaks.length - 1] < 1
							? pct(b, 0)
							: breaks[breaks.length - 1] > 1000
							? money(b)
							: b) + (dynamicVars.includes(variable) && i === breaks.length - 1 ? ' Asian' : '')}
					</p>
				{/each}
			</div>
		{/if}

		<div class="stats">
			<h3>
				<button
					on:click={() => {
						showPlans = !showPlans;
						showComms = false;
					}}
				>
					Plans ↓
				</button>
				<button class="subbutton" on:click={() => (changingLines = !changingLines)}>
					{changingLines ? 'Original' : 'Modify'}
				</button>
			</h3>
			{#if showPlans}
				<div in:slide out:slide>
					<div class="plan-selector">
						<select bind:value={plan}>
							{#each ['assembly', 'senate', 'congress'] as scope}
								<optgroup label={capitalize(scope)}>
									{#each ['', '_letters', '_names'] as proposal}
										<option value={scope + proposal}>{planDesc(scope + proposal)}</option>
									{/each}
								</optgroup>
							{/each}
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
								<p class="table-footer">
									Income: {money(stats[a].income) +
										(changingLines && plan in idealValues
											? '; ' + deviation(stats[a]['pop20_total'] - idealValues[plan])
											: '')}
								</p>
							</div>
						{/if}
					{/each}
				</div>
			{/if}
		</div>

		<div class="stats">
			<h3>
				<button
					on:click={() => {
						showComms = !showComms;
						showPlans = false;
					}}>Communities ↓</button
				>
				<button on:click={() => (drawing = true)}>+</button>
			</h3>
			{#if showComms}
				<div class="community" in:slide out:slide>
					{#each drawings as { name, stats }, i}
						<div>
							<p>
								<i>{name || 'COI' + (i + 1)}</i> <button on:click={() => delDrawing(i)}>🗑</button>
							</p>
							<table>
								<tr>
									<th />
									<th>CVAP</th>
									<th>Pop.</th>
								</tr>
								{#each groups as g}
									<tr>
										<td>{capitalize(g)}</td>
										<td>{pct(stats['cvap19' + g])}</td>
										<td>{pct(stats['pop20' + g])}</td>
									</tr>
								{/each}
							</table>
							<p class="table-footer">Income: {money(stats.income)}</p>
							<p class="table-footer">Asian and LEP: {pct(stats['hhlang'])}</p>
							<p class="table-footer">Pct. gov't benefits: {pct(stats['benefits'])}</p>
						</div>
					{/each}

					<button on:click={save} style="font-size: 13px;">
						<b>[SAVE]</b>
					</button>
				</div>
			{/if}
		</div>
	</div>

	<Svg
		{viewBox}
		{labelSize}
		{draggedBgs}
		{data}
		{path}
		{color}
		{changingLines}
		{neighbor}
		{showPluralities}
		{metric}
		{period}
		{tractVars}
		{showComms}
		{drawings}
		{showPlans}
		{plan}
		{points}
		{tractMesh}
		{bgMesh}
		{mesh}
		{aggregates}
		{obj}
		{handleLabelClick}
		{congressMeshes}
		{plansMeshes}
		{startDrag}
		{endDrag}
		{handleMouseMove}
		{viewCutoff}
	/>

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

	.stats div.community {
		margin-bottom: 10px;
	}

	.stats h3 {
		font-size: 16px;
		margin-bottom: 4px;
		cursor: pointer;
		width: 138px;
	}
	.stats h3 button.subbutton {
		font-size: 14px;
		font-weight: 300;
		text-decoration: underline;
	}

	.stats p {
		line-height: 1.25;
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
	}

	.color-legend p {
		font-size: 13px;
		text-align: center;
		line-height: 1;
		position: relative;
		right: 13px;
	}

	.color-legend.pctasian p {
		text-align: left;
		right: 7px;
	}

	.color-legend.pctasian p:last-child {
		white-space: pre;
	}

	.plurality-legend {
		grid-template-columns: repeat(4, 40px);
	}

	.plurality-legend p {
		right: 0;
		word-break: break-all;
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

	.table-footer {
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
