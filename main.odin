package main

import game "src"
import rl "vendor:raylib"

main :: proc() {
	monitor := i32(0)
	screen_w := rl.GetMonitorWidth(monitor)
	screen_h := rl.GetMonitorHeight(monitor)

	rl.SetConfigFlags({.MSAA_4X_HINT, .FULLSCREEN_MODE, .WINDOW_RESIZABLE})
	rl.InitWindow(screen_w, screen_h, "nutri-slayer")
	rl.InitAudioDevice()
	rl.SetWindowMinSize(640, 360)
	rl.SetTargetFPS(60)
    rl.SetExitKey(.KEY_NULL)

	app := game.App_State {
		screen = .Title,
		settings = {target_fps = 60, resolution = .Monitor_Native, sfx_volume = 0.5},
	}
	game.apply_settings(&app.settings)
	game.load_sounds()
	game.load_game_sprites()
    game.load_settings()

	for !rl.WindowShouldClose() && !app.request_quit {
		dt := rl.GetFrameTime()
		game.viewport_update()

		switch app.screen {
		case .Title:
			game.update_title(&app)
		case .Options:
			game.update_options(&app)
		case .Playing:
			game.update_game(&app, dt)
		}

		game.viewport_begin_frame()
		switch app.screen {
		case .Title:
			game.draw_title()
		case .Options:
			game.draw_options(&app)
		case .Playing:
			game.draw_ui(&app.game)
		}
		game.viewport_end_frame()
	}

	game.unload_sounds()
	game.unload_game_sprites()
	rl.CloseAudioDevice()
	rl.CloseWindow()
}
