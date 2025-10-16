<script lang="ts">
	import GameGrid from '$lib/components/GameGrid.svelte';
	import TooltipBar from '$lib/components/TooltipBar.svelte';
	import FightBar from '$lib/components/FightBar.svelte';
	import { gameState } from '$lib/store/game-state.svelte';
	import { enemies } from '$lib/store/enemies';

	let shouldRefreshEnemy: boolean = $state(true);

	$effect(() => {
		if (shouldRefreshEnemy) {
			const randomEnemy = enemies[Math.floor(gameState.rand() * enemies.length)];
			const initialHP = Math.floor(randomEnemy.baseHP * (1 + gameState.stage / 10));
			const currentDamage = Math.floor(randomEnemy.baseDamage * (1 + gameState.stage / 10));
			gameState.currentEnemy = {
				...randomEnemy,
				initialHP,
				currentHP: initialHP,
				currentDamage,
				turnsUntilAttack: randomEnemy.turnsPerAttack
			};

			shouldRefreshEnemy = false;
		}
	});
</script>

<div class="flex h-full w-full flex-col gap-2 p-3">
	<FightBar />
	<div class="flex h-3/4 w-full rounded-md border-black bg-white">
		<GameGrid />
		<TooltipBar />
	</div>
</div>
