<script context="module">
	import { feature } from 'topojson-client';
	import { unpackAttributes, readCSV } from '$lib/utils';
	import { base } from '$app/paths';

	/**
	 * A function that computes all constant data
	 */
	export async function load({ fetch }) {
		// Fetch TopoJSON data; do necessary transformations
		const censusData = readCSV(await (await fetch(`${base}/data.csv`)).text());
		const topoData = await (await fetch(`${base}/output_census_wgs84.topojson`)).json();
		const obj = unpackAttributes(topoData.objects.census);
		const census = feature(topoData, obj);
		const data = census.features;

		// Establish the static variables and the variables that change over time
		const dynamicVars = ['pop', 'vap', 'cvap'];
		const staticVars = [
			...data.reduce((acc, val) => {
				const fields = Object.keys(val.properties)
					.filter(
						(k) =>
							[...dynamicVars, 'GEOID', 'senate', 'assembly'].every((v) => !k.includes(v)) &&
							k === k.toLowerCase()
					)
					.map((k) => k.split('_')[0]);
				return new Set([...acc, ...fields]);
			}, [])
		];

		return {
			props: {
				censusData,
				data,
				dynamicVars,
				staticVars,
				pluralityVars: ['asiaentry'], // Aside from race
				census,
				plansTopo: await (await fetch(`${base}/plans.topojson`)).json(),
				points: await (await fetch(`${base}/points.geojson`)).json()
			}
		};
	}
</script>

