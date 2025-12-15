package core

import camera "../camera"
import "core:math"
import "core:sort"
Hoverable :: struct {
	id:      string,
	x:       f32,
	y:       f32,
	width:   f32,
	height:  f32,
	z_index: i32,
	fixed:   bool,
}

hoverables: [dynamic]Hoverable
hover := ""

add_hoverable :: proc(id: string, x, y, width, height: f32, z_index: i32, fixed: bool) {
	hoverable := Hoverable {
		id      = id,
		x       = x,
		y       = y,
		width   = width,
		height  = height,
		z_index = z_index,
		fixed   = fixed,
	}
	append_elem(&hoverables, hoverable)
}

process_hoverables :: proc() {
	_hoverables := hoverables[:]
	sort.quick_sort_proc(_hoverables, proc(a, b: Hoverable) -> int {
		if a.z_index < b.z_index {
			return -1
		} else if a.z_index > b.z_index {
			return 1
		}
		return 0
	})

	mouse_x := input_state.mouse_pos[0]
	mouse_y := input_state.mouse_pos[1]

	if camera.camera.rotation != 0 {
		cos_r := math.cos(-camera.camera.rotation)
		sin_r := math.sin(-camera.camera.rotation)
		rotated_x := mouse_x * cos_r - mouse_y * sin_r
		rotated_y := mouse_x * sin_r + mouse_y * cos_r
		mouse_x = rotated_x
		mouse_y = rotated_y
	}

	world_mouse_x := (mouse_x / camera.camera.zoom) + camera.camera.position.x
	world_mouse_y := (mouse_y / camera.camera.zoom) + camera.camera.position.y

	for hoverable in _hoverables {
		if hoverable.fixed {
			if mouse_x >= hoverable.x &&
			   mouse_x <= hoverable.x + hoverable.width &&
			   mouse_y >= hoverable.y &&
			   mouse_y <= hoverable.y + hoverable.height {
				hover = hoverable.id
				break
			}
		} else {
			if world_mouse_x >= hoverable.x &&
			   world_mouse_x <= hoverable.x + hoverable.width &&
			   world_mouse_y >= hoverable.y &&
			   world_mouse_y <= hoverable.y + hoverable.height {
				hover = hoverable.id
				break
			}
		}
	}
	hoverables = {}
}
