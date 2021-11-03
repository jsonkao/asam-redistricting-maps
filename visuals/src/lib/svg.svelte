<script>
	import { fade } from 'svelte/transition';
	import { id, D, xor } from '$lib/utils';
	import { focusDistricts } from '$lib/constants';
	import { mesh as topoMesh } from 'topojson-client';

	export let viewBox,
		labelSize,
		draggedBgs,
		data,
		path,
		color,
		changingLines,
		neighbor,
		showPluralities,
		metric,
		period,
		tractVars,
		showComms,
		drawings,
		showPlans,
		plan,
		points = [],
		tractMesh,
		bgMesh,
		mesh,
		aggregates,
		obj,
		handleLabelClick,
		congressPlans,
		plans,
		startDrag,
		endDrag,
		handleMouseMove,
		viewCutoff,
		showOnlyFocusDistricts,
		showStreets,
		streets;

	$: focuses = focusDistricts[plan];
	$: showFocusDistricts = showOnlyFocusDistricts && focuses;
	$: topo = plan.startsWith('congress') ? congressPlans : plans;
	$: obj = topo ? topo.objects[plan] : undefined;
	function getMesh() {
		if (!topo) return;
		if (showFocusDistricts) {
			return path(
				topoMesh(topo, {
					type: obj.type,
					geometries: obj.geometries.filter((g) => focuses.includes(g.properties[plan]))
				})
			);
		}
		return path(topoMesh(topo, obj, (a, b) => D(a) !== D(b)));
	}

	let hoveredDistrict;
</script>

<svg
	viewBox={viewBox.join(' ')}
	on:mousedown={startDrag}
	on:mouseup={endDrag}
	style="--font-size: {labelSize || 0.8}em"
>
	<g class="block-groups">
		{#each data as f, i (id(f))}
			{#if i < viewCutoff}
				<path
					class:head={draggedBgs[0] === id(f)}
					d={path(f)}
					fill={color(f, metric, period, showPluralities)}
					on:click={() => changingLines && plan.includes('_') && neighbor(i)}
					on:contextmenu|preventDefault={() => console.log(f.properties)}
					on:mousemove|preventDefault={() => handleMouseMove(f)}
				/>
			{/if}
		{/each}
	</g>
	<g class="meshes">
		{#if bgMesh}
			<path class="mesh-bg" d={tractVars.includes(metric) ? tractMesh : bgMesh} />
		{/if}

		{#if showComms}
			<g in:fade out:fade>
				{#each drawings as { outline }}
					<path class="mesh-community" d={outline} />
				{/each}
			</g>
		{/if}

		{#if showPlans && !changingLines}
			<g in:fade out:fade>
				<path
					class="mesh-district"
					class:showPluralities
					d={getMesh(plan, plans, congressPlans, showOnlyFocusDistricts)}
				/>
			</g>
		{/if}

		{#if changingLines}
			<g in:fade out:fade>
				<path
					class="mesh-district"
					d={path(mesh((a, b) => a.properties[plan] !== b.properties[plan], obj))}
				/>
			</g>
		{/if}

		{#if showPlans || changingLines}
			<g class="labels" in:fade out:fade>
				{#each points as { properties: p, geometry: { coordinates: [x, y] } }}
					{#if plan in p && (!showFocusDistricts || (showFocusDistricts && focuses.includes(p[plan])))}
						<text
							in:fade
							out:fade
							{x}
							{y}
							class:chosen={aggregates.includes(`${plan},${p[plan]}`)}
							on:click={() => handleLabelClick(`${plan},${p[plan]}`)}
							on:mousemove={() => (hoveredDistrict = p[plan])}
							on:mouseout={() => (hoveredDistrict = null)}
							on:blur={undefined}
						>
							{p[plan]}
						</text>
					{/if}
				{/each}
				{#if hoveredDistrict}
					<path
						class="mesh-onhover mesh-district"
						d={obj &&
							path(
								topoMesh(topo, {
									type: obj.type,
									geometries: obj.geometries.filter((g) => hoveredDistrict === g.properties[plan])
								})
							)}
					/>
				{/if}
			</g>
		{/if}

		{#if showStreets && streets}
			<g class="streets">
				{#each streets as f}
					<path d={path(f)} />
				{/each}
			</g>
		{/if}
	</g>
</svg>

<style>
	svg {
		margin-left: var(--control-width);
		display: block;
		width: calc(100% - var(--control-width) * 1.45);
	}

	svg path.head {
		stroke: black;
		stroke-width: 2;
		stroke-dasharray: 4;
	}

	.streets {
		stroke: black;
		stroke-width: 1;
		fill: none;
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
		stroke-width: 1.1;
	}

	.meshes path.mesh-onhover {
		stroke-width: 2.5;
	}

	.mesh-community {
		stroke: black;
		stroke-width: 1.1;
	}

	.block-groups path {
		transition-duration: 0.2s;
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

	.labels text.chosen,
	.labels text:hover {
		font-weight: 700;
	}
</style>
