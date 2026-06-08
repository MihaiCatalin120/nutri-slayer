package tests

import "core:testing"
import game "../src"

@(test)
test_apply_damage_to_enemy :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.hp = 50
	anim := game.Damage_Anim{damage = 15, target = .Enemy}
	game.apply_damage(&state, &anim)
	testing.expect_value(t, state.enemy.hp, 35)
}

@(test)
test_apply_damage_to_player_with_shield :: proc(t: ^testing.T) {
	state := make_game_state()
	state.player.hp = 100
	state.player.shield = 10
	anim := game.Damage_Anim{damage = 25, target = .Player}
	game.apply_damage(&state, &anim)
	testing.expect_value(t, state.player.shield, 0)
	testing.expect_value(t, state.player.hp, 85)
}

@(test)
test_apply_damage_does_not_go_negative :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.hp = 5
	anim := game.Damage_Anim{damage = 20, target = .Enemy}
	game.apply_damage(&state, &anim)
	testing.expect_value(t, state.enemy.hp, 0)
}

@(test)
test_spawn_damage_anim :: proc(t: ^testing.T) {
	state := make_game_state()
	game.spawn_damage_anim(&state, 8, .Enemy)
	testing.expect(t, state.damage_anims[0].active, "damage anim should be active")
	testing.expect_value(t, state.damage_anims[0].damage, 8)
}

@(test)
test_damage_anim_position_hold :: proc(t: ^testing.T) {
	anim := game.Damage_Anim{start_x = 10, start_y = 20, flying = false}
	x, y := game.damage_anim_position(&anim)
	testing.expect_value(t, x, 10)
	testing.expect_value(t, y, 20)
}

@(test)
test_damage_anim_position_fly :: proc(t: ^testing.T) {
	anim := game.Damage_Anim {
		start_x = 0,
		start_y = 0,
		end_x   = 100,
		end_y   = 100,
		flying  = true,
		fly_t   = 1,
	}
	x, y := game.damage_anim_position(&anim)
	testing.expect_value(t, x, 100)
	testing.expect_value(t, y, 100)
}

@(test)
test_actor_sprite_rect :: proc(t: ^testing.T) {
	px, py, ps := game.actor_sprite_rect(true)
	ex, ey, es := game.actor_sprite_rect(false)
	testing.expect_value(t, ps, es)
	testing.expect(t, ex > px, "enemy sprite should be on the right side")
	testing.expect_value(t, py, ey)
}
