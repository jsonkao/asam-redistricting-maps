<script>
	import { capitalize } from './utils.js';
	import { translate } from './constants.js';
	import { slide } from 'svelte/transition';

	export let panels, togglePanel, panelName;

	const niceNames = {
		plan: 'Districts' + (translate ? ' / 区域划分' : ''),
		plan2: 'Compare a district',
		views: 'Views' + (translate ? ' / 选择区' : ''),
	}
</script>

<div class="panel">
	<h3>
		<button on:click={() => togglePanel(panelName)}>
			{niceNames[panelName] || capitalize(panelName)}
			{panels.includes(panelName) ? '↑' : '↓'}
		</button>
		<slot name="title" />
	</h3>
	{#if panels.includes(panelName)}
		<div in:slide out:slide>
			<slot name="body" />
		</div>
	{/if}
</div>

<style>
	.panel div {
		margin-bottom: 20px;
	}

	.panel h3 {
		font-size: 1em;
		margin-bottom: 4px;
		cursor: pointer;
	}

	.panel h3 :global(button.subbutton) {
		font-size: 0.88em;
		font-weight: 300;
		text-decoration: underline;
	}
</style>
