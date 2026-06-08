package tests

import "core:testing"
import game "../src"

@(test)
test_layout_constants :: proc(t: ^testing.T) {
	testing.expect_value(t, game.GAME_X + game.GAME_W + game.PANEL_W, game.WINDOW_W)
	testing.expect_value(t, game.ARENA_H + game.SEARCH_H, game.WINDOW_H)
	testing.expect(t, game.GAME_W > 0, "game area should have width")
	testing.expect(t, game.GAME_H > 0, "game area should have height")
}

@(test)
test_grid_dimensions :: proc(t: ^testing.T) {
	testing.expect_value(t, game.GRID_COLS, 9)
	testing.expect_value(t, game.GRID_ROWS, 9)
	testing.expect_value(t, game.MIN_POP_SIZE, 2)
}

@(test)
test_block_type_count :: proc(t: ^testing.T) {
	testing.expect_value(t, game.NUM_BLOCK_TYPES, 6)
	testing.expect_value(t, len(game.Block_Colors), game.NUM_BLOCK_TYPES)
	testing.expect_value(t, len(game.Block_Attack_Multiplier), game.NUM_BLOCK_TYPES)
}
