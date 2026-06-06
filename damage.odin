package main

import "core:fmt"
import rl "vendor:raylib"

actor_sprite_rect :: proc(is_player: bool) -> (x, y, size: i32) {
	sprite_size: i32 = 90
	sx := (PANEL_W - sprite_size) / 2
	if is_player {
		return sx, 36, sprite_size
	}
	ex := WINDOW_W - PANEL_W
	return ex + sx, 36, sprite_size
}

actor_center :: proc(is_player: bool) -> (cx, cy: f32) {
	x, y, size := actor_sprite_rect(is_player)
	return f32(x + size / 2), f32(y + size / 2)
}

damage_spawn_point :: proc(attacker_is_player: bool) -> (x, y: f32) {
	attacker_x, attacker_y := actor_center(attacker_is_player)
	target_x, target_y := actor_center(!attacker_is_player)

	// Offset slightly from attacker center toward the target.
	dx := target_x - attacker_x
	dy := target_y - attacker_y
	return attacker_x + dx * 0.15, attacker_y + dy * 0.15
}

damage_init :: proc(state: ^Game_State) {
	for i in 0 ..< MAX_DAMAGE_ANIMS {
		state.damage_anims[i] = {}
	}
}

spawn_damage_anim :: proc(state: ^Game_State, damage: i32, target: Damage_Target) {
	if damage <= 0 do return

	attacker_is_player := target == .Enemy
	start_x, start_y := damage_spawn_point(attacker_is_player)
	end_x, end_y := actor_center(target == .Player)

	for i in 0 ..< MAX_DAMAGE_ANIMS {
		if !state.damage_anims[i].active {
			state.damage_anims[i] = Damage_Anim{
				active     = true,
				damage     = damage,
				target     = target,
				start_x    = start_x,
				start_y    = start_y,
				end_x      = end_x,
				end_y      = end_y,
			}
			return
		}
	}
}

apply_damage :: proc(state: ^Game_State, anim: ^Damage_Anim) {
	switch anim.target {
	case .Enemy:
		state.enemy.hp -= anim.damage
		if state.enemy.hp < 0 do state.enemy.hp = 0
	case .Player:
		state.player.hp -= anim.damage
		if state.player.hp < 0 do state.player.hp = 0
	}
}

update_damage_anims :: proc(state: ^Game_State, dt: f32) {
	for i in 0 ..< MAX_DAMAGE_ANIMS {
		anim := &state.damage_anims[i]
		if !anim.active do continue

		if !anim.flying {
			anim.hold_timer += dt
			if anim.hold_timer >= DAMAGE_HOLD_DELAY {
				anim.flying = true
			}
		} else {
			anim.fly_t += dt / DAMAGE_FLY_DURATION
			if anim.fly_t >= 1 {
				apply_damage(state, anim)
				anim.active = false
			}
		}
	}
}

damage_anim_position :: proc(anim: ^Damage_Anim) -> (x, y: f32) {
	if !anim.flying {
		return anim.start_x, anim.start_y
	}
	t := ease_in_quad(anim.fly_t)
	return anim.start_x + (anim.end_x - anim.start_x) * t, anim.start_y + (anim.end_y - anim.start_y) * t
}

draw_damage_anims :: proc(state: ^Game_State) {
	for i in 0 ..< MAX_DAMAGE_ANIMS {
		anim := &state.damage_anims[i]
		if !anim.active do continue

		x, y := damage_anim_position(anim)

		buf: [16]u8
		text := fmt.bprintf(buf[:], "%d", anim.damage)
		font_size: i32 = 36
		tw := rl.MeasureText(to_cstring(text), font_size)

		color := anim.target == .Enemy ? rl.Color{255, 220, 80, 255} : rl.Color{255, 90, 90, 255}
		if anim.flying {
			color.a = u8(255 * (1 - f32(anim.fly_t) * 0.35))
		}

		draw_x := i32(x) - tw / 2
		draw_y := i32(y) - font_size / 2
		draw_text(text, draw_x, draw_y, font_size, color)
	}
}
