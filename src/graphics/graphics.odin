package graphics

game_width: i32 = 800
game_height: i32 = 600

set_game_dimensions :: proc(width, height: i32) {
	game_width = width
	game_height = height
}

init_graphics :: proc() {
	load_default_image()
}

shutdown_graphics :: proc() {
	shutdown_quad_buffers()
	shutdown_text_buffers()
	unload_fonts()
	destroy_images()
}
