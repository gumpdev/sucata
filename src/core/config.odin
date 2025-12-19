package core

import sapp "../../sokol/app"
import common "../common"
import graphics "../graphics"
import "core:strings"

windowConfig := common.WindowConfig {
	width           = 800,
	height          = 600,
	vsync           = 1,
	fullscreen      = false,
	title           = "Sucata",
	lock_mouse      = false,
	visible_mouse   = true,
	draw_debug_info = false,
	keep_aspect     = 0,
}

set_mouse_lock :: proc(mouse_lock: b32) {
	windowConfig.lock_mouse = bool(mouse_lock)

	if sapp.isvalid() {
		sapp.lock_mouse(windowConfig.lock_mouse)
	}
}

set_mouse_visible :: proc(mouse_visible: b32) {
	windowConfig.visible_mouse = bool(mouse_visible)

	if sapp.isvalid() {
		sapp.show_mouse(windowConfig.visible_mouse)
	}
}

set_window_title :: proc(title: string) {
	windowConfig.title = title

	title_cstring := strings.clone_to_cstring(title)
	defer delete(title_cstring)

	if sapp.isvalid() {
		sapp.set_window_title(title_cstring)
	}
}

set_window_vsync :: proc(vsync: i32) {
	windowConfig.vsync = vsync
}

set_window_size :: proc(width: i32, height: i32) {
	windowConfig.width = width
	windowConfig.height = height
	graphics.set_game_dimensions(width, height)
}

set_window_fullscreen :: proc(fullscreen: b32) {
	if windowConfig.fullscreen == bool(fullscreen) {
		return
	}
	windowConfig.fullscreen = bool(fullscreen)

	if sapp.isvalid() {
		sapp.toggle_fullscreen()
	}
}
