package tests

import "core:testing"
import game "../src"

@(test)
test_apply_shield :: proc(t: ^testing.T) {
	state := make_game_state()
	state.player.shield = 5
	anim := game.Shield_Anim{shield = 10}
	game.apply_shield(&state, &anim)
	testing.expect_value(t, state.player.shield, 15)
}

@(test)
test_spawn_shield_anim :: proc(t: ^testing.T) {
	state := make_game_state()
	game.spawn_shield_anim(&state, 7)
	testing.expect(t, state.shield_anims[0].active, "shield anim should be active")
	testing.expect_value(t, state.shield_anims[0].shield, 7)
}

@(test)
test_spawn_shield_anim_ignores_zero :: proc(t: ^testing.T) {
	state := make_game_state()
	game.spawn_shield_anim(&state, 0)
	testing.expect(t, !state.shield_anims[0].active, "zero shield should not spawn anim")
}

@(test)
test_shield_anim_position :: proc(t: ^testing.T) {
	anim := game.Shield_Anim {
		start_x = 50,
		start_y = 60,
		end_x   = 200,
		end_y   = 80,
		flying  = true,
		fly_t   = 0.5,
	}
	x, y := game.shield_anim_position(&anim)
	testing.expect(t, x > 50 && x < 200, "flying shield should be between start and end x")
	testing.expect(t, y > 60 && y < 80, "flying shield should be between start and end y")
}

@(test)
test_shield_spawn_point_center :: proc(t: ^testing.T) {
	x, y := game.shield_spawn_point()
	testing.expect_value(t, x, f32(game.WINDOW_W / 2))
	testing.expect_value(t, y, f32(game.WINDOW_H / 2))
}
