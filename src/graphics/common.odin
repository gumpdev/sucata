package graphics

import "core:math/linalg"

Vec2 :: [2]f32
Vec3 :: [3]f32
Vec4 :: [4]f32

Vertex_Data :: struct {
	position: Vec2,
	col:      Vec4,
	uv:       Vec2,
}

get_fixed_mvp :: proc() -> matrix[4, 4]f32 {
	return linalg.matrix_ortho3d_f32(0, f32(game_width), f32(game_height), 0, -1, 1)
}
