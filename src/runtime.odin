package game

import rl "vendor:raylib"

update_game :: proc(app: ^App_State, dt: f32) {
	state := &app.game
	if state.status_timer > 0 {
		state.status_timer -= dt
	}

	update_animations(state, dt)
	update_damage_anims(state, dt)
	update_shield_anims(state, dt)

	if game_is_over(state) {
		if rl.IsKeyPressed(.R) {
			app.screen = .Title
		}
		return
	}

	won := stage_won(state)
	if won {
		state.enemy = pick_enemy(state.stage)
		state.stage += 1
	}

	if !anim_locked(state) {
		search_input_char(state)

		if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.KP_ENTER) {
			submit_search(state)
		}
	}

	mx, my := viewport_mouse()

	state.hover_col = -1
	state.hover_row = -1
	state.selected_count = 0

	if !anim_locked(state) && point_in_game_area(mx, my) {
		col, row, ok := screen_to_cell(mx, my)
		if ok && state.board.cells[row][col].active {
			state.hover_col = col
			state.hover_row = row
			state.selected_count = preview_group_size(&state.board, col, row)
		}
	}

	if !anim_locked(state) && rl.IsMouseButtonPressed(.LEFT) {
		if search_bar_submit_clicked(mx, my) {
			submit_search(state)
		} else if point_in_game_area(mx, my) {
			col, row, ok := screen_to_cell(mx, my)
			if ok {
				try_pop_group(state, col, row)
			}
		}
	}
}
