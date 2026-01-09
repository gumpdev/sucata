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

MAX_GAMEPADS :: 4
gamepads: [MAX_GAMEPADS]GamepadState

init_gamepad :: proc() {
	if !sdl3.InitSubSystem({.GAMEPAD}) {
		fmt.eprintln("Falha ao inicializar SDL3 Gamepad:", sdl3.GetError())
		return
	}

	joystick_count: c.int
	joystick_ids := sdl3.GetJoysticks(&joystick_count)
	if joystick_ids == nil {
		fmt.eprintln("Erro ao obter joysticks:", sdl3.GetError())
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
		fmt.eprintln("Máximo de gamepads atingido")
		return false
	}

	gamepad := sdl3.OpenGamepad(joystick_id)
	if gamepad == nil {
		fmt.eprintln("Falha ao abrir gamepad:", sdl3.GetError())
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

	fmt.printfln("Gamepad conectado no slot %d: %s", slot, gamepads[slot].name)
	return true
}

remove_gamepad :: proc(id: sdl3.JoystickID) {
	for i in 0 ..< MAX_GAMEPADS {
		if gamepads[i].connected && gamepads[i].id == id {
			if gamepads[i].gamepad != nil {
				sdl3.CloseGamepad(gamepads[i].gamepad)
			}
			gamepads[i] = {}
			fmt.printfln("Gamepad desconectado do slot %d", i)
			break
		}
	}
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

gamepad_button_down :: proc(slot: int, button: sdl3.GamepadButton) -> bool {
	if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
		return false
	}
	return gamepads[slot].buttons[button]
}

gamepad_button_pressed :: proc(slot: int, button: sdl3.GamepadButton) -> bool {
	if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
		return false
	}
	return gamepads[slot].buttons_down[button]
}

gamepad_button_released :: proc(slot: int, button: sdl3.GamepadButton) -> bool {
	if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
		return false
	}
	return gamepads[slot].buttons_up[button]
}

gamepad_axis :: proc(slot: int, axis: sdl3.GamepadAxis) -> f32 {
	if slot < 0 || slot >= MAX_GAMEPADS || !gamepads[slot].connected {
		return 0.0
	}
	return gamepads[slot].axes[axis]
}

gamepad_left_stick :: proc(slot: int) -> [2]f32 {
	return {gamepad_axis(slot, .LEFTX), gamepad_axis(slot, .LEFTY)}
}

gamepad_right_stick :: proc(slot: int) -> [2]f32 {
	return {gamepad_axis(slot, .RIGHTX), gamepad_axis(slot, .RIGHTY)}
}

gamepad_triggers :: proc(slot: int) -> [2]f32 {
	return {gamepad_axis(slot, .LEFT_TRIGGER), gamepad_axis(slot, .RIGHT_TRIGGER)}
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
