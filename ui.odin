package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

random_int_between :: proc(min, max: i32) -> i32 {
	if max <= min do return min
	return rl.GetRandomValue(min, max)
}

to_cstring :: proc(text: string) -> cstring {
	return strings.clone_to_cstring(text, context.temp_allocator)
}

draw_text :: proc(text: string, x, y, size: i32, color: rl.Color) {
	rl.DrawText(to_cstring(text), x, y, size, color)
}

draw_section_label :: proc(label: cstring, x, y: i32) {
	rl.DrawText(label, x + 8, y + 6, 16, {180, 180, 200, 255})
}

draw_arena_frame :: proc() {
	border := rl.Color{70, 70, 90, 255}

	rl.DrawRectangle(ARENA_X, ARENA_Y, ARENA_W, ARENA_H, {35, 35, 45, 255})
	rl.DrawRectangleLinesEx({f32(ARENA_X), f32(ARENA_Y), f32(ARENA_W), f32(ARENA_H)}, 2, border)

	draw_section_label("PLAYER", 0, 0)
	draw_section_label("ENEMY", WINDOW_W - PANEL_W, 0)
}

draw_hp_bar :: proc(x, y, w, h, hp, max_hp: i32) {
	rl.DrawRectangle(x, y, w, h, {40, 40, 50, 255})
	if max_hp > 0 {
		fill_w := i32(f32(w) * f32(hp) / f32(max_hp))
		color := hp > max_hp / 4 ? rl.Color{80, 180, 80, 255} : rl.Color{200, 80, 60, 255}
		rl.DrawRectangle(x, y, fill_w, h, color)
	}
	rl.DrawRectangleLinesEx({f32(x), f32(y), f32(w), f32(h)}, 1, {100, 100, 120, 255})

	hp_buf: [32]u8
	hp_text := fmt.bprintf(hp_buf[:], "%d / %d HP", hp, max_hp)
	tw := rl.MeasureText(to_cstring(hp_text), 14)
	draw_text(hp_text, x + (w - tw) / 2, y + (h - 14) / 2, 14, rl.WHITE)
}

draw_shield :: proc(x, y, w, h, shield: i32) {
	shield_buf: [32]u8
	shield_text := fmt.bprintf(shield_buf[:], "%d shield", shield)
	font_size := i32(12)
	tw := rl.MeasureText(to_cstring(shield_text), font_size)
	draw_text(shield_text, x + (w - tw), y + (h - font_size) / 2, font_size, rl.WHITE)
}

draw_actor_sprite :: proc(x, y, size: i32, actor: ^Actor, is_player: bool) {
	rl.DrawRectangle(x, y, size, size, actor.color)
	rl.DrawRectangleLinesEx({f32(x), f32(y), f32(size), f32(size)}, 2, rl.WHITE)

	icon := is_player ? "P" : "E"
	iw := rl.MeasureText(to_cstring(icon), 48)
	draw_text(icon, x + (size - iw) / 2, y + size / 2 - 24, 48, rl.WHITE)
}

draw_stats :: proc(x, y, w, h: i32, title: cstring) {
	rl.DrawRectangle(x, y, w, h, {30, 30, 38, 255})
	rl.DrawRectangleLinesEx({f32(x), f32(y), f32(w), f32(h)}, 1, {60, 60, 75, 255})
	rl.DrawText(title, x + 8, y + 6, 14, {150, 150, 170, 255})
	rl.DrawText("(buffs / debuffs — placeholder)", x + 8, y + 28, 12, {100, 100, 115, 255})
}

draw_hovered_block_info :: proc(state: ^Game_State, x, y, w, h: i32) {
	rl.DrawRectangle(x, y, w, h, {30, 30, 38, 255})
	rl.DrawRectangleLinesEx({f32(x), f32(y), f32(w), f32(h)}, 1, {60, 60, 75, 255})
	rl.DrawText("Block info", x + 8, y + 6, 14, {150, 150, 170, 255})

	if state.hover_col < 0 || state.hover_row < 0 {
		draw_text("Hover a block...", x + 8, y + 36, 12, {100, 100, 115, 255})
		return
	}

	block := state.board.cells[state.hover_row][state.hover_col].block
	color := Block_Colors[block]

	rl.DrawRectangle(x + 8, y + 28, 18, 18, color)
	rl.DrawRectangleLinesEx({f32(x + 8), f32(y + 28), 18, 18}, 1, {0, 0, 0, 80})
	draw_text(Block_Full_Names[block], x + 32, y + 30, 14, rl.WHITE)

	mult_buf: [32]u8
	mult_text := fmt.bprintf(mult_buf[:], "Power: %.1fx", Block_Attack_Multiplier[block])
	draw_text(mult_text, x + 8, y + 52, 12, {160, 160, 175, 255})

	group_buf: [32]u8
	group_text := fmt.bprintf(group_buf[:], "Group: %d blocks", state.selected_count)
	draw_text(group_text, x + 8, y + 68, 12, {160, 160, 175, 255})
}