<script>
	import ckmeans from 'ckmeans';
	import { slide } from 'svelte/transition';
	import { capitalize, isNum, planDesc } from '$lib/utils';
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
	import Legend from '$lib/legend.svelte';
	import Tables from '$lib/tables.svelte';
	import Panel from '$lib/panel.svelte';
	import Modal from '$lib/modal.svelte';
	import Map from '$lib/map.svelte';

	export let censusData,
		census,
		plansTopo,
		data,
		dynamicVars,
		staticVars,
		pluralityVars,
		points;

	let showModal;
	let showMoreOptions = true;
	let showOnlyFocusDistricts = false;
	let changingLines, pointing;
	let aggregates = [];
	let stats = {};
	let isolate = false;
	let showPluralities;

	let panels = ['plan'];

	let plan = 'senate_letters';
	let plan2 = 'senate_unity';

	let opacity = 0.75;

	let containerFont = 18;

	const closeModal = () => (showModal = false);

	let period = 'present';
	let variable = 'vap';
	$: metric = staticVars.includes(variable)
		? variable
		: variable
		? variable + (period === 'past' ? 10 : variable === 'cvap' ? 19 : 20)
		: variable;

	const breaksCache = {
		pop: [0, 0.1, 0.2, 0.4, 0.6],
		cvap: [0, 0.1, 0.2, 0.4, 0.6],
		vap: [0, 0.1, 0.2, 0.4, 0.6]
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

	function color({ properties: d }) {
		if (metric === null) {
			console.trace();
			return null;
		}
		if (!d.ALAND) return 'rgba(0, 0, 0, 0)';
		const total = d[`${metric}_total`];

		if (pluralityVars.includes(metric)) {
			const p = (g) => d[`${metric}_${g}`];
			if (p(periods[0]) === null) return 'rgba(0, 0, 0, 0)';
			const pluralities = [...periods].sort((a, b) => p(b) - p(a));
			return schemeBlues[periods.indexOf(pluralities[0])];
		} else if (staticVars.includes(metric)) {
			if (!isNum(getValue(d))) return 'rgba(0, 0, 0, 0)';
			if (total <= 10) return 'rgba(0, 0, 0, 0)';
			for (let i = 1; i < breaks.length; i++) {
				if (getValue(d) < breaks[i]) return schemeBlues[i];
			}
			return schemeBlues[breaks.length - 1];
		} else {
			if (total <= 10) return 'rgba(0, 0, 0, 0)';
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

	function getStats(input) {
		const data1 = input;
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
		['pop20', 'vap20', 'cvap19', 'pop10', 'vap10', 'cvap10'].forEach((m) =>
			groups.forEach((g) => (output[m + g] = prop(m, g)))
		);
		return output;
	}

	const togglePanel = (p) =>
		(panels = panels.includes(p) ? panels.filter((x) => x !== p) : [...panels, p]);

	$: {
		for (let i = 0; i < aggregates.length; i++) {
			const [aPlan, aDistrict] = aggregates[i].split(',');
			if (aPlan === plan || aPlan === plan2 /* && !(aggregates[i] in stats) */) {
				stats[aggregates[i]] = getStats(censusData.filter((d) => aDistrict === '' + d[aPlan]));
			}
		}
	}

	function handleLabelClick(id, forceInclusion = false, forceExclusion = false) {
		if (aggregates.includes(id)) {
			if (!forceInclusion) {
				aggregates = aggregates.filter((a) => a !== id);
			}
		} else {
			if (!forceExclusion) {
				aggregates = [...aggregates, id];
			}
		}
	}

	const togglePointing = () => (pointing = !pointing);
	function handleKeydown({ key }) {
		if (key === ' ') togglePointing();
		if (key === 'i') isolate = !isolate;
		if (key === '=') containerFont += 2;
		if (key === '-') containerFont -= 2;
		if (key === 'v') showMoreOptions = !showMoreOptions;
		if (key === 's') showOnlyFocusDistricts = !showOnlyFocusDistricts;
	}
</script>

<svelte:window on:keydown={handleKeydown} />

<Modal {showModal} {closeModal} />

<div
	class="container"
	style="--container-font: {containerFont}px; --control-width: {270 + (containerFont - 16) * 10}px;"
>
	<div class="controls">
		<select
			bind:value={variable}
			style="width: {staticVars.includes(variable)
				? 'auto'
				: 'calc(var(--control-width) + 45px * 0)'}"
		>
			<option value={null}>Select data</option>
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
						Show {showPluralities ? 'pct. asian' : 'all races and ethniticies'}
					</button>
				{/if}
			</div>
		{/if}

		{#if metric !== null}
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
		{/if}

		<Panel panelName="plan" {panels} {togglePanel}>
			<div slot="body">
				<div class="plan-selector">
					<select bind:value={plan}>
						{#each ['assembly', 'senate'] as scope}
							<optgroup label={capitalize(scope)}>
								{#each ['', '_letters', '_names', '_unity', '_latfor'] as proposal}
									<option value={scope + proposal}>
										{planDesc(scope + proposal)}
									</option>
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
					{variable}
				/>
			</div>
		</Panel>

		<Panel panelName="plan2" {panels} {togglePanel}>
			<div slot="body">
				<div class="slider">
					<input type="range" bind:value={opacity} min="0" max="1.5" step="0.01" />
				</div>
				<div class="plan-selector">
					<select bind:value={plan2}>
						{#each ['assembly', 'senate'] as scope}
							<optgroup label={capitalize(scope)}>
								{#each ['', '_letters', '_names', '_unity', '_latfor'] as proposal}
									<option value={scope + proposal}>
										{planDesc(scope + proposal)}
									</option>
								{/each}
							</optgroup>
						{/each}
					</select>
				</div>
				<Tables
					{aggregates}
					{handleLabelClick}
					plan={plan2}
					{stats}
					{groups}
					{changingLines}
					{idealValues}
					{variable}
				/>
			</div>
		</Panel>
	</div>

	<Map
		{census}
		{plansTopo}
		{pointing}
		{color}
		{showPluralities}
		{metric}
		{opacity}
		{period}
		{panels}
		{plan}
		{plan2}
		{points}
		{togglePointing}
		{handleLabelClick}
		{isolate}
	/>
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
		left: 22px;
		padding: 15px;
		background: #fff;
		z-index: 1;
		box-shadow: 0px 2px 5px #0006;
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

	.plan-selector {
		margin-bottom: 10px;
	}

	.slider input {
		width: 20px;
	}
</style>
