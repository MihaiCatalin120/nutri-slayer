<script>
	import { gameState } from '$lib/store/game-state.svelte';
</script>

<div class="flex h-1/4 w-full justify-between rounded-md border-white bg-black px-2 text-white">
	<div class="relative">
		<img src="/images/candy.png" width="150" alt="player" />
		{#if gameState.nextAttackDamage}
			<span class="absolute top-[50%] -right-2 text-white">
				{gameState.nextAttackDamage}
			</span>
		{/if}
	</div>
	{#if gameState.currentEnemy}
		<div class="relative flex items-center justify-center">
			<span class="absolute top-1 text-white">{gameState.currentEnemy.name}</span>
			<img
				src={gameState.currentEnemy.imageUrl}
				class="h-[90%] object-contain"
				width="300"
				alt="enemy"
			/>
			<div
				class="absolute bottom-3 left-0 flex h-5 w-full content-center justify-center rounded-md border-1 border-white bg-green-500"
			>
				<span class="text-sm">
					{gameState.currentEnemy.currentHP} / {gameState.currentEnemy.initialHP}
				</span>
			</div>
		</div>
	{/if}
</div>