draw_search_bar :: proc(state: ^Game_State) {
	y := WINDOW_H - SEARCH_H
	rl.DrawRectangle(0, y, WINDOW_W, SEARCH_H, {25, 25, 32, 255})
	rl.DrawLine(0, y, WINDOW_W, y, {70, 70, 90, 255})

	rl.DrawText("Search food:", 16, y + 18, 16, {180, 180, 200, 255})

	box_x: i32 = 130
	box_w: i32 = WINDOW_W - 280
	box_h: i32 = 32
	box_y := y + 12

	rl.DrawRectangle(box_x, box_y, box_w, box_h, {50, 50, 62, 255})
	rl.DrawRectangleLinesEx(
		{f32(box_x), f32(box_y), f32(box_w), f32(box_h)},
		1,
		{90, 90, 110, 255},
	)

	query := string(state.search_buffer[:state.search_len])
	display := query if len(query) > 0 else "Type a meal (salad, burger, sandwich...)"
	text_color := len(query) > 0 ? rl.WHITE : rl.Color{110, 110, 125, 255}
	draw_text(display, box_x + 8, box_y + 8, 16, text_color)

	// Blinking cursor
	if i32(rl.GetTime() * 2) % 2 == 0 {
		cx := box_x + 8 + rl.MeasureText(to_cstring(query), 16)
		rl.DrawLine(cx, box_y + 6, cx, box_y + box_h - 6, rl.WHITE)
	}

	btn_x := WINDOW_W - 130
	btn_w: i32 = 110
	rl.DrawRectangle(btn_x, box_y, btn_w, box_h, {60, 100, 60, 255})
	rl.DrawRectangleLinesEx(
		{f32(btn_x), f32(box_y), f32(btn_w), f32(box_h)},
		1,
		{90, 140, 90, 255},
	)
	btn_label := "Eat  [Enter]"
	tw := rl.MeasureText(to_cstring(btn_label), 14)
	draw_text(btn_label, btn_x + (btn_w - tw) / 2, box_y + 9, 14, rl.WHITE)
}

search_bar_submit_clicked :: proc(mx, my: i32) -> bool {
	y := WINDOW_H - SEARCH_H
	box_y := y + 12
	btn_x := WINDOW_W - 130
	btn_w: i32 = 110
	box_h: i32 = 32

	return mx >= btn_x && mx <= btn_x + btn_w && my >= box_y && my <= box_y + box_h
}

point_in_game_area :: proc(mx, my: i32) -> bool {
	return mx >= GAME_X && mx < GAME_X + GAME_W && my >= GAME_Y && my < GAME_Y + GAME_H
}

draw_block :: proc(x, y, w, h: f32, block: Block_Type, scale: f32 = 1, alpha: u8 = 255) {
	color := Block_Colors[block]
	color.a = alpha

	rx, ry, rw, rh := x, y, w, h
	if scale != 1 {
		cx := x + w * 0.5
		cy := y + h * 0.5
		rw = w * scale
		rh = h * scale
		rx = cx - rw * 0.5
		ry = cy - rh * 0.5
	}

	rl.DrawRectangleRec({rx, ry, rw, rh}, color)
	rl.DrawRectangleLinesEx({rx, ry, rw, rh}, 1, {0, 0, 0, u8(f32(alpha) * 0.24)})
}

