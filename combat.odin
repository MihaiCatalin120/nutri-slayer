package main

BASE_ATTACK_DAMAGE :: 4

calc_attack_damage :: proc(block: Block_Type, pop_count: int) -> i32 {
	mult := Block_Attack_Multiplier[block]
	raw := f32(BASE_ATTACK_DAMAGE) * f32(pop_count) * mult
	return i32(raw + 0.5)
}

player_attack :: proc(state: ^Game_State, block: Block_Type, pop_count: int) {
	damage := calc_attack_damage(block, pop_count)
	spawn_damage_anim(state, damage, .Enemy)

	state.player_turns += 1
	try_enemy_attack(state)
}

try_enemy_attack :: proc(state: ^Game_State) {
	state.enemy.turns_until_attack -= 1
	if state.enemy.turns_until_attack > 0 do return

	damage := i32(random_int_between(6, 14))
	spawn_damage_anim(state, damage, .Player)

	state.enemy.turns_until_attack = state.enemy.turns_per_attack
}

game_is_over :: proc(state: ^Game_State) -> (over: bool, player_won: bool) {
	if state.enemy.hp <= 0 do return true, true
	if state.player.hp <= 0 do return true, false
	return false, false
}

reset_game :: proc(state: ^Game_State) {
	board_init(&state.board)
	state.player = Actor{
		name           = "Player",
		hp             = 100,
		max_hp         = 100,
		turns_per_attack = 0,
		color          = {60, 120, 200, 255},
	}
	state.enemy = Actor{
		name               = "Enemy",
		hp                 = 80,
		max_hp             = 80,
		turns_per_attack   = 3,
		turns_until_attack = 3,
		color              = {180, 60, 60, 255},
	}
	state.player_turns = 0
	state.search_len = 0
	state.last_meal_len = 0
	state.status_timer = 0
	state.hover_col = -1
	state.hover_row = -1
	state.selected_count = 0
	anim_init(&state.anims)
	damage_init(state)
}
