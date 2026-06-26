package game

import "core:fmt"
import rl "vendor:raylib"
import ini "core:encoding/ini"
import strconv "core:strconv"

App_Screen :: enum {
	Title,
	Playing,
	Options,
}

Resolution_Preset :: enum {
	Monitor_Native,
	R_1280x720,
	R_1600x900,
	R_1920x1080,
	R_2560x1440,
}

FPS_OPTIONS: [3]i32 = {30, 60, 120}

Settings :: struct {
	target_fps: i32,
	resolution: Resolution_Preset,
    sfx_volume: f16,
}

App_State :: struct {
	screen:       App_Screen,
	settings:     Settings,
	game:         Game_State,
	request_quit: bool,
}

resolution_label :: proc(preset: Resolution_Preset) -> string {
	switch preset {
	case .Monitor_Native:
		return "Monitor (Fullscreen)"
	case .R_1280x720:
		return "1280 x 720"
	case .R_1600x900:
		return "1600 x 900"
	case .R_1920x1080:
		return "1920 x 1080"
	case .R_2560x1440:
		return "2560 x 1440"
	}
	return "Unknown"
}

fps_option_index :: proc(fps: i32) -> int {
	for i in 0 ..< len(FPS_OPTIONS) {
		if FPS_OPTIONS[i] == fps do return i
	}
	return 1
}

apply_settings :: proc(settings: ^Settings) {
	rl.SetTargetFPS(settings.target_fps)

	switch settings.resolution {
	case .Monitor_Native:
		if !rl.IsWindowFullscreen() {
			rl.ToggleFullscreen()
		}
	case .R_1280x720:
		set_windowed_size(1280, 720)
	case .R_1600x900:
		set_windowed_size(1600, 900)
	case .R_1920x1080:
		set_windowed_size(1920, 1080)
	case .R_2560x1440:
		set_windowed_size(2560, 1440)
	}

    set_all_sfx_volume(&settings.sfx_volume)
}

save_settings :: proc(settings: Settings) {
    //TODO(mihai): use and test
    config := make(ini.Map)
    defer {
        for _, section_map in config {
            delete(section_map)
        }
        delete(config)
    }

    config["settings"] = make(map[string]string)
    config_settings := config["settings"]

    buf: [4]byte
    config_settings["target_fps"] = strconv.write_int(buf[:], i64(settings.target_fps), 10)

    switch settings.resolution {
    case .Monitor_Native:
        config_settings["resolution"] = "native"
    case .R_1280x720:
        config_settings["resolution"] = "1280x720"
    case .R_1600x900:
        config_settings["resolution"] = "1600x900"
    case .R_1920x1080:
        config_settings["resolution"] = "1920x1080"
    case .R_2560x1440:
        config_settings["resolution"] = "2560x1440"
    }

    config_settings["sfx_volume"] = strconv.write_float(buf[:], f64(settings.sfx_volume), 'f', 2, 64)
}

load_settings :: proc(settings: ^Settings) {
    if config, _, ok := ini.load_map_from_path(
        string(rl.TextFormat(
            "%s%s",
            rl.GetApplicationDirectory(),
            "options.ini",
        )),
        context.allocator
    ); ok {
        config_settings := config["settings"]

        if n, ok := strconv.parse_int(config_settings["target_fps"], base = 10); ok do settings.target_fps = i32(n)

        switch config_settings["resolution"] {
        case "native":
            settings.resolution = Resolution_Preset.Monitor_Native
        case "1280x720":
            settings.resolution = Resolution_Preset.R_1280x720
        case "1600x900":
            settings.resolution = Resolution_Preset.R_1600x900
        case "1920x1080":
            settings.resolution = Resolution_Preset.R_1920x1080
        case "2560x1440":
            settings.resolution = Resolution_Preset.R_2560x1440
        case:
            fmt.println("ERROR: Unsupported config resolution; Defaulting to native")
            settings.resolution = Resolution_Preset.Monitor_Native
        }
        if n, ok := strconv.parse_f32(config_settings["sfx_volume"]); ok do settings.sfx_volume = f16(n)
    }
}

set_windowed_size :: proc(w, h: i32) {
	if rl.IsWindowFullscreen() {
		rl.ToggleFullscreen()
	}
	rl.SetWindowSize(w, h)
}

next_fps :: proc(current: i32, delta: int) -> i32 {
	idx := fps_option_index(current)
	count := len(FPS_OPTIONS)
	idx = (idx + delta + count) % count
	return FPS_OPTIONS[idx]
}

