package core

calc_screen_scale :: proc(screen_width, screen_height: i32) -> f32 {
	scale_x := f32(screen_width) / (f32(windowConfig.width))
	scale_y := f32(screen_height) / (f32(windowConfig.height))

	return min(scale_x, scale_y)
}

calc_screen_scale_crop :: proc(screen_width, screen_height: i32) -> f32 {
	scale_x := f32(screen_width) / (f32(windowConfig.width))
	scale_y := f32(screen_height) / (f32(windowConfig.height))

	return max(scale_x, scale_y)
}

get_game_screen_size :: proc(screen_width, screen_height: i32) -> (i32, i32) {
	scale := calc_screen_scale(screen_width, screen_height)
	game_width := i32(f32(windowConfig.width) * scale)
	game_height := i32(f32(windowConfig.height) * scale)
	return game_width, game_height
}

get_game_screen_size_crop :: proc(screen_width, screen_height: i32) -> (i32, i32) {
	scale := calc_screen_scale_crop(screen_width, screen_height)
	game_width := i32(f32(windowConfig.width) * scale)
	game_height := i32(f32(windowConfig.height) * scale)
	return game_width, game_height
}

get_game_screen :: proc(screen_width, screen_height: i32) -> (i32, i32, i32, i32) {
	game_screen_width, game_screen_height := get_game_screen_size(screen_width, screen_height)

	translate_x: i32 = (screen_width - game_screen_width) / 2
	translate_y: i32 = (screen_height - game_screen_height) / 2

	return translate_x, translate_y, game_screen_width, game_screen_height
}

get_game_screen_crop :: proc(screen_width, screen_height: i32) -> (i32, i32, i32, i32) {
	game_screen_width, game_screen_height := get_game_screen_size_crop(screen_width, screen_height)

	translate_x: i32 = (screen_width - game_screen_width) / 2
	translate_y: i32 = (screen_height - game_screen_height) / 2

	return translate_x, translate_y, game_screen_width, game_screen_height
}
