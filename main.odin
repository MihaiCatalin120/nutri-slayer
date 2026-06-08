package main

import rl "vendor:raylib"

update_game :: proc(state: ^Game_State, dt: f32) {
	if state.status_timer > 0 {
		state.status_timer -= dt
	}

	update_animations(state, dt)
	update_damage_anims(state, dt)
	update_shield_anims(state, dt)

	over := game_is_over(state)
	if over {
		if rl.IsKeyPressed(.R) {
			reset_game(state)
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

main :: proc() {
	monitor := i32(0)
	screen_w := rl.GetMonitorWidth(monitor)
	screen_h := rl.GetMonitorHeight(monitor)

	rl.SetConfigFlags({.MSAA_4X_HINT, .FULLSCREEN_MODE, .WINDOW_RESIZABLE})
	rl.InitWindow(screen_w, screen_h, "nutri-slayer")
	rl.SetWindowMinSize(640, 360)
	rl.SetTargetFPS(60)

	state: Game_State
	reset_game(&state)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		viewport_update()
		update_game(&state, dt)

		viewport_begin_frame()
		draw_ui(&state)
		viewport_end_frame()
	}

	rl.CloseWindow()
}