next_resolution :: proc(current: Resolution_Preset, delta: int) -> Resolution_Preset {
	preset := i32(current)
	count := i32(Resolution_Preset.R_2560x1440) + 1
	return Resolution_Preset((preset + i32(delta) + count) % count)
}

cycle_fps :: proc(settings: ^Settings, delta: int) {
	settings.target_fps = next_fps(settings.target_fps, delta)
	rl.SetTargetFPS(settings.target_fps)
}

cycle_resolution :: proc(settings: ^Settings, delta: int) {
	settings.resolution = next_resolution(settings.resolution, delta)
	apply_settings(settings)
}

draw_menu_button :: proc(label: string, x, y, w, h: i32, hovered: bool) {
	bg := hovered ? rl.Color{70, 110, 70, 255} : rl.Color{50, 80, 50, 255}
	border := hovered ? rl.Color{110, 160, 110, 255} : rl.Color{80, 120, 80, 255}

	rl.DrawRectangle(x, y, w, h, bg)
	rl.DrawRectangleLinesEx({f32(x), f32(y), f32(w), f32(h)}, 2, border)

	tw := rl.MeasureText(to_cstring(label), 22)
	draw_text(label, x + (w - tw) / 2, y + (h - 22) / 2, 22, rl.WHITE)
}

menu_button_hovered :: proc(mx, my, x, y, w, h: i32) -> bool {
	return mx >= x && mx < x + w && my >= y && my < y + h
}

menu_button_clicked :: proc(mx, my, x, y, w, h: i32) -> bool {
	return rl.IsMouseButtonPressed(.LEFT) && menu_button_hovered(mx, my, x, y, w, h)
}

SETTING_ROW_X: i32 : 340
SETTING_ROW_W: i32 : 600
SETTING_ROW_H: i32 : 48
SETTING_ARROW_W: i32 : 48

setting_row_input :: proc(y: i32, mx, my: i32) -> (prev, next: bool) {
	prev_x := SETTING_ROW_X
	next_x := SETTING_ROW_X + SETTING_ROW_W - SETTING_ARROW_W
	prev_hover := menu_button_hovered(mx, my, prev_x, y, SETTING_ARROW_W, SETTING_ROW_H)
	next_hover := menu_button_hovered(mx, my, next_x, y, SETTING_ARROW_W, SETTING_ROW_H)
	prev = rl.IsMouseButtonPressed(.LEFT) && prev_hover
	next = rl.IsMouseButtonPressed(.LEFT) && next_hover
	return
}

set_all_sfx_volume :: proc(value: ^f16) {
    for i in 0 ..< len(available_sounds) do rl.SetSoundVolume(SOUNDS[available_sounds[i]], f32(value^))
}

set_slider_input :: proc(y: i32, mx, my: i32, value: ^f16) {
    slider_hover := menu_button_hovered(mx, my, SETTING_ROW_X, y, SETTING_ROW_W, SETTING_ROW_H)
    if rl.IsMouseButtonDown(.LEFT) && slider_hover {
        value^ = f16((mx - SETTING_ROW_X)) / f16(SETTING_ROW_W)
        set_all_sfx_volume(value)
    }
    return
}

draw_setting_row :: proc(label: string, value: string, y: i32, mx, my: i32, settings: Settings) {
	row_x := SETTING_ROW_X
	row_w := SETTING_ROW_W
	row_h := SETTING_ROW_H
	arrow_w := SETTING_ARROW_W

	rl.DrawRectangle(row_x, y, row_w, row_h, {35, 35, 45, 255})
	rl.DrawRectangleLinesEx({f32(row_x), f32(y), f32(row_w), f32(row_h)}, 1, {70, 70, 90, 255})

	draw_text(label, row_x + 32, y + 14, 18, {180, 180, 200, 255})

	tw := rl.MeasureText(to_cstring(value), 20)
	draw_text(value, row_x + (row_w - tw) / 2, y + 14, 20, rl.WHITE)

    if label == "SFX Volume" {
        rl.DrawRectangle(SETTING_ROW_X, y, i32(f16(SETTING_ROW_W) * settings.sfx_volume), SETTING_ROW_H, {0, 255, 0, 30})
    } else {
        prev_x := row_x
        next_x := row_x + row_w - arrow_w
        prev_hover := menu_button_hovered(mx, my, prev_x, y, arrow_w, row_h)
        next_hover := menu_button_hovered(mx, my, next_x, y, arrow_w, row_h)

        prev_color := prev_hover ? rl.Color{100, 100, 120, 255} : rl.Color{70, 70, 85, 255}
        next_color := next_hover ? rl.Color{100, 100, 120, 255} : rl.Color{70, 70, 85, 255}

        draw_text(">", next_x + 16, y + 12, 24, next_color)
        draw_text("<", prev_x + 16, y + 12, 24, prev_color)
    }
}

