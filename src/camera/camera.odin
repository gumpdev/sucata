package camera

import "core:math/linalg"

Camera :: struct {
	position: [2]f32,
	zoom:     f32,
	rotation: f32,
}

camera: Camera = {
	position = {0, 0},
	zoom     = 1.0,
	rotation = 0.0,
}

init_camera :: proc(x, y: f32, zoom: f32 = 1.0) {
	camera.position = {x, y}
	camera.zoom = zoom
	camera.rotation = 0.0
}

set_camera_position :: proc(x, y: f32) {
	camera.position = {x, y}
}

set_camera_zoom :: proc(zoom: f32) {
	camera.zoom = zoom
}

set_camera_rotation :: proc(rotation: f32) {
	camera.rotation = rotation
}

move_camera :: proc(dx, dy: f32) {
	camera.position.x += dx
	camera.position.y += dy
}

get_view_projection_matrix :: proc(game_width, game_height: i32) -> matrix[4, 4]f32 {
	projection := linalg.matrix_ortho3d_f32(0, f32(game_width), f32(game_height), 0, -1, 1)

	view := linalg.matrix4_translate_f32({-camera.position.x, -camera.position.y, 0})
	view = linalg.matrix_mul(view, linalg.matrix4_scale_f32({camera.zoom, camera.zoom, 1}))

	if camera.rotation != 0 {
		view = linalg.matrix_mul(view, linalg.matrix4_rotate_f32(camera.rotation, {0, 0, 1}))
	}

	return linalg.matrix_mul(projection, view)
}
