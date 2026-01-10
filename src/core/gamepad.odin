package core

import "core:c"
import "core:fmt"
import "core:strings"
import "vendor:sdl3"

GamepadState :: struct {
	gamepad:      ^sdl3.Gamepad,
	id:           sdl3.JoystickID,
	name:         string,
	buttons:      [sdl3.GamepadButton]bool,
	buttons_down: [sdl3.GamepadButton]bool,
	buttons_up:   [sdl3.GamepadButton]bool,
	axes:         [sdl3.GamepadAxis]f32,
	connected:    bool,
}

MAX_GAMEPADS :: 8
gamepads: [MAX_GAMEPADS]GamepadState

init_gamepad :: proc() {
	if !sdl3.InitSubSystem({.GAMEPAD}) {
		fmt.eprintln("Error in SDL3 Gamepad:", sdl3.GetError())
		return
	}

	joystick_count: c.int
	joystick_ids := sdl3.GetJoysticks(&joystick_count)
	if joystick_ids == nil {
		fmt.eprintln("Error to get joysticks:", sdl3.GetError())
		return
	}
	defer sdl3.free(joystick_ids)

	for i: i32 = 0; i < joystick_count && i < MAX_GAMEPADS; i += 1 {
		if sdl3.IsGamepad(joystick_ids[i]) {
			add_gamepad(joystick_ids[i])
		}
	}
}

add_gamepad :: proc(joystick_id: sdl3.JoystickID) -> bool {
	slot := -1
	for i in 0 ..< MAX_GAMEPADS {
		if !gamepads[i].connected {
			slot = i
			break
		}
	}

	if slot == -1 {
		return false
	}

	if gamepads[slot].name != "" {
		delete(gamepads[slot].name)
	}

	gamepad := sdl3.OpenGamepad(joystick_id)
	if gamepad == nil {
		fmt.eprintln("Failed to run the gamepad:", sdl3.GetError())
		return false
	}

	gamepads[slot].gamepad = gamepad
	gamepads[slot].id = sdl3.GetGamepadID(gamepad)

	name := sdl3.GetGamepadName(gamepad)
	gamepads[slot].name = name != nil ? string(name) : "Unknown"
	gamepads[slot].connected = true

	for axis in sdl3.GamepadAxis {
		gamepads[slot].axes[axis] = 0.0
	}

	return true
}

remove_gamepad :: proc(id: sdl3.JoystickID) {
	for i in 0 ..< MAX_GAMEPADS {
		if gamepads[i].connected && gamepads[i].id == id {
			if gamepads[i].gamepad != nil {
				sdl3.CloseGamepad(gamepads[i].gamepad)
			}
			delete(gamepads[i].name)
			gamepads[i] = {}
			break
		}
	}
}

get_gamepad_count :: proc() -> int {
	count := 0
	for i in 0 ..< MAX_GAMEPADS {
		if gamepads[i].connected {
			count += 1
		}
	}
	return count
}

clear_gamepad_states :: proc() {
	for i in 0 ..< MAX_GAMEPADS {
		if gamepads[i].connected {
			for btn in sdl3.GamepadButton {
				gamepads[i].buttons_down[btn] = false
				gamepads[i].buttons_up[btn] = false
			}
		}
	}
}

handle_gamepad_event :: proc(event: ^sdl3.Event) {
	#partial switch event.type {
	case .GAMEPAD_ADDED:
		add_gamepad(event.gdevice.which)

	case .GAMEPAD_REMOVED:
		remove_gamepad(event.gdevice.which)

	case .GAMEPAD_BUTTON_DOWN:
		for i in 0 ..< MAX_GAMEPADS {
			if gamepads[i].connected && gamepads[i].id == event.gbutton.which {
				btn := sdl3.GamepadButton(event.gbutton.button)
				if !gamepads[i].buttons[btn] {
					gamepads[i].buttons_down[btn] = true
				}
				gamepads[i].buttons[btn] = true
				break
			}
		}

	case .GAMEPAD_BUTTON_UP:
		for i in 0 ..< MAX_GAMEPADS {
			if gamepads[i].connected && gamepads[i].id == event.gbutton.which {
				btn := sdl3.GamepadButton(event.gbutton.button)
				gamepads[i].buttons[btn] = false
				gamepads[i].buttons_up[btn] = true
				break
			}
		}

	case .GAMEPAD_AXIS_MOTION:
		for i in 0 ..< MAX_GAMEPADS {
			if gamepads[i].connected && gamepads[i].id == event.gaxis.which {
				axis := sdl3.GamepadAxis(event.gaxis.axis)
				value := f32(event.gaxis.value) / 32767.0
				gamepads[i].axes[axis] = value
				break
			}
		}
	}
}