start_new_game :: proc(app: ^App_State) {
	app.game.stage = 1
	reset_game(&app.game)
	app.screen = .Playing
}

update_title :: proc(app: ^App_State) {
	mx, my := viewport_mouse()

	btn_w: i32 = 280
	btn_h: i32 = 48
	btn_x := (WINDOW_W - btn_w) / 2
	play_y: i32 = 300
	options_y: i32 = 370
	exit_y: i32 = 440

	if menu_button_clicked(mx, my, btn_x, play_y, btn_w, btn_h) {
		rl.PlaySound(SOUNDS["button_select"])
		start_new_game(app)
	}
	if menu_button_clicked(mx, my, btn_x, options_y, btn_w, btn_h) {
		app.screen = .Options
	}
	if menu_button_clicked(mx, my, btn_x, exit_y, btn_w, btn_h) || rl.IsKeyPressed(.ESCAPE) {
		app.request_quit = true
	}

}

draw_title :: proc() {
	rl.ClearBackground({20, 20, 26, 255})

	title := "Nutri Slayer"
	tw := rl.MeasureText(to_cstring(title), 64)
	draw_text(title, (WINDOW_W - tw) / 2, 140, 64, {100, 200, 100, 255})

	mx, my := viewport_mouse()
	btn_w: i32 = 280
	btn_h: i32 = 48
	btn_x := (WINDOW_W - btn_w) / 2

	draw_menu_button(
		"New Game",
		btn_x,
		300,
		btn_w,
		btn_h,
		menu_button_hovered(mx, my, btn_x, 300, btn_w, btn_h),
	)
	draw_menu_button(
		"Options",
		btn_x,
		370,
		btn_w,
		btn_h,
		menu_button_hovered(mx, my, btn_x, 370, btn_w, btn_h),
	)
	draw_menu_button(
		"Exit",
		btn_x,
		440,
		btn_w,
		btn_h,
		menu_button_hovered(mx, my, btn_x, 440, btn_w, btn_h),
	)
}

update_options :: proc(app: ^App_State) {
	mx, my := viewport_mouse()

	if rl.IsKeyPressed(.ESCAPE) {
		app.screen = .Title
		return
	}

	prev, next := setting_row_input(280, mx, my)
	if prev do cycle_fps(&app.settings, -1)
	if next do cycle_fps(&app.settings, 1)

	res_prev, res_next := setting_row_input(360, mx, my)
	if res_prev do cycle_resolution(&app.settings, -1)
	if res_next do cycle_resolution(&app.settings, 1)

    set_slider_input(440, mx, my, &app.settings.sfx_volume)

	btn_w: i32 = 200
	btn_h: i32 = 44
	btn_x := (WINDOW_W - btn_w) / 2
	back_y: i32 = 560
	if menu_button_clicked(mx, my, btn_x, back_y, btn_w, btn_h) {
		app.screen = .Title
	}
}

draw_options :: proc(app: ^App_State) {
	rl.ClearBackground({20, 20, 26, 255})

	title := "Options"
	tw := rl.MeasureText(to_cstring(title), 48)
	draw_text(title, (WINDOW_W - tw) / 2, 120, 48, rl.WHITE)

	mx, my := viewport_mouse()

	buf: [16]u8
	text := fmt.bprintf(buf[:], "%d FPS", app.settings.target_fps)
	draw_setting_row("Max FPS", text, 280, mx, my, app.settings)

	draw_setting_row("Resolution", resolution_label(app.settings.resolution), 360, mx, my, app.settings)

    text = fmt.bprintf(buf[:], "%d%%", i8(app.settings.sfx_volume * 100))
	draw_setting_row("SFX Volume", text, 440, mx, my, app.settings)

	btn_w: i32 = 200
	btn_h: i32 = 44
	btn_x := (WINDOW_W - btn_w) / 2
	draw_menu_button(
		"Back",
		btn_x,
		560,
		btn_w,
		btn_h,
		menu_button_hovered(mx, my, btn_x, 560, btn_w, btn_h),
	)
}
