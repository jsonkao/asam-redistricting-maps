<script context="module">
	import { feature, neighbors as topoNeighbors, mesh as topoMesh } from 'topojson-client';
	import { unpackAttributes, reduceCoordinatePrecision } from '$lib/utils';
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
	import {
		capitalize,
		isNum,
		id,
		xor,
		planDesc,
		path,
		getPoints,
		getPlansMeshes,
		getCongressMeshes,
		getStreets
	} from '$lib/utils';
	import {
		colors,
		levels,
		groups,
		periods,
		variablesLong,
		seqColors,
		schemeBlues,
		views,
		idealValues
	} from '$lib/constants';
	import { polygonCentroid } from 'd3-polygon';
	import { onMount } from 'svelte';
	import Svg from '$lib/svg.svelte';
	import Legend from '$lib/legend.svelte';
	import Tables from '$lib/tables.svelte';
	import Panel from '$lib/panel.svelte';
	import Modal from '$lib/modal.svelte';

	export let topoData,
		obj,
		neighbors,
		data,
		dynamicVars,
		staticVars,
		tractVars,
		pluralityVars,
		idToIndex;

	let showStreets, showModal;
	let showMoreOptions = true;
	let showOnlyFocusDistricts = false;
	let drawing, dragging, changingLines;
	let fetchedDrawings;
	let draggedBgs = [];
	let drawings = [];
	let aggregates = [];
	let stats = {};
	let presentationMode = false;

	let panels = ['plans', 'views'];

	let plan = 'assembly';
	let bgMesh, congressPlans, points, streets;
	let plans;

	let containerFont = presentationMode ? 24 : 18;
	let clientWidth;
	let viewCutoff = 870; // manually copied from make/mapshaper output
	let view = Object.keys(views)[0];
	$: viewBox = views[view];

	const mesh = (filterFn) => topoMesh(topoData, obj, filterFn);
	const tractMesh = path(mesh((a, b) => id(a).substring(0, 11) !== id(b).substring(0, 11)));

	const closeModal = () => (showModal = false);
	onMount(async () => {
		bgMesh = path(reduceCoordinatePrecision(mesh((a, b) => id(a) !== id(b))));
		const promises = await Promise.all([getPlansMeshes(), getPoints()]);
		plans = promises[0];
		points = promises[1];
		viewCutoff = data.length;

		showModal = !presentationMode;
	});

	let lastDistrict;
	const getDistrict = (i) => data[i].properties[plan];
	function neighbor(i) {
		const selfD = getDistrict(i);
		const districts = new Set(neighbors[i].map(getDistrict).filter((d) => d !== selfD));
		if (districts.size === 1)
			obj.geometries[i].properties[plan] = lastDistrict = districts.values().next().value;
		else if (districts.has(lastDistrict)) obj.geometries[i].properties[plan] = lastDistrict;
		else return;
		obj = obj;
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
		if (!d.ALAND) return '#fff';
		const total = d[`${metric}_total`];

		if (pluralityVars.includes(metric)) {
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return '#eee';
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[periods.indexOf(pluralities[0])];
		} else if (staticVars.includes(metric)) {
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
				if (majority !== undefined)
					return colors[majority] + levels[total < 130 ? 0 : total < 200 ? 1 : 2];
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

	$: {
		if (!dragging && draggedBgs.length > 0) {
			if (draggedBgs[0] === draggedBgs[draggedBgs.length - 1]) {
				const bgs = new Set(draggedBgs);
				const hull = concaveman(
					mesh((a, b) => xor(bgs.has(id(a)), bgs.has(id(b)))).coordinates.flat()
				);
				const ids = data
					.filter((f) => pointInPolygon(polygonCentroid(f.geometry.coordinates[0]), hull))
					.map(id);
				drawings = [
					...drawings,
					{
						outline: path({ type: 'LineString', coordinates: hull }),
						ids,
						stats: getStats(ids)
					}
				];
			}
			draggedBgs = [];
		}
	}

	$: plan.startsWith('congress') && congressPlans === undefined && loadCongressMeshes();
	const loadCongressMeshes = async () => (congressPlans = await getCongressMeshes());

	$: showStreets && streets === undefined && loadStreets();
	const loadStreets = async () => (streets = await getStreets());

	function getStats(input) {
		const data1 =
			typeof input[0] === 'string'
				? input.map((id) => data[idToIndex[id]].properties)
				: input.map((f) => f.properties);
		const sum = (m, w) => data1.reduce((a, d) => a + (d[m] || 0) * (w ? d[w] || 1 : 1), 0);
		const wMean = (m) => sum(m, 'pop20_total') / sum('pop20_total');
		const prop = (m, subgroup) => sum(`${m}_${subgroup}`) / sum(`${m}_total`);
		let old_asian = sum('pop10_asian');
		let new_asian = sum('pop20_asian');
		let old_asiancvap = sum('cvap10_asian');
		let new_asiancvap = sum('cvap19_asian');

		const output = {
			income: wMean('income'),
			hhlang: prop('hhlang', 'asian'),
			benefits: prop('families', 'benefits'),
			pop20_total: sum('pop20_total'),
			pct_increase: (new_asian - old_asian) / old_asian,
			pct_increase_cvap: (new_asiancvap - old_asiancvap) / old_asiancvap
		};
		['pop20', 'cvap19', 'pop10', 'cvap10'].forEach((m) =>
			groups.forEach((g) => (output[m + g] = prop(m, g)))
		);
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

	$: {
		if (panels.includes('communities') && !fetchedDrawings) {
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

	const togglePanel = (p) =>
		(panels = panels.includes(p) ? panels.filter((x) => x !== p) : [...panels, p]);

	$: labelSize =
		((plan.endsWith('_names') ? 0.9 : 1.1) / ((clientWidth - 410) / viewBox[2])) *
		(presentationMode ? 1.24 : 1.1);

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

	function handleKeydown({ key }) {
		if (!presentationMode) return;
		if (key === '=') containerFont += 2;
		if (key === '-') containerFont -= 2;
		if (key === 'v') showMoreOptions = !showMoreOptions;
		if (key === 'f') showOnlyFocusDistricts = !showOnlyFocusDistricts;
		if (key === 's') showOnlyFocusDistricts = !showOnlyFocusDistricts;
	}
</script>

<svelte:window on:keydown={handleKeydown} />

<Modal {showModal} {closeModal} />

<div
	class="container"
	style="cursor: {drawing
		? 'crosshair'
		: 'auto'}; --container-font: {containerFont}px; --control-width: {270 +
		(containerFont - 16) * 10}px;"
	bind:clientWidth
>
	<div class="controls">
		<select
			bind:value={variable}
			style="width: {staticVars.includes(variable) ? 'auto' : 'calc(var(--control-width) + 45px)'}"
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

		{#if showMoreOptions}
			<div in:slide out:slide>
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
			</div>
		{/if}

		<Legend
			{groups}
			{levels}
			{colors}
			{dynamicVars}
			{variable}
			{metric}
			{showPluralities}
			{pluralityVars}
			{periods}
			{breaks}
		/>

		<Panel panelName="plans" {panels} {togglePanel}>
			<!-- <button slot="title" class="subbutton" on:click={() => (changingLines = !changingLines)}>
				{changingLines ? 'Original' : 'Modify'}
			</button> -->
			<div slot="body">
				<div class="plan-selector">
					<select bind:value={plan}>
						{#each ['assembly', 'senate', 'congress'] as scope}
							<optgroup label={capitalize(scope)}>
								{#each ['', '_letters', '_names', '_unity'] as proposal}
									{#if scope + proposal !== 'congress_unity'}
										<option value={scope + proposal}>
											{planDesc(scope + proposal)}
										</option>
									{/if}
								{/each}
							</optgroup>
						{/each}
					</select>
				</div>
				<Tables
					{aggregates}
					{handleLabelClick}
					{plan}
					{stats}
					{groups}
					{changingLines}
					{idealValues}
				/>
			</div>
		</Panel>

		<Panel panelName="views" {panels} {togglePanel}>
			<div slot="body" class="views">
				<select bind:value={view}>
					{#each Object.keys(views) as v}
						<option value={v}>{v}</option>
					{/each}
				</select>
				<label>
					<input type="checkbox" bind:checked={showStreets} />
					Inspect streets
				</label>
			</div>
		</Panel>

		{#if !presentationMode}
			<Panel panelName="communities" {panels} {togglePanel}>
				<button slot="title" on:click={() => (drawing = true)}>+</button>
				<div slot="body" class="community">
					<Tables type="community" {drawings} {delDrawing} {groups} {stats} />
					<button on:click={save} style="font-size: 13px;">
						<b>[SAVE]</b>
					</button>
				</div>
			</Panel>
		{/if}
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
		{panels}
		{drawings}
		{plan}
		{points}
		{tractMesh}
		{bgMesh}
		{mesh}
		{aggregates}
		{obj}
		{handleLabelClick}
		{congressPlans}
		{plans}
		{startDrag}
		{endDrag}
		{handleMouseMove}
		{viewCutoff}
		{showOnlyFocusDistricts}
		{showStreets}
		{streets}
		{presentationMode}
	/>

	{#if !presentationMode}
		<div class="footer">
			<p>
				Questions, suggestions, concerns --> <a href="mailto:jason.kao@console.edu"
					>jason.kao@columbia.edu</a
				>.
			</p>
		</div>
	{/if}
</div>

<style>
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
		padding-left: 15px;
	}

	.community {
		margin-bottom: 10px;
	}

	.plurality-toggle {
		text-decoration: underline;
		margin-left: 7px;
		font-size: 0.88em;
		line-height: 1;
	}

	.footer {
		padding: 0 15px;
		margin-top: 20px;
		font-size: 0.8em;
		text-align: right;
	}

	.views label {
		display: block;
		cursor: pointer;
	}

	.plan-selector {
		margin-bottom: 10px;
	}
</style>
