<script>
	import { planTitle, capitalize, pct, money, deviation } from '$lib/utils';
	export let aggregates,
		handleLabelClick,
		plan,
		stats,
		groups,
		changingLines,
		variable,
		idealValues;
	export let drawings = [];
	export let delDrawing = undefined;

	export let type = 'districts';

	$: varLabel = {'vap': 'Voting-age population', 'pop': 'Population'}[variable];

	$: console.log(stats);
</script>

{#if variable !== null}
	{#if type === 'districts'}
		{#each aggregates as a}
			{#if a.split(',')[0] === plan}
				<div class="district-aggregate">
					<p on:click={() => handleLabelClick(a)}><i>{planTitle(a)}</i></p>
					<p />
					<p class="chart-title">{varLabel} (20{(a.includes('_') ? (variable === 'cvap' ? '19' : '20') : '10')})</p>
					<div class="chart">
						{#each groups as grp}
							<p class="bar-label">{capitalize(grp)}</p>
							<div
								class="bar bar-{grp}"
								style="width: {pct(stats[a][variable + (a.includes('_') ? (variable === 'cvap' ? '19' : '20') : '10') + grp])}"
							>
								<p>{pct(stats[a][variable + (a.includes('_') ? (variable === 'cvap' ? '19' : '20') : '10') + grp], !!(grp === 'asian'))}</p>
							</div>
						{/each}
					</div>
					{#if changingLines && plan in idealValues}
						<p class="table-footer">
							Income: {money(stats[a].income) +
								(changingLines && plan in idealValues
									? '; ' + deviation(stats[a]['pop20_total'] - idealValues[plan])
									: '')}
						</p>
					{/if}
				</div>
			{/if}
		{/each}
	{:else if type === 'community'}
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
	{/if}
{/if}

<style>
	p {
		line-height: 1.25;
	}

	table {
		border-collapse: collapse;
		margin: 0;
		margin-bottom: 4px;
		min-width: 240px;
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
		font-size: 0.93em;
	}

	.table-footer {
		font-size: 0.93em;
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

	.district-aggregate {
		margin-bottom: 11px;
	}

	.district-aggregate p:first-child {
		cursor: pointer;
	}

	.chart {
		display: grid;
		grid-template-columns: auto 1fr;
		column-gap: 8px;
		row-gap: 4px;
	}

	.chart-title {
		font-weight: bold;
		margin-bottom: 5px;
	}

	.bar {
		height: 100%;
		background-color: #ccc;
	}

	.bar p {
		position: relative;
		left: calc(100% + 4px);
		top: 4px;
	}

	.bar-asian {
		background-color: rgb(222, 45, 38);
	}

	.bar-label {
		text-align: right;
	}
</style>
