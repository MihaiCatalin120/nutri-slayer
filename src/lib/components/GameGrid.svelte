<script lang="ts">
	import { type GameBlock } from '../../models/block';

	const blockStyle = ' border cursor-pointer';

	let blocks: Array<GameBlock> = [
		{
			name: 'Protein',
			style: 'bg-red-500' + blockStyle,
			id: 1
		},
		{
			name: 'Fat',
			style: 'bg-yellow-500' + blockStyle,
			id: 2
		},
		{
			name: 'Carbohydrate',
			style: 'bg-yellow-900' + blockStyle,
			id: 3
		},
		{
			name: 'Air',
			style: 'bg-white',
			id: 0
		}
	];

	let isAnimating = $state(false);
	let GRID_WIDTH = 10;
	let GRID_HEIGHT = 8;

	let grid = $state(
		Array.from({ length: GRID_HEIGHT }, () =>
			Array.from({ length: GRID_WIDTH }, () => blocks[Math.floor(Math.random() * blocks.length)])
		)
	);

	function onBlockClick(row: number, column: number, blockID: number) {
		if (isAnimating) return;

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
		if (blockID !== grid[row][column].id) return [];

		visited.add(key);
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
		const airBlock = blocks.find((block) => block.id === 0);

		if (!airBlock) {
			console.error('Air block was not found');
			return;
		}

		isAnimating = true;

		group.forEach((element) => {
			const domElement = document.getElementById(`cell-${element.row}-${element.column}`);
			domElement?.classList.add('animate-pop');
		});

		setTimeout(() => {
			group.forEach((element) => {
				grid[element.row][element.column] = airBlock;
			});
			isAnimating = false;
		}, 500);
	}
</script>

<div class="grid aspect-10/8 h-full grid-cols-10 grid-rows-8 gap-1 p-1">
	{#each grid as column, rowIndex (rowIndex)}
		{#each column as cell, columnIndex (`cell-${columnIndex}-${cell.id}`)}
			<button
				id="cell-{rowIndex}-{columnIndex}"
				aria-label={cell.name}
				data-row={rowIndex}
				data-column={columnIndex}
				class="{cell.style} h-full w-full rounded-md transition hover:scale-[1.1]"
				onclick={() => onBlockClick(rowIndex, columnIndex, cell.id)}
			></button>
		{/each}
	{/each}
</div>
