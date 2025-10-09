<script>
	import { gameState } from '$lib/store/game-state.svelte';
</script>

<div class="flex h-1/4 w-full justify-between rounded-md border-white bg-black px-2 text-white">
	<div class="relative">
		<img src="/images/bomboana.png" width="150" alt="player" />
		{#if gameState.nextAttackDamage}
			<span class="absolute top-[50%] -right-2 text-white">
				{gameState.nextAttackDamage}
			</span>
		{/if}
	</div>
	<div class="relative flex">
		<img src="/images/fry-gon.png" class="object-contain" width="300" alt="enemy" />
		<div
			class="absolute bottom-3 left-0 h-5 w-full rounded-md border-1 border-white bg-green-500"
		></div>
	</div>
</div>
