package main

Gravity_Move :: struct {
	col, from_row, to_row: int,
	block: Block_Type,
}

anim_init :: proc(anims: ^Anim_State) {
	anims^ = {}
}

anim_locked :: proc(state: ^Game_State) -> bool {
	return state.anims.locked
}

ease_out_quad :: proc(t: f32) -> f32 {
	v := clamp(t, 0, 1)
	return 1 - (1 - v) * (1 - v)
}

ease_in_quad :: proc(t: f32) -> f32 {
	v := clamp(t, 0, 1)
	return v * v
}

compute_gravity_moves :: proc(board: ^Board, moves: ^[MAX_FALL_ANIMS]Gravity_Move) -> int {
	count := 0

	for col in 0 ..< GRID_COLS {
		write_row := GRID_ROWS - 1

		for read_row := GRID_ROWS - 1; read_row >= 0; read_row -= 1 {
			cell := board.cells[read_row][col]
			if !cell.active do continue

			if read_row != write_row {
				moves[count] = Gravity_Move{col, read_row, write_row, cell.block}
				count += 1
			}
			write_row -= 1
		}
	}

	return count
}

add_fall_anim :: proc(anims: ^Anim_State, col, from_row, to_row: int, block: Block_Type) {
	for i in 0 ..< MAX_FALL_ANIMS {
		if !anims.falls[i].active {
			anims.falls[i] = Fall_Anim{
				active   = true,
				col      = col,
				from_row = f32(from_row),
				to_row   = to_row,
				block    = block,
			}
			return
		}
	}
}

add_pop_anim :: proc(anims: ^Anim_State, col, row: int, block: Block_Type) {
	for i in 0 ..< MAX_POP_ANIMS {
		if !anims.pops[i].active {
			anims.pops[i] = Pop_Anim{active = true, col = col, row = row, block = block}
			return
		}
	}
}

start_gravity_anims :: proc(state: ^Game_State) {
	moves: [MAX_FALL_ANIMS]Gravity_Move
	move_count := compute_gravity_moves(&state.board, &moves)
	apply_gravity(&state.board)

	if move_count == 0 do return

	for i in 0 ..< move_count {
		m := moves[i]
		add_fall_anim(&state.anims, m.col, m.from_row, m.to_row, m.block)
	}
	state.anims.locked = true
}

count_active_pops :: proc(anims: ^Anim_State) -> int {
	count := 0
	for i in 0 ..< MAX_POP_ANIMS {
		if anims.pops[i].active do count += 1
	}
	return count
}

count_active_falls :: proc(anims: ^Anim_State) -> int {
	count := 0
	for i in 0 ..< MAX_FALL_ANIMS {
		if anims.falls[i].active do count += 1
	}
	return count
}

fall_anim_at :: proc(anims: ^Anim_State, col, row: int) -> (^Fall_Anim, bool) {
	for i in 0 ..< MAX_FALL_ANIMS {
		anim := &anims.falls[i]
		if anim.active && anim.col == col && anim.to_row == row && anim.t < 1 {
			return anim, true
		}
	}
	return nil, false
}

update_animations :: proc(state: ^Game_State, dt: f32) {
	anims := &state.anims

	for i in 0 ..< MAX_POP_ANIMS {
		anim := &anims.pops[i]
		if !anim.active do continue

		anim.t += dt / POP_ANIM_DURATION
		if anim.t >= 1 {
			anim.active = false
		}
	}

	if anims.pending_gravity && count_active_pops(anims) == 0 {
		anims.pending_gravity = false
		start_gravity_anims(state)
	}

	for i in 0 ..< MAX_FALL_ANIMS {
		anim := &anims.falls[i]
		if !anim.active do continue

		anim.t += dt / FALL_ANIM_DURATION
		if anim.t >= 1 {
			anim.t = 1
			anim.active = false
		}
	}

	if count_active_pops(anims) == 0 && count_active_falls(anims) == 0 && !anims.pending_gravity {
		anims.locked = false
	}
}

try_pop_group :: proc(state: ^Game_State, col, row: int) -> bool {
	if anim_locked(state) do return false
	if col < 0 || row < 0 || col >= GRID_COLS || row >= GRID_ROWS do return false
	if !state.board.cells[row][col].active do return false

	visited: [GRID_ROWS][GRID_COLS]bool
	count := flood_fill_group(&state.board, col, row, &visited)
	if count < MIN_POP_SIZE do return false

	block := state.board.cells[row][col].block

	for r in 0 ..< GRID_ROWS {
		for c in 0 ..< GRID_COLS {
			if !visited[r][c] do continue
			add_pop_anim(&state.anims, c, r, state.board.cells[r][c].block)
			state.board.cells[r][c] = Cell{}
		}
	}

	state.anims.pending_gravity = true
	state.anims.locked = true
	player_attack(state, block, count)
	return true
}
