package core

import sapp "../../sokol/app"
import "core:strings"

InputState :: struct {
	keys_down:     [512]bool,
	keys_pressed:  [512]bool,
	keys_released: [512]bool,
	mods:          u32,
	mouse_pos:     [2]f32,
	mouse_delta:   [2]f32,
	scroll:        [2]f32,
	btn_down:      [3]bool,
	btn_pressed:   [3]bool,
	btn_released:  [3]bool,
	last_char:     u32,
}

input_state := InputState{}

mouse_btn_index :: proc(b: sapp.Mousebutton) -> int {
	when int(sapp.Mousebutton.LEFT) == 0 {
		return int(b)
	}
	if b == .LEFT do return 0
	if b == .RIGHT do return 1
	if b == .MIDDLE do return 2
	return 0
}

clear_input :: proc() {
	input_state.mouse_delta = [2]f32{0, 0}
	input_state.scroll = [2]f32{0, 0}
	input_state.last_char = 0
	for i in 0 ..< len(input_state.keys_pressed) do input_state.keys_pressed[i] = false
	for i in 0 ..< len(input_state.keys_released) do input_state.keys_released[i] = false
	for i in 0 ..< len(input_state.btn_pressed) do input_state.btn_pressed[i] = false
	for i in 0 ..< len(input_state.btn_released) do input_state.btn_released[i] = false
}

handle_input_event :: proc(event: ^sapp.Event) {
	input_state.mods = event.modifiers

	#partial switch event.type {
	case .MOUSE_MOVE:
		new_pos := [2]f32{event.mouse_x, event.mouse_y}
		input_state.mouse_delta = [2]f32 {
			new_pos[0] - input_state.mouse_pos[0],
			new_pos[1] - input_state.mouse_pos[1],
		}
		input_state.mouse_pos = new_pos

	case .MOUSE_DOWN:
		idx := mouse_btn_index(event.mouse_button)
		if 0 <= idx && idx < 3 {
			if !input_state.btn_down[idx] {
				input_state.btn_pressed[idx] = true
			}
			input_state.btn_down[idx] = true
		}

	case .MOUSE_UP:
		idx := mouse_btn_index(event.mouse_button)
		if 0 <= idx && idx < 3 {
			input_state.btn_down[idx] = false
			input_state.btn_released[idx] = true
		}

	case .MOUSE_SCROLL:
		input_state.scroll = [2]f32{event.scroll_x, event.scroll_y}

	case .KEY_DOWN:
		code := int(event.key_code)
		if 0 <= code && code < len(input_state.keys_down) {
			if !input_state.keys_down[code] {
				input_state.keys_pressed[code] = true
			}
			input_state.keys_down[code] = true
		}

	case .KEY_UP:
		code := int(event.key_code)
		if 0 <= code && code < len(input_state.keys_down) {
			input_state.keys_down[code] = false
			input_state.keys_released[code] = true
		}

	case .CHAR:
		input_state.last_char = event.char_code
	}
}


is_down :: proc(btn: string) -> bool {
	keycode := string_to_keycode(btn)
	if keycode != .INVALID {
		if key_down(keycode) {
			return true
		}
	}
	mouse_btn := string_to_mouse(btn)
	if mouse_btn != .INVALID {
		if mouse_down(mouse_btn) {
			return true
		}
	}
	return false
}
is_pressed :: proc(btn: string) -> bool {
	keycode := string_to_keycode(btn)
	if keycode != .INVALID {
		if key_pressed(keycode) {
			return true
		}
	}
	mouse_btn := string_to_mouse(btn)
	if mouse_btn != .INVALID {
		if mouse_pressed(mouse_btn) {
			return true
		}
	}
	return false
}
is_released :: proc(btn: string) -> bool {
	keycode := string_to_keycode(btn)
	if keycode != .INVALID {
		if key_released(keycode) {
			return true
		}
	}
	mouse_btn := string_to_mouse(btn)
	if mouse_btn != .INVALID {
		if mouse_released(mouse_btn) {
			return true
		}
	}
	return false
}

key_down :: proc(k: sapp.Keycode) -> bool {
	return input_state.keys_down[int(k)]
}
key_pressed :: proc(k: sapp.Keycode) -> bool {
	return input_state.keys_pressed[int(k)]
}
key_released :: proc(k: sapp.Keycode) -> bool {
	return input_state.keys_released[int(k)]
}

mouse_down :: proc(btn: sapp.Mousebutton) -> bool {
	return (0 <= int(btn) && int(btn) < 3) && input_state.btn_down[int(btn)]
}
mouse_pressed :: proc(btn: sapp.Mousebutton) -> bool {
	return (0 <= int(btn) && int(btn) < 3) && input_state.btn_pressed[int(btn)]
}
mouse_released :: proc(btn: sapp.Mousebutton) -> bool {
	return (0 <= int(btn) && int(btn) < 3) && input_state.btn_released[int(btn)]
}

mouse_position :: proc() -> (f32, f32) {
	mx := input_state.mouse_pos[0]
	my := input_state.mouse_pos[1]

	if windowConfig.keep_aspect > 0 {
		screen_width := sapp.width()
		screen_height := sapp.height()
		offset_x, offset_y, viewport_width, viewport_height: i32

		if windowConfig.keep_aspect == 2 {
			offset_x, offset_y, viewport_width, viewport_height = get_game_screen_crop(
				screen_width,
				screen_height,
			)
		} else {
			offset_x, offset_y, viewport_width, viewport_height = get_game_screen(
				screen_width,
				screen_height,
			)
		}

		game_x := (mx - f32(offset_x)) * (f32(windowConfig.width) / f32(viewport_width))
		game_y := (my - f32(offset_y)) * (f32(windowConfig.height) / f32(viewport_height))

		return game_x, game_y
	}

	return mx, my
}

mouse_scroll :: proc() -> (f32, f32) {return input_state.scroll[0], input_state.scroll[1]}

string_to_mouse :: proc(s: string) -> sapp.Mousebutton {
	sv := strings.to_lower(s)

	switch sv {
	case "mouse_left":
		return .LEFT
	case "mouse_right":
		return .RIGHT
	case "mouse_middle":
		return .MIDDLE
	}

	return .INVALID
}

string_to_keycode :: proc(s: string) -> sapp.Keycode {
	sv := strings.to_lower(s)

	switch sv {
	case "a":
		return .A
	case "b":
		return .B
	case "c":
		return .C
	case "d":
		return .D
	case "e":
		return .E
	case "f":
		return .F
	case "g":
		return .G
	case "h":
		return .H
	case "i":
		return .I
	case "j":
		return .J
	case "k":
		return .K
	case "l":
		return .L
	case "m":
		return .M
	case "n":
		return .N
	case "o":
		return .O
	case "p":
		return .P
	case "q":
		return .Q
	case "r":
		return .R
	case "s":
		return .S
	case "t":
		return .T
	case "u":
		return .U
	case "v":
		return .V
	case "w":
		return .W
	case "x":
		return .X
	case "y":
		return .Y
	case "z":
		return .Z

	case "space", " ":
		return .SPACE

	case "escape", "esc":
		return .ESCAPE

	case "enter", "return":
		return .ENTER

	case "shift":
		return .LEFT_SHIFT
	case "ctrl", "control":
		return .LEFT_CONTROL
	case "alt":
		return .LEFT_ALT

	case "up":
		return .UP
	case "down":
		return .DOWN
	case "left":
		return .LEFT
	case "right":
		return .RIGHT
	}

	return .INVALID
}
