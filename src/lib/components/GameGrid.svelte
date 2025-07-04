<script lang="ts">
	import { type GameBlock } from '../../models/block';
	let blocks: Array<GameBlock> = [
		{
			name: 'Protein',
			color: 'bg-red-500',
			id: 1
		},
		{
			name: 'Fat',
			color: 'bg-yellow-500',
			id: 2
		},
		{
			name: 'Carbohydrate',
			color: 'bg-yellow-900',
			id: 3
		}
	];

	let grid = $state(
		Array.from({ length: 8 }, () =>
			Array.from({ length: 10 }, () => blocks[Math.floor(Math.random() * blocks.length)])
		)
	);

	grid.map(() => {
		return new Array(10);
	});
</script>

<div class="grid aspect-10/8 h-full grid-cols-10 grid-rows-8 gap-1 p-1">
	{#each grid as column, index (index)}
		{#each column as cell, index (`cell-${index}-${cell.id}`)}
			<div
				class="{cell.color} h-full w-full cursor-pointer rounded-md border transition hover:scale-[1.1]"
			></div>
		{/each}
	{/each}
</div>
