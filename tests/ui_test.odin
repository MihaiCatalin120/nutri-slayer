package tests

import "core:testing"
import game "../src"

@(test)
test_point_in_game_area :: proc(t: ^testing.T) {
	cx := game.GAME_X + game.GAME_W / 2
	cy := game.GAME_Y + game.GAME_H / 2
	testing.expect(t, game.point_in_game_area(cx, cy), "center of game area should be inside")

	testing.expect(t, !game.point_in_game_area(0, 0), "top-left panel should be outside game area")
	testing.expect(t, !game.point_in_game_area(game.GAME_X - 1, cy), "just left of game area should be outside")
}

@(test)
test_board_cell_size_fills_game_area :: proc(t: ^testing.T) {
	cell_w, cell_h, _, _ := game.board_cell_size()
	grid_w := cell_w * f32(game.GRID_COLS)
	grid_h := cell_h * f32(game.GRID_ROWS)
	testing.expect_value(t, grid_w, f32(game.GAME_W))
	testing.expect_value(t, grid_h, f32(game.GAME_H))
}

@(test)
test_search_bar_submit_region :: proc(t: ^testing.T) {
	y := game.WINDOW_H - game.SEARCH_H
	box_y := y + 12
	btn_x := game.WINDOW_W - 130
	inside_x := btn_x + 55
	inside_y := box_y + 16
	testing.expect(t, game.search_bar_submit_clicked(inside_x, inside_y), "eat button center should register")

	testing.expect(t, !game.search_bar_submit_clicked(0, 0), "top-left should not hit eat button")
}
