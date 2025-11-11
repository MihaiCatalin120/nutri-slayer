<script lang="ts">
	import { gameState } from '$lib/store/game-state.svelte';
</script>

<div class="flex w-full flex-col gap-2 p-4">
	<div class="h-1/2 w-full rounded-xl bg-red-300 p-2">Enemy info</div>
	<div class="flex h-1/2 w-full flex-col rounded-xl bg-green-300 p-2">
		{#if gameState.hoveredBlock}
			<p>{gameState.hoveredBlock.name}</p>
			<p>{gameState.hoveredBlock.description}</p>
			<div class="flex gap-3">
				<div class="flex gap-2">
					<img src="/icons/sword-line.svg" width="24" alt="damage" />
					<span>{gameState.hoveredBlock.baseDamage}</span>
				</div>
				<div class="flex gap-2">
					<img src="/icons/line-chart-line.svg" width="24" alt="damage" />
					<span>{gameState.hoveredBlock.damageMultiplier}</span>
				</div>
			</div>
		{/if}

		<span class="ms-auto mt-auto text-xs">{gameState.seed}</span>
	</div>
</div>
