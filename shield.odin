package main

import "core:fmt"
import rl "vendor:raylib"

shield_spawn_point :: proc() -> (x, y: f32) {
	w := f32(WINDOW_W / 2)
	h := f32(WINDOW_H / 2)
	return w, h
}

shield_init :: proc(state: ^Game_State) {
	for i in 0 ..< MAX_SHIELD_ANIMS {
		state.shield_anims[i] = {}
	}
}

spawn_shield_anim :: proc(state: ^Game_State, shield: i32) {
	if shield <= 0 do return

	start_x, start_y := shield_spawn_point()
	end_x, end_y := actor_center(true)

	for i in 0 ..< MAX_SHIELD_ANIMS {
		if !state.shield_anims[i].active {
			state.shield_anims[i] = Shield_Anim {
				active  = true,
				shield  = shield,
				start_x = start_x,
				start_y = start_y,
				end_x   = end_x,
				end_y   = end_y,
			}
			return
		}
	}
}

apply_shield :: proc(state: ^Game_State, anim: ^Shield_Anim) {
	state.player.shield += anim.shield
}

update_shield_anims :: proc(state: ^Game_State, dt: f32) {
	for i in 0 ..< MAX_SHIELD_ANIMS {
		anim := &state.shield_anims[i]
		if !anim.active do continue

		if !anim.flying {
			anim.hold_timer += dt
			if anim.hold_timer >= SHIELD_HOLD_DELAY {
				anim.flying = true
			}
		} else {
			anim.fly_t += dt / SHIELD_FLY_DURATION
			if anim.fly_t >= 1 {
				apply_shield(state, anim)
				anim.active = false
			}
		}
	}
}

shield_anim_position :: proc(anim: ^Shield_Anim) -> (x, y: f32) {
	if !anim.flying {
		return anim.start_x, anim.start_y
	}
	t := ease_in_quad(anim.fly_t)
	return anim.start_x + (anim.end_x - anim.start_x) * t,
		anim.start_y + (anim.end_y - anim.start_y) * t
}

draw_shield_anims :: proc(state: ^Game_State) {
	for i in 0 ..< MAX_SHIELD_ANIMS {
		anim := &state.shield_anims[i]
		if !anim.active do continue

		x, y := shield_anim_position(anim)

		buf: [16]u8
		text := fmt.bprintf(buf[:], "%d", anim.shield)
		font_size: i32 = 36
		tw := rl.MeasureText(to_cstring(text), font_size)

		color := rl.Color{255, 255, 255, 255}
		if anim.flying {
			color.a = u8(255 * (1 - f32(anim.fly_t) * 0.35))
		}

		draw_x := i32(x) - tw / 2
		draw_y := i32(y) - font_size / 2
		draw_text(text, draw_x, draw_y, font_size, color)
	}
}
