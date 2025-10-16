<script lang="ts">
	import { onMount } from 'svelte';
	import { gameState } from '$lib/store/game-state.svelte';
	import * as blocks from '$lib/store/game-blocks';
	import { type GameBlock } from '../../models/block';

	let isAnimating = $state(false);
	let GRID_WIDTH = 10;
	let GRID_HEIGHT = 8;
	let grid: GameBlock[][] | null = $state(null);

	let cellElements: Record<string, HTMLButtonElement> = $state({});
	onMount(() => {
		grid = Array.from({ length: GRID_HEIGHT }, () =>
			Array.from(
				{ length: GRID_WIDTH },
				() => blocks.all[Math.floor(gameState.rand() * blocks.all.length)]
			)
		);

		setTimeout(() => {
			applyGravity();
		}, 200);
	});

	function onBlockClick(row: number, column: number, blockID: number) {
		if (isAnimating) return;
		if (blockID === blocks.air.id) return;

		let visited: Set<string> = new Set<string>();

		const group = findConnectedGroup(row, column, blockID, visited);

		if (group.length >= 3) {
			popGroup(group);
		}
	}

	function findConnectedGroup(
		row: number,
		column: number,
		blockID: number,
		visited: Set<string>
	): Array<{ row: number; column: number }> {
		if (!grid) return [];
		const key = `${row}${column}`;

		if (visited.has(key)) return [];
		if (row < 0 || row >= GRID_HEIGHT || column < 0 || column >= GRID_WIDTH) return [];

		visited.add(key);
		if (blockID !== grid[row][column].id) return [];
		let group = [{ row, column }];
		const directions = [
			[-1, 0],
			[1, 0],
			[0, -1],
			[0, 1]
		];

		for (let [rowDirection, columnDirection] of directions) {
			group = group.concat(
				findConnectedGroup(row + rowDirection, column + columnDirection, blockID, visited)
			);
		}

		return group;
	}

	function popGroup(group: Array<{ row: number; column: number }>) {
		isAnimating = true;

		gameState.nextAttackDamage = 0;

		group.forEach((cell) => {
			if (!grid) return;

			gameState.nextAttackDamage += grid[cell.row][cell.column].baseDamage;
			gameState.nextAttackDamage *= grid[cell.row][cell.column].damageMultiplier;
		});

		gameState.nextAttackDamage = Math.round(gameState.nextAttackDamage);

		group.forEach((element) => {
			const domBlock = cellElements[`cell-${element.row}-${element.column}`];
			domBlock?.classList.add('animate-pop');

			setTimeout(() => {
				if (grid) grid[element.row][element.column] = blocks.air;
			}, 200);
		});

		setTimeout(() => {
			applyGravity().then(() => {
				isAnimating = false;
			});
		}, 200);
	}

	function applyGravity(): Promise<void> {
		return new Promise((resolve) => {
			let animationPromises: Promise<void>[] = [];

			for (let column = 0; column < GRID_WIDTH; column++) {
				let fallingBlocks = [];
				let targetRow = GRID_HEIGHT - 1;

				// collect non-air blocks
				for (let row = GRID_HEIGHT - 1; row >= 0; row--) {
					if (grid && grid[row][column].id !== blocks.air.id) {
						if (row !== targetRow) {
							fallingBlocks.push({
								from: row,
								to: targetRow,
								element: grid[row][column]
							});
						}
						targetRow--;
					}
				}

				// animate falling blocks
				fallingBlocks.forEach((block) => {
					if (block.element.id !== blocks.air.id) {
						const fallDistance = (block.to - block.from) * 84; // block height + gap
						cellElements[`cell-${block.from}-${column}`].style.setProperty(
							'--fall-distance',
							`${fallDistance}px`
						);
						cellElements[`cell-${block.from}-${column}`].classList.add('animate-fall');

						const promise: Promise<void> = new Promise((resolve) => {
							setTimeout(() => {
								cellElements[`cell-${block.from}-${column}`].classList.remove('animate-fall');

								resolve();
							}, 600);
						});
						animationPromises.push(promise);
					}
				});
			}

			Promise.all(animationPromises).then(() => {
				for (let column = 0; column < GRID_WIDTH; column++) {
					let columnBlocks: GameBlock[] = [];

					for (let row = 0; row < GRID_HEIGHT; row++) {
						if (!grid) break; // There has to be a better way of dealing with this
						if (grid[row][column].id !== blocks.air.id) columnBlocks.push(grid[row][column]);
						grid[row][column] = blocks.air;
					}

					for (let row = GRID_HEIGHT - 1; row >= 0; row--) {
						if (!grid) break; // Here too, see upper comment
						grid[row][column] = columnBlocks.pop() || blocks.air;
					}
				}

				resolve();
			});
		});
	}

	function setHoveredBlock(row: number, column: number) {
		if (grid) gameState.hoveredBlock = grid[row][column];
	}
</script>

{#if grid}
	<div class="grid aspect-10/8 h-full grid-cols-10 grid-rows-8 gap-1 p-1">
		{#each grid as column, rowIndex (rowIndex)}
			{#each column as cell, columnIndex (`cell-${rowIndex}-${columnIndex}-${cell.id}`)}
				<button
					id="cell-{rowIndex}-{columnIndex}"
					bind:this={cellElements[`cell-${rowIndex}-${columnIndex}`]}
					aria-label={cell.name}
					class="{cell.style} h-full w-full rounded-md transition"
					onclick={() => onBlockClick(rowIndex, columnIndex, cell.id)}
					onfocus={() => setHoveredBlock(rowIndex, columnIndex)}
					onmouseover={() => setHoveredBlock(rowIndex, columnIndex)}
				></button>
			{/each}
		{/each}
	</div>
{/if}
