package graphics

import sg "../../sokol/gfx"
import "core:math"

to_world_space_2d :: proc(
	position: [2]f32,
	size: [2]f32,
	scale: [2]f32,
	origin: [2]f32,
	rotation: f32,
) -> [4][2]f32 {
	scaled_size := [2]f32{size[0] * scale[0], size[1] * scale[1]}

	origin_offset := [2]f32{origin[0] * scaled_size[0], origin[1] * scaled_size[1]}

	base_vertices := [4][2]f32 {
		{0, 0},
		{0, scaled_size[1]},
		{scaled_size[0], scaled_size[1]},
		{scaled_size[0], 0},
	}

	transformed_vertices: [4][2]f32
	cos_r := math.cos(rotation)
	sin_r := math.sin(rotation)

	for i in 0 ..< 4 {
		rel_x := base_vertices[i][0] - origin_offset[0]
		rel_y := base_vertices[i][1] - origin_offset[1]

		rotated_x := rel_x * cos_r - rel_y * sin_r
		rotated_y := rel_x * sin_r + rel_y * cos_r

		transformed_vertices[i][0] = position[0] + rotated_x
		transformed_vertices[i][1] = position[1] + rotated_y
	}

	return transformed_vertices
}

sg_range :: proc(s: []$T) -> sg.Range {
	return sg.Range{ptr = raw_data(s), size = len(s) * size_of(s[0])}
}

to_uv_space_2d :: proc(x1, y1, x2, y2, w, h: f32) -> [4][2]f32 {
	return [4][2]f32{{x1 / w, y1 / h}, {x1 / w, y2 / h}, {x2 / w, y2 / h}, {x2 / w, y1 / h}}
}

screen_relative :: proc(left, top, right, bottom: f64) -> (f64, f64, f64, f64) {
	x := left * f64(game_width)
	y := top * f64(game_height)
	width := (right - left) * f64(game_width)
	height := (bottom - top) * f64(game_height)

	return x, y, width, height
}
