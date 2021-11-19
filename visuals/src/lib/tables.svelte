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

	$: varLabel = variable === 'pop' ? 'Pop.' : variable.toUpperCase();
</script>

{#if type === 'districts'}
	{#each aggregates as a}
		{#if a.split(',')[0].split('_')[0] === plan.split('_')[0]}
			<div class="district-aggregate">
				<p on:click={() => handleLabelClick(a)}><i>{planTitle(a)}</i></p>
				<table>
					<tr>
						<th />
						<!-- <th>2010 {varLabel}</th> -->
						<th>2020 {varLabel}</th>
					</tr>
					{#each groups as grp}
						<tr>
							<td>{capitalize(grp)}</td>
							<!-- <td>{pct(stats[a][variable + '10' + grp])}</td> -->
							<td>{pct(stats[a][variable + (variable === 'pop' ? '20' : '19') + grp])}</td>
						</tr>
					{/each}
				</table>
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
</style>