poll_gamepad_events :: proc() {
	event: sdl3.Event
	for sdl3.PollEvent(&event) {
		handle_gamepad_event(&event)
	}
}

shutdown_gamepad :: proc() {
	for i in 0 ..< MAX_GAMEPADS {
		if gamepads[i].connected && gamepads[i].gamepad != nil {
			sdl3.CloseGamepad(gamepads[i].gamepad)
		}
		if gamepads[i].connected {
			delete(gamepads[i].name)
		}
		gamepads[i] = {}
	}
	sdl3.QuitSubSystem({.GAMEPAD})
}

gamepad_is_connected :: proc(slot: int) -> bool {
	if slot < 0 || slot >= MAX_GAMEPADS {
		return false
	}
	return gamepads[slot].connected
}

gamepad_get_name :: proc(slot: int) -> string {
	if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
		return ""
	}
	return gamepads[slot].name
}

gamepad_button_down :: proc(button_str: string, slot: int = -1) -> (bool, int) {
	button := string_to_gamepad_button(button_str)
	if slot >= 0 {
		if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
			return false, -1
		}
		return gamepads[slot].buttons[button], slot
	}

	for i in 0 ..< MAX_GAMEPADS {
		if !gamepads[i].connected {
			continue
		}
		if gamepads[i].buttons[button] {
			return true, i
		}
	}
	return false, -1
}

gamepad_button_pressed :: proc(button_str: string, slot: int = -1) -> (bool, int) {
	button := string_to_gamepad_button(button_str)
	if slot >= 0 {
		if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
			return false, -1
		}
		return gamepads[slot].buttons_down[button], slot
	}

	for i in 0 ..< MAX_GAMEPADS {
		if !gamepads[i].connected {
			continue
		}
		if gamepads[i].buttons_down[button] {
			return true, i
		}
	}
	return false, -1
}

gamepad_button_released :: proc(button_str: string, slot: int = -1) -> (bool, int) {
	button := string_to_gamepad_button(button_str)
	if slot >= 0 {
		if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
			return false, -1
		}
		return gamepads[slot].buttons_up[button], slot
	}

	for i in 0 ..< MAX_GAMEPADS {
		if !gamepads[i].connected {
			continue
		}
		if gamepads[i].buttons_up[button] {
			return true, i
		}
	}
	return false, -1
}

gamepad_axis :: proc(axis_str: string, slot: int = -1) -> (f32, int) {
	axis := string_to_gamepad_axis(axis_str)

	if slot >= 0 {
		if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
			return 0.0, slot
		}
		return gamepads[slot].axes[axis], slot
	}
	for i in 0 ..< MAX_GAMEPADS {
		if !gamepads[i].connected {
			continue
		}
		if gamepads[i].axes[axis] != 0.0 {
			return gamepads[i].axes[axis], i
		}
	}
	return 0.0, -1
}

string_to_gamepad_axis :: proc(s: string) -> sdl3.GamepadAxis {
	sv := strings.to_lower(s)
	defer delete(sv)

	switch sv {
	case "left_x":
		return .LEFTX
	case "left_y":
		return .LEFTY
	case "right_x":
		return .RIGHTX
	case "right_y":
		return .RIGHTY
	case "trigger_left":
		return .LEFT_TRIGGER
	case "trigger_right":
		return .RIGHT_TRIGGER
	}
	return .INVALID
}

string_to_gamepad_button :: proc(s: string) -> sdl3.GamepadButton {
	sv := strings.to_lower(s)
	defer delete(sv)

	switch sv {
	case "a":
		return .SOUTH
	case "b":
		return .EAST
	case "x":
		return .NORTH
	case "y":
		return .WEST
	case "back":
		return .BACK
	case "guide":
		return .GUIDE
	case "start":
		return .START
	case "left_stick":
		return .LEFT_STICK
	case "right_stick":
		return .RIGHT_STICK
	case "left_shoulder":
		return .LEFT_SHOULDER
	case "right_shoulder":
		return .RIGHT_SHOULDER
	case "dpad_up":
		return .DPAD_UP
	case "dpad_down":
		return .DPAD_DOWN
	case "dpad_left":
		return .DPAD_LEFT
	case "dpad_right":
		return .DPAD_RIGHT
	}

	return .INVALID
}
