package game

BASE_ATTACK_DAMAGE :: 4

calc_attack_damage :: proc(block: Block_Type, pop_count: int) -> i32 {
	mult := Block_Attack_Multiplier[block]
	raw := f32(BASE_ATTACK_DAMAGE) * f32(pop_count) * mult
	return i32(raw + 0.5)
}

player_action :: proc(state: ^Game_State, block: Block_Type, pop_count: int) {
	damage := calc_attack_damage(block, pop_count)

	#partial switch block {
	case .Carbohydrates, .Fiber:
		spawn_shield_anim(state, damage)
	case:
		spawn_damage_anim(state, damage, .Enemy)
	}

	state.player_turns += 1
	try_enemy_attack(state)
}

try_enemy_attack :: proc(state: ^Game_State) {
	state.enemy.turns_until_attack -= 1
	if state.enemy.turns_until_attack > 0 do return

	damage := state.enemy.damage
	spawn_damage_anim(state, damage, .Player)

	state.enemy.turns_until_attack = state.enemy.turns_per_attack
}

stage_won :: proc(state: ^Game_State) -> (won: bool) {
	return state.enemy.hp <= 0
}

game_is_over :: proc(state: ^Game_State) -> (over: bool) {
	return state.player.hp <= 0
}

enemy_valid_for_stage :: proc(enemy: Actor, stage: int) -> bool {
    if enemy.max_stage == 0 {
        return i32(stage) >= enemy.min_stage
    }
    return i32(stage) >= enemy.min_stage && i32(stage) <= enemy.max_stage
}

pick_enemy :: proc(stage: int) -> Actor {
    valid := make([dynamic]Actor)

    for enemy in ENEMY_DATABASE {
        if enemy_valid_for_stage(enemy, stage) {
            append(&valid, enemy)
        }
    }

    assert(len(valid) > 0)
    result: Actor = valid[random_int_between(0, i32(len(valid) - 1))]
    result.damage += i32(f32(result.damage * (i32(stage) - 1)) * STAGE_DAMAGE_MULTIPLIER)
    result.max_hp += i32(f32(result.max_hp * (i32(stage) - 1)) * STAGE_HP_MULTIPLIER)
    result.hp = result.max_hp
    delete(valid)
    return result
}

reset_game :: proc(state: ^Game_State) {
	board_init(&state.board)
	state.player = Actor {
		name             = "Player",
        damage           = BASE_ATTACK_DAMAGE,
		hp               = 100,
		max_hp           = 100,
		shield           = 0,
		turns_per_attack = 0,
		color            = {60, 120, 200, 255},
	}

	state.player_turns = 0
	state.search_len = 0
	state.last_meal_len = 0
	state.status_timer = 0
	state.hover_col = -1
	state.hover_row = -1
	state.selected_count = 0
	state.enemy = pick_enemy(state.stage)
	anim_init(&state.anims)
	damage_init(state)
	shield_init(state)
}
