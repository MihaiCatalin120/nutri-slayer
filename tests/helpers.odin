package tests

import game "../src"
import rl "vendor:raylib"

seed_random :: proc() {
	rl.SetRandomSeed(1234)
}

make_game_state :: proc() -> game.Game_State {
	state: game.Game_State
	game.board_init(&state.board)
	game.anim_init(&state.anims)
	game.damage_init(&state)
	game.shield_init(&state)
	return state
}

set_cell :: proc(board: ^game.Board, col, row: int, block: game.Block_Type) {
	board.cells[row][col] = game.Cell{active = true, block = block}
}

fill_column_bottom :: proc(board: ^game.Board, col: int, block: game.Block_Type, count: int) {
	placed := 0
	for row := game.GRID_ROWS - 1; row >= 0 && placed < count; row -= 1 {
		set_cell(board, col, row, block)
		placed += 1
	}
}
