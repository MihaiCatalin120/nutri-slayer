package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

FOOD_DATABASE: []Food_Item = {
	{
		name = "green salad",
		terms = {"green salad", "salad", "lettuce"},
		probs = {0.12, 0.22, 0.30, 0.28, 0.03, 0.05},
	},
	{
		name = "burger",
		terms = {"burger", "hamburger", "cheeseburger"},
		probs = {0.28, 0.22, 0.04, 0.18, 0.22, 0.06},
	},
	{
		name = "sandwich",
		terms = {"sandwich", "sub", "panini"},
		probs = {0.22, 0.30, 0.08, 0.15, 0.12, 0.13},
	},
	{
		name = "apple",
		terms = {"apple", "fruit"},
		probs = {0.02, 0.18, 0.28, 0.02, 0.00, 0.50},
	},
	{
		name = "chicken breast",
		terms = {"chicken", "chicken breast", "grilled chicken"},
		probs = {0.72, 0.00, 0.00, 0.18, 0.08, 0.02},
	},
	{
		name = "pasta",
		terms = {"pasta", "spaghetti", "noodles"},
		probs = {0.14, 0.58, 0.06, 0.06, 0.08, 0.08},
	},
	{
		name = "avocado toast",
		terms = {"avocado", "avocado toast", "toast"},
		probs = {0.08, 0.32, 0.18, 0.38, 0.02, 0.02},
	},
	{
		name = "donut",
		terms = {"donut", "doughnut", "pastry"},
		probs = {0.06, 0.38, 0.02, 0.10, 0.18, 0.26},
	},
}

find_food :: proc(query: string) -> (^Food_Item, bool) {
	trimmed := strings.trim_space(query)
	if len(trimmed) == 0 {
		return nil, false
	}

	lower := strings.to_lower(trimmed, context.temp_allocator)

	for i in 0 ..< len(FOOD_DATABASE) {
		item := &FOOD_DATABASE[i]
		for term in item.terms {
			if lower == strings.to_lower(term, context.temp_allocator) {
				return item, true
			}
		}
	}

	return nil, false
}

pick_block_from_probs :: proc(probs: [NUM_BLOCK_TYPES]f32) -> Block_Type {
	roll := f32(random_int_between(0, 9999)) / 10000.0
	accum: f32 = 0
	for i in 0 ..< NUM_BLOCK_TYPES {
		accum += probs[i]
		if roll < accum {
			return Block_Type(i)
		}
	}
	return .Sugar
}

count_empty_cells :: proc(board: ^Board) -> int {
	count := 0
	for row in 0 ..< GRID_ROWS {
		for col in 0 ..< GRID_COLS {
			if !board.cells[row][col].active {
				count += 1
			}
		}
	}
	return count
}

// Spawns blocks into the topmost empty slots per column.
spawn_food_blocks :: proc(state: ^Game_State, food: ^Food_Item) -> int {
	board := &state.board
	spawned := 0

	for col in 0 ..< GRID_COLS {
		empty_count := 0
		for row in 0 ..< GRID_ROWS {
			if !board.cells[row][col].active {
				empty_count += 1
			}
		}

		to_fill := empty_count / 2
		if to_fill < 1 && empty_count > 0 {
			to_fill = 1
		}

		placed := 0
		for row in 0 ..< GRID_ROWS {
			if placed >= to_fill do break
			if !board.cells[row][col].active {
				board.cells[row][col] = Cell{
					active = true,
					block  = pick_block_from_probs(food.probs),
				}
				spawned += 1
				placed += 1
			}
		}
	}

	if spawned > 0 {
		start_gravity_anims(state)
	}
	return spawned
}

search_input_char :: proc(state: ^Game_State) {
	ch := rl.GetCharPressed()
	for ch > 0 {
		if ch >= 32 && ch <= 126 && state.search_len < len(state.search_buffer) - 1 {
			state.search_buffer[state.search_len] = u8(ch)
			state.search_len += 1
		}
		ch = rl.GetCharPressed()
	}

	if rl.IsKeyPressed(.BACKSPACE) && state.search_len > 0 {
		state.search_len -= 1
	}

	if rl.IsKeyPressed(.UP) && state.last_meal_len > 0 {
		n := min(state.last_meal_len, len(state.search_buffer) - 1)
		for i in 0 ..< n {
			state.search_buffer[i] = state.last_meal[i]
		}
		state.search_len = n
	}
}

submit_search :: proc(state: ^Game_State) {
	query := string(state.search_buffer[:state.search_len])
	food, found := find_food(query)

	if !found {
		set_status(state, "Unknown food — try: salad, burger, sandwich…")
		return
	}

	if anim_locked(state) do return

	spawned := spawn_food_blocks(state, food)
	if spawned == 0 {
		set_status(state, "Board is full — pop blocks first!")
		return
	}

	msg := fmt.tprintf("Added %d blocks from %s", spawned, food.name)
	set_status(state, msg)

	n := min(state.search_len, len(state.last_meal) - 1)
	for i in 0 ..< n {
		state.last_meal[i] = state.search_buffer[i]
	}
	state.last_meal_len = n
	state.search_len = 0
}
