package tests

import "core:testing"
import game "../src"

@(test)
test_calc_attack_damage :: proc(t: ^testing.T) {
	// 4 * 3 * 1.4 = 16.8 -> 17
	damage := game.calc_attack_damage(.Protein, 3)
	testing.expect_value(t, damage, 17)
}

@(test)
test_game_is_over :: proc(t: ^testing.T) {
	state := make_game_state()
	state.player.hp = 0
	testing.expect(t, game.game_is_over(&state), "zero hp should be game over")

	state.player.hp = 1
	testing.expect(t, !game.game_is_over(&state), "positive hp should not be over")
}

@(test)
test_stage_won :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.hp = 0
	testing.expect(t, game.stage_won(&state), "zero enemy hp should be stage won")
}

@(test)
test_enemy_valid_for_stage :: proc(t: ^testing.T) {
	gingee := game.Actor{min_stage = 1, max_stage = 5}
	testing.expect(t, game.enemy_valid_for_stage(gingee, 3), "stage 3 in gingee range")
	testing.expect(t, !game.enemy_valid_for_stage(gingee, 6), "stage 6 above gingee max")

	open := game.Actor{min_stage = 2, max_stage = 0}
	testing.expect(t, game.enemy_valid_for_stage(open, 10), "max_stage 0 means no upper cap")
	testing.expect(t, !game.enemy_valid_for_stage(open, 1), "below min_stage should fail")
}

@(test)
test_try_enemy_attack :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.damage = 12
	state.enemy.turns_per_attack = 2
	state.enemy.turns_until_attack = 1

	game.try_enemy_attack(&state)

	testing.expect(t, state.damage_anims[0].active, "enemy attack should spawn damage anim")
	testing.expect_value(t, state.damage_anims[0].damage, 12)
	testing.expect_value(t, state.enemy.turns_until_attack, 2)
}

@(test)
test_pick_enemy_stage_scaling :: proc(t: ^testing.T) {
	seed_random()
	enemy := game.pick_enemy(1)
	testing.expect(t, enemy.hp > 0, "picked enemy should have hp")
	testing.expect(t, enemy.hp == enemy.max_hp, "picked enemy hp should match max")

	seed_random()
	stronger := game.pick_enemy(3)
	testing.expect(t, stronger.damage >= enemy.damage || stronger.max_hp >= enemy.max_hp, "later stages scale up")
}

@(test)
test_reset_game :: proc(t: ^testing.T) {
	seed_random()
	state := make_game_state()
	state.stage = 1
	state.player.hp = 0
	game.reset_game(&state)

	testing.expect_value(t, state.player.hp, 100)
	testing.expect_value(t, state.search_len, 0)
	testing.expect(t, state.enemy.hp > 0, "enemy should be assigned")
}

@(test)
test_player_action_shield_blocks :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.turns_until_attack = 99
	game.player_action(&state, .Fiber, 2)
	testing.expect(t, state.shield_anims[0].active, "fiber pop should spawn shield anim")
}

@(test)
test_player_action_attack_blocks :: proc(t: ^testing.T) {
	state := make_game_state()
	state.enemy.turns_until_attack = 99
	game.player_action(&state, .Protein, 2)
	testing.expect(t, state.damage_anims[0].active, "protein pop should spawn enemy damage anim")
	testing.expect(t, state.damage_anims[0].target == .Enemy, "damage should target enemy")
}
