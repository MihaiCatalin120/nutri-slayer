package tests

import "core:testing"
import game "../src"

@(test)
test_board_init_clears_cells :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)

	for row in 0 ..< game.GRID_ROWS {
		for col in 0 ..< game.GRID_COLS {
			testing.expect(t, !board.cells[row][col].active, "cell should be inactive after init")
		}
	}
}

@(test)
test_flood_fill_group_connected :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)
	set_cell(&board, 0, 0, .Protein)
	set_cell(&board, 1, 0, .Protein)
	set_cell(&board, 2, 0, .Sugar)

	visited: [game.GRID_ROWS][game.GRID_COLS]bool
	count := game.flood_fill_group(&board, 0, 0, &visited)
	testing.expect_value(t, count, 2)
}

@(test)
test_preview_group_size_inactive :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)
	testing.expect_value(t, game.preview_group_size(&board, 0, 0), 0)
}

@(test)
test_apply_gravity :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)
	set_cell(&board, 0, 0, .Protein)
	set_cell(&board, 0, 2, .Sugar)

	game.apply_gravity(&board)

	bottom := game.GRID_ROWS - 1
	testing.expect(t, board.cells[bottom][0].active, "lower block should fall to bottom")
	testing.expect(t, board.cells[bottom][0].block == .Sugar, "higher starting row lands on bottom")
	testing.expect(t, board.cells[bottom - 1][0].active, "second block should stack above")
	testing.expect(t, board.cells[bottom - 1][0].block == .Protein, "lower starting row stacks above bottom")
}

@(test)
test_screen_to_cell_inside_board :: proc(t: ^testing.T) {
	cell_w, cell_h, ox, oy := game.board_cell_size()
	col, row, ok := game.screen_to_cell(i32(ox + cell_w * 0.5), i32(oy + cell_h * 0.5))
	testing.expect(t, ok, "point inside board should map to a cell")
	testing.expect_value(t, col, 0)
	testing.expect_value(t, row, 0)
}

@(test)
test_screen_to_cell_outside :: proc(t: ^testing.T) {
	_, _, ok := game.screen_to_cell(-10, -10)
	testing.expect(t, !ok, "point outside board should fail")
}

@(test)
test_set_status :: proc(t: ^testing.T) {
	state := make_game_state()
	game.set_status(&state, "hello")
	testing.expect(t, state.status_timer > 0, "status timer should be set")
	testing.expect(t, state.status_message[0] == 'h', "status message should be stored")
}
