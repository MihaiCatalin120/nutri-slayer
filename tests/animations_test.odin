package tests

import "core:math"
import "core:testing"
import game "../src"

@(test)
test_ease_functions :: proc(t: ^testing.T) {
	testing.expect_value(t, game.ease_in_quad(0), 0)
	testing.expect_value(t, game.ease_in_quad(1), 1)
	testing.expect_value(t, game.ease_out_quad(0), 0)
	testing.expect_value(t, game.ease_out_quad(1), 1)
	testing.expect(t, game.ease_in_quad(0.5) < 0.5, "ease in should start slow")
	testing.expect(t, game.ease_out_quad(0.5) > 0.5, "ease out should start fast")
}

@(test)
test_compute_gravity_moves :: proc(t: ^testing.T) {
	board: game.Board
	game.board_init(&board)
	set_cell(&board, 0, 0, .Protein)

	moves: [game.MAX_FALL_ANIMS]game.Gravity_Move
	count := game.compute_gravity_moves(&board, &moves)
	testing.expect_value(t, count, 1)
	testing.expect_value(t, moves[0].from_row, 0)
	testing.expect_value(t, moves[0].to_row, game.GRID_ROWS - 1)
}

@(test)
test_anim_locked :: proc(t: ^testing.T) {
	state := make_game_state()
	testing.expect(t, !game.anim_locked(&state), "fresh state should not be locked")
	state.anims.locked = true
	testing.expect(t, game.anim_locked(&state), "locked flag should be respected")
}

@(test)
test_try_pop_group_too_small :: proc(t: ^testing.T) {
	state := make_game_state()
	set_cell(&state.board, 0, 0, .Protein)
	ok := game.try_pop_group(&state, 0, 0)
	testing.expect(t, !ok, "single block group should not pop")
}

@(test)
test_try_pop_group_success :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.turns_until_attack = 99
	set_cell(&state.board, 0, 0, .Protein)
	set_cell(&state.board, 1, 0, .Protein)

	ok := game.try_pop_group(&state, 0, 0)
	testing.expect(t, ok, "pair should pop")
	testing.expect(t, !state.board.cells[0][0].active, "popped cells should be cleared")
	testing.expect(t, state.anims.locked, "pop should lock animations")
}

@(test)
test_update_animations_completes_pop :: proc(t: ^testing.T) {
	state := make_game_state()
	game.add_pop_anim(&state.anims, 0, 0, .Protein)
	state.anims.locked = true

	game.update_animations(&state, game.POP_ANIM_DURATION + 0.1)
	testing.expect(t, !state.anims.pops[0].active, "pop anim should finish")
	testing.expect(t, !state.anims.locked, "lock should release when anims complete")
}

@(test)
test_count_active_anims :: proc(t: ^testing.T) {
	anims: game.Anim_State
	game.add_pop_anim(&anims, 0, 0, .Protein)
	game.add_pop_anim(&anims, 1, 0, .Sugar)
	testing.expect_value(t, game.count_active_pops(&anims), 2)
}
