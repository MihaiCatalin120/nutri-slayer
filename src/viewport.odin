package game

import rl "vendor:raylib"

viewport_camera: rl.Camera2D

viewport_scale :: proc(screen_w, screen_h: f32) -> f32 {
	return min(screen_w / f32(WINDOW_W), screen_h / f32(WINDOW_H))
}

viewport_update :: proc() {
	screen_w := f32(rl.GetScreenWidth())
	screen_h := f32(rl.GetScreenHeight())
	scale := viewport_scale(screen_w, screen_h)

	viewport_camera = rl.Camera2D {
		target   = {f32(WINDOW_W) * 0.5, f32(WINDOW_H) * 0.5},
		offset   = {screen_w * 0.5, screen_h * 0.5},
		rotation = 0,
		zoom     = scale,
	}
}

viewport_begin_frame :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({10, 10, 14, 255})
	rl.BeginMode2D(viewport_camera)
}

viewport_end_frame :: proc() {
	rl.EndMode2D()
	rl.EndDrawing()
}

viewport_mouse :: proc() -> (x, y: i32) {
	world := rl.GetScreenToWorld2D(
		{f32(rl.GetMouseX()), f32(rl.GetMouseY())},
		viewport_camera,
	)
	return i32(world.x), i32(world.y)
}
