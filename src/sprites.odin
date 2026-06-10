package game

import rl "vendor:raylib"

GAME_SPRITES: map[string]rl.Texture2D

available_images: [1]string = {"nutri-hero"}

load_game_sprites :: proc() {
	app_path := rl.GetApplicationDirectory()
	base_images_path := "assets/images/"

	for i in 0 ..< len(available_images) {
		image_name := available_images[i]
		GAME_SPRITES[image_name] = rl.LoadTexture(
			rl.TextFormat("%s%s%s%s", app_path, base_images_path, image_name, ".png"),
		)
	}
}

unload_game_sprites :: proc() {
	for i in 0 ..< len(available_images) {
		image_name := available_images[i]
		rl.UnloadTexture(GAME_SPRITES[image_name])
	}
}
