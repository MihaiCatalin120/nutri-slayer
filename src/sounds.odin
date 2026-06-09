package game

import rl "vendor:raylib"

SOUNDS: map[string]rl.Sound
available_sounds: [11]string = {
	"block_collision",
	"block_pop",
	"boss_defeat",
	"button_select",
	"enemy_attack",
	"enemy_defeat",
	"invalid_action",
	"low_hp_warn",
	"option_select",
	"player_attack",
	"shield_gain",
}

load_sounds :: proc() {
	app_path := rl.GetApplicationDirectory()
	base_sounds_path := "assets/sound/"

	for i in 0 ..< len(available_sounds) {
		sound_name := available_sounds[i]
		SOUNDS[sound_name] = rl.LoadSound(
			rl.TextFormat("%s%s%s%s", app_path, base_sounds_path, sound_name, ".wav"),
		)
	}
}

unload_sounds :: proc() {
	for i in 0 ..< len(available_sounds) {
		sound_name := available_sounds[i]
		rl.UnloadSound(SOUNDS[sound_name])
	}
}
