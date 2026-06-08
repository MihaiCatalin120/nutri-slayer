package tests

import "core:math"
import "core:testing"
import game "../src"

@(test)
test_find_food_exact_match :: proc(t: ^testing.T) {
	food, found := game.find_food("salad")
	testing.expect(t, found, "salad alias should match")
	testing.expect(t, food.name == "green salad", "salad should resolve to green salad")
}

@(test)
test_find_food_case_insensitive :: proc(t: ^testing.T) {
	_, found := game.find_food("BURGER")
	testing.expect(t, found, "search should be case insensitive")
}

@(test)
test_find_food_unknown :: proc(t: ^testing.T) {
	_, found := game.find_food("xyznotafood")
	testing.expect(t, !found, "unknown food should not match")
}

@(test)
test_count_empty_cells :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)
	testing.expect_value(t, game.count_empty_cells(&board), game.GRID_ROWS * game.GRID_COLS)

	set_cell(&board, 0, 0, .Protein)
	testing.expect_value(t, game.count_empty_cells(&board), game.GRID_ROWS*game.GRID_COLS - 1)
}

@(test)
test_spawn_food_blocks :: proc(t: ^testing.T) {
	seed_random()
	state := make_game_state()
	food, _ := game.find_food("apple")
	spawned := game.spawn_food_blocks(&state, food)
	testing.expect(t, spawned > 0, "spawn should place blocks on empty board")
	testing.expect(t, game.count_empty_cells(&state.board) < game.GRID_ROWS * game.GRID_COLS, "board should have blocks")
}

@(test)
test_food_probabilities_sum :: proc(t: ^testing.T) {
	for item in game.FOOD_DATABASE {
		if len(item.name) == 0 do continue
		sum: f32 = 0
		for p in item.probs {
			sum += p
		}
		testing.expectf(t, math.abs(sum - 1.0) < 0.001, "food %q probs should sum to 1, got %f", item.name, sum)
	}
}

@(test)
test_spawn_food_blocks_full_board :: proc(t: ^testing.T) {
	state := make_game_state()
	for row in 0 ..< game.GRID_ROWS {
		for col in 0 ..< game.GRID_COLS {
			set_cell(&state.board, col, row, .Sugar)
		}
	}
	food, _ := game.find_food("apple")
	spawned := game.spawn_food_blocks(&state, food)
	testing.expect_value(t, spawned, 0)
}
