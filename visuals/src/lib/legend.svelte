<script>
	import { capitalize, pct, money } from '$lib/utils';
	import { schemeBlues, seqColors } from '$lib/constants';

	export let groups,
		levels,
		colors,
		dynamicVars,
		variable,
		metric,
		showPluralities,
		pluralityVars,
		periods,
		breaks;
</script>

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
		style="grid-template-columns: repeat({dynamicVars.includes(variable) ? 5 : 6}, 2.5em);"
	>
		{#each breaks as b, i}
			<div
				style="background-color: {dynamicVars.includes(variable) ? seqColors[i] : schemeBlues[i]};"
			/>
		{/each}
		{#each breaks as b, i}
			<p>
				{(breaks[breaks.length - 1] < 1
					? pct(b, 0)
					: breaks[breaks.length - 1] > 1000
					? money(b)
					: b) + (dynamicVars.includes(variable) && i === breaks.length - 1 ? '+ Asian' : '')}
			</p>
		{/each}
	</div>
{/if}

<style>
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
		font-size: 0.7em;
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
		font-size: 0.8em;
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
</style>