draw_board :: proc(state: ^Game_State) {
	rl.DrawRectangle(GAME_X, GAME_Y, GAME_W, GAME_H, {28, 28, 36, 255})

	cell_w, cell_h, ox, oy := board_cell_size()
	pad: f32 = 3

	for row in 0 ..< GRID_ROWS {
		for col in 0 ..< GRID_COLS {
			x := ox + f32(col) * cell_w + pad
			y := oy + f32(row) * cell_h + pad
			w := cell_w - pad * 2
			h := cell_h - pad * 2

			// Empty cell slot
			rl.DrawRectangleRec({x, y, w, h}, {42, 42, 52, 255})

			cell := state.board.cells[row][col]
			if cell.active {
				if _, falling := fall_anim_at(&state.anims, col, row); !falling {
					draw_block(x, y, w, h, cell.block)

					if col == state.hover_col &&
					   row == state.hover_row &&
					   state.selected_count >= MIN_POP_SIZE {
						rl.DrawRectangleLinesEx({x - 1, y - 1, w + 2, h + 2}, 2, rl.WHITE)
					}
				}
			}
		}
	}

	for i in 0 ..< MAX_FALL_ANIMS {
		anim := &state.anims.falls[i]
		if !anim.active do continue

		row_f := anim.from_row + (f32(anim.to_row) - anim.from_row) * ease_out_quad(anim.t)
		x := ox + f32(anim.col) * cell_w + pad
		y := oy + row_f * cell_h + pad
		bw := cell_w - pad * 2
		bh := cell_h - pad * 2
		draw_block(x, y, bw, bh, anim.block)
	}

	for i in 0 ..< MAX_POP_ANIMS {
		anim := &state.anims.pops[i]
		if !anim.active do continue

		x := ox + f32(anim.col) * cell_w + pad
		y := oy + f32(anim.row) * cell_h + pad
		w := cell_w - pad * 2
		h := cell_h - pad * 2

		pop_t := ease_in_quad(anim.t)
		scale := 1 + 0.15 * (1 - pop_t) - pop_t * 0.5
		alpha := u8(255 * (1 - pop_t))
		draw_block(x, y, w, h, anim.block, scale, alpha)
	}
}

draw_ui :: proc(state: ^Game_State) {
	rl.ClearBackground({20, 20, 26, 255})

	draw_arena_frame()

	sprite_size: i32 = 90
	sx := (PANEL_W - sprite_size) / 2
	ex := WINDOW_W - PANEL_W
	stats_y := HEADER_H
	block_info_y := stats_y + STATS_H

	draw_actor_sprite(sx, 36, sprite_size, &state.player, true)
	draw_hp_bar(16, 140, PANEL_W - 32, 22, state.player.hp, state.player.max_hp)
	draw_shield(16, 140 - 22, PANEL_W - 32, 22, state.player.shield)
	draw_stats(0, stats_y, PANEL_W, STATS_H, "Player stats / info")
	draw_hovered_block_info(state, 0, block_info_y, PANEL_W, BLOCK_INFO_H)

	draw_actor_sprite(ex + sx, 36, sprite_size, &state.enemy, false)
	draw_hp_bar(ex + 16, 140, PANEL_W - 32, 22, state.enemy.hp, state.enemy.max_hp)
	draw_stats(ex, stats_y, PANEL_W, STATS_H, "Enemy stats")

	counter_buf: [48]u8
	counter_text := fmt.bprintf(
		counter_buf[:],
		"Attacks in: %d turns",
		state.enemy.turns_until_attack,
	)
	draw_text(counter_text, ex + 8, 170, 12, {170, 130, 130, 255})

	draw_board(state)

	draw_damage_anims(state)
	draw_shield_anims(state)

	// --- Search bar ---
	draw_search_bar(state)

	// Status message
	if state.status_timer > 0 {
		rl.DrawText(cstring(&state.status_message[0]), GAME_X + 8, 28, 16, {220, 220, 140, 255})
	}

	// Game over overlay
	over, won := game_is_over(state)
	if over {
		rl.DrawRectangle(0, 0, WINDOW_W, WINDOW_H, {0, 0, 0, 160})
		title := won ? "Victory!" : "Defeat!"
		title_color := won ? rl.Color{100, 220, 100, 255} : rl.Color{220, 80, 80, 255}
		tw := rl.MeasureText(to_cstring(title), 48)
		draw_text(title, (WINDOW_W - tw) / 2, WINDOW_H / 2 - 40, 48, title_color)
		draw_text(
			"Press R to restart",
			(WINDOW_W - rl.MeasureText(to_cstring("Press R to restart"), 20)) / 2,
			WINDOW_H / 2 + 20,
			20,
			rl.WHITE,
		)
	}

	if won {
		state.enemy = Actor {
			name               = "Enemy",
			hp                 = 80,
			max_hp             = 80,
			shield             = 0,
			turns_per_attack   = 3,
			turns_until_attack = 3,
			color              = {180, 60, 60, 255},
		}
	}
}
