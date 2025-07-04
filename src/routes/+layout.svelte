<script lang="ts">
	import '../app.css';

	let { children } = $props();
</script>

<div class="h-full w-full bg-green-400">
	{@render children()}
</div>
