package common

WindowConfig :: struct {
	width:           i32,
	height:          i32,
	vsync:           i32,
	title:           string,
	fullscreen:      bool,
	lock_mouse:      bool,
	visible_mouse:   bool,
	draw_debug_info: bool,
	keep_aspect:     i32,
}
