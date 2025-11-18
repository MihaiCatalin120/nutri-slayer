<script>
	import { gameState } from '$lib/store/game-state.svelte';
</script>

<div class="flex h-1/4 w-full justify-between rounded-md border-white bg-black px-2 text-white">
	<div class="relative">
		<img src="/images/player.png" class="h-full" alt="player" />
		{#if gameState.nextAttackDamage}
			<span class="absolute top-[50%] -right-2 text-white">
				{gameState.nextAttackDamage}
			</span>
		{/if}
		<div
			class="absolute bottom-3 left-0 flex h-5 w-full items-center justify-center rounded-md border-1 border-white bg-green-500 text-black"
		>
			{gameState.currentHP}/{gameState.maxHP}
		</div>
	</div>
	<div class="relative flex">
		{#if gameState.currentEnemy}
			<img src={gameState.currentEnemy.imageUrl} class="object-contain" width="300" alt="enemy" />
			<div
				class="absolute bottom-3 left-0 flex h-5 w-full items-center justify-center rounded-md border-1 border-white bg-green-500 text-black"
			>
				{gameState.currentEnemy?.currentHP}/{gameState.currentEnemy?.totalHP}
			</div>
		{/if}
	</div>
</div>
