<script lang="ts">
	import { type GameBlock } from '../../models/block';
	import { onMount } from 'svelte';

	const blockStyle = ' border cursor-pointer';

	const protein = {
		name: 'Protein',
		style: 'bg-red-500' + blockStyle,
		id: 1
	};

	const fat = {
		name: 'Fat',
		style: 'bg-yellow-500' + blockStyle,
		id: 2
	};

	const carbohydrate = {
		name: 'Carbohydrate',
		style: 'bg-yellow-900' + blockStyle,
		id: 3
	};

	const air = {
		name: 'Air',
		style: 'bg-white',
		id: 0
	};

	let blocks: Array<GameBlock> = [protein, fat, carbohydrate, air];

	let isAnimating = $state(false);
	let GRID_WIDTH = 10;
	let GRID_HEIGHT = 8;

	let grid = $state(
		Array.from({ length: GRID_HEIGHT }, () =>
			Array.from({ length: GRID_WIDTH }, () => blocks[Math.floor(Math.random() * blocks.length)])
		)
	);
	let cellElements: Record<string, HTMLButtonElement> = $state({});
	onMount(() => {
		applyGravity();
	});

	function onBlockClick(row: number, column: number, blockID: number) {
		if (isAnimating) return;
		if (blockID === air.id) return;

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

		group.forEach((element) => {
			const domBlock = cellElements[`cell-${element.row}-${element.column}`];
			domBlock?.classList.add('animate-pop');

			setTimeout(() => {
				grid[element.row][element.column] = air;
			}, 500);
		});

		setTimeout(() => {
			applyGravity().then(() => {
				// TODO: add scores and moves
				//
				isAnimating = false;
			});
		}, 500);
	}

	function applyGravity(): Promise<void> {
		return new Promise((resolve) => {
			let animationPromises: Promise<void>[] = [];

			for (let column = 0; column < GRID_WIDTH; column++) {
				let fallingBlocks = [];
				let targetRow = GRID_HEIGHT - 1;

				// collect non-air blocks
				for (let row = GRID_HEIGHT - 1; row >= 0; row--) {
					if (grid[row][column].id !== air.id) {
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
					if (block.element.id !== air.id) {
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
						if (grid[row][column].id !== air.id) columnBlocks.push(grid[row][column]);
						grid[row][column] = air;
					}

					for (let row = GRID_HEIGHT - 1; row > 0; row--) {
						grid[row][column] = columnBlocks.pop() || air;
					}
				}

				resolve();
			});
		});
	}
</script>

<div class="grid aspect-10/8 h-full grid-cols-10 grid-rows-8 gap-1 p-1">
	{#each grid as column, rowIndex (rowIndex)}
		{#each column as cell, columnIndex (`cell-${rowIndex}-${columnIndex}-${cell.id}`)}
			<button
				id="cell-{rowIndex}-{columnIndex}"
				bind:this={cellElements[`cell-${rowIndex}-${columnIndex}`]}
				aria-label={cell.name}
				class="{cell.style} h-full w-full rounded-md transition hover:scale-[1.1]"
				onclick={() => onBlockClick(rowIndex, columnIndex, cell.id)}
			></button>
		{/each}
	{/each}
</div>
