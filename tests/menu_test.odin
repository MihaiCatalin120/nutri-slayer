package tests

import "core:testing"
import game "../src"

@(test)
test_resolution_label :: proc(t: ^testing.T) {
	testing.expect(t, len(game.resolution_label(.Monitor_Native)) > 0, "monitor label should exist")
	testing.expect(t, game.resolution_label(.R_1920x1080) == "1920 x 1080", "fixed resolution label")
}

@(test)
test_fps_option_index :: proc(t: ^testing.T) {
	testing.expect_value(t, game.fps_option_index(60), 1)
	testing.expect_value(t, game.fps_option_index(999), 1)
}

@(test)
test_next_fps_cycles :: proc(t: ^testing.T) {
	testing.expect_value(t, game.next_fps(60, 1), 120)
	testing.expect_value(t, game.next_fps(120, 1), 30)
	testing.expect_value(t, game.next_fps(30, -1), 120)
}

@(test)
test_next_resolution_cycles :: proc(t: ^testing.T) {
	testing.expect_value(t, game.next_resolution(.Monitor_Native, 1), game.Resolution_Preset.R_1280x720)
	last := game.next_resolution(.R_2560x1440, 1)
	testing.expect_value(t, last, game.Resolution_Preset.Monitor_Native)
}

@(test)
test_menu_button_hovered :: proc(t: ^testing.T) {
	testing.expect(t, game.menu_button_hovered(10, 10, 0, 0, 100, 100), "point inside button")
	testing.expect(t, !game.menu_button_hovered(200, 200, 0, 0, 100, 100), "point outside button")
}

@(test)
test_start_new_game :: proc(t: ^testing.T) {
	seed_random()
	app := game.App_State{screen = .Title}
	app.game.stage = 5
	game.start_new_game(&app)
	testing.expect(t, app.screen == .Playing, "should switch to playing")
	testing.expect_value(t, app.game.stage, 1)
	testing.expect_value(t, app.game.player.hp, 100)
}

@(test)
test_setting_row_input_arrows :: proc(t: ^testing.T) {
	// No mouse press — just verify hover regions exist without crashing.
	_, _ = game.setting_row_input(280, game.SETTING_ROW_X + 10, 300)
}
