package game

board_init :: proc(board: ^Board) {
	for row in 0 ..< GRID_ROWS {
		for col in 0 ..< GRID_COLS {
			board.cells[row][col] = Cell{}
		}
	}
}

board_cell_size :: proc() -> (cell_w, cell_h: f32, offset_x, offset_y: f32) {
	cell_w = f32(GAME_W) / f32(GRID_COLS)
	cell_h = f32(GAME_H) / f32(GRID_ROWS)
	grid_w := cell_w * f32(GRID_COLS)
	grid_h := cell_h * f32(GRID_ROWS)
	offset_x = f32(GAME_X) + (f32(GAME_W) - grid_w) * 0.5
	offset_y = f32(GAME_Y) + (f32(GAME_H) - grid_h) * 0.5
	return
}

screen_to_cell :: proc(mx, my: i32) -> (col, row: int, ok: bool) {
	cell_w, cell_h, ox, oy := board_cell_size()

	fmx := f32(mx)
	fmy := f32(my)

	if fmx < ox || fmy < oy {
		return -1, -1, false
	}

	col = int((fmx - ox) / cell_w)
	row = int((fmy - oy) / cell_h)

	if col < 0 || col >= GRID_COLS || row < 0 || row >= GRID_ROWS {
		return -1, -1, false
	}

	return col, row, true
}

flood_fill_group :: proc(
	board: ^Board,
	start_col, start_row: int,
	visited: ^[GRID_ROWS][GRID_COLS]bool,
) -> int {
	cell := &board.cells[start_row][start_col]
	if !cell.active do return 0
	if visited[start_row][start_col] do return 0

	target := cell.block
	count := 0

	stack: [GRID_ROWS * GRID_COLS][2]int
	top := 0

	stack[top] = [2]int{start_col, start_row}
	top += 1

	for top > 0 {
		top -= 1
		pos := stack[top]
		c, r := pos[0], pos[1]

		if c < 0 || c >= GRID_COLS || r < 0 || r >= GRID_ROWS do continue
		if visited[r][c] do continue

		cur := board.cells[r][c]
		if !cur.active || cur.block != target do continue

		visited[r][c] = true
		count += 1

		stack[top] = [2]int{c + 1, r}; top += 1
		stack[top] = [2]int{c - 1, r}; top += 1
		stack[top] = [2]int{c, r + 1}; top += 1
		stack[top] = [2]int{c, r - 1}; top += 1
	}

	return count
}

valid_moves_available :: proc(board: ^Board) -> bool {
    for col in 0 ..<GRID_COLS {
        for row in 0 ..<GRID_ROWS {
            if preview_group_size(board, col, row) > 1 do return true
        }
    }

    return false
}

preview_group_size :: proc(board: ^Board, col, row: int) -> int {
	if col < 0 || row < 0 do return 0
	if !board.cells[row][col].active do return 0

	visited: [GRID_ROWS][GRID_COLS]bool
	return flood_fill_group(board, col, row, &visited)
}

apply_gravity :: proc(board: ^Board) {
	for col in 0 ..< GRID_COLS {
		write_row := GRID_ROWS - 1

		for read_row := GRID_ROWS - 1; read_row >= 0; read_row -= 1 {
			cell := board.cells[read_row][col]
			if cell.active {
				if read_row != write_row {
					board.cells[write_row][col] = cell
					board.cells[read_row][col] = Cell{}
				}
				write_row -= 1
			}
		}
	}
}

set_status :: proc(state: ^Game_State, msg: string) {
	n := min(len(msg), len(state.status_message) - 1)
	for i in 0 ..< n {
		state.status_message[i] = u8(msg[i])
	}
	state.status_message[n] = 0
	state.status_timer = 4.0
}
