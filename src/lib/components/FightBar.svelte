<script>
	import { gameState } from '$lib/store/game-state.svelte';

	let percentageEnemyHP = $derived(
		Math.floor(
			((gameState.currentEnemy?.currentHP || 1) * 100) / (gameState.currentEnemy?.totalHP || 1)
		)
	);

	let enemyHPBackground = $derived.by(() => {
		let color = 'bg-green-500';

		if (percentageEnemyHP < 75) color = 'bg-yellow-500';
		if (percentageEnemyHP < 25) color = 'bg-red-500';

		return color;
	});
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
			<img
				src={gameState.currentEnemy.imageUrl}
				class="object-contain {gameState.currentEnemy.currentHP <= 0 && 'animate-pop'}"
				width="300"
				alt="enemy"
			/>
			<div
				class="absolute bottom-3 left-0 h-5 w-full overflow-hidden rounded-md border-1 border-white"
			>
				<div class="relative h-full w-full">
					<div
						class="absolute bottom-0 left-0 z-10 flex h-full items-center justify-center text-black {enemyHPBackground}"
						style="width: {percentageEnemyHP}%"
					></div>
					<div
						class="absolute bottom-0 left-0 z-20 flex h-full w-full items-center justify-center bg-transparent text-black"
					>
						{gameState.currentEnemy?.currentHP}/{gameState.currentEnemy?.totalHP}
					</div>
					<div class="absolute bottom-0 left-0 h-full w-full bg-white"></div>
				</div>
			</div>
		{/if}
	</div>
</div>
