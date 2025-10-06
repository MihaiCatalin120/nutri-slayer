<script lang="ts">
	import GameGrid from '$lib/components/GameGrid.svelte';
	import TooltipBar from '$lib/components/TooltipBar.svelte';
	import FightBar from '$lib/components/FightBar.svelte';
</script>

<div class="flex h-full w-full flex-col gap-2 p-3">
	<FightBar />
	<div class="flex h-3/4 w-full rounded-md border-black bg-white">
		<GameGrid />
		<TooltipBar />
	</div>
</div>
