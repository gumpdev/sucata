package graphics

import "../common"

calculate_atlas_uv :: proc(atlas: common.AtlasProps, width: f32, height: f32) -> [4][2]f32 {
	atlas_width := atlas.width
	atlas_height := atlas.height
	atlas_spacing := atlas.spacing
	atlas_margin := atlas.margin
	atlas_x := atlas.x
	atlas_y := atlas.y

	if atlas_height == 0.0 || atlas_width == 0.0 {
		return [4][2]f32{{0.0, 0.0}, {0.0, 1.0}, {1.0, 1.0}, {1.0, 0.0}}
	}

	u0 := (atlas_margin + (atlas_x * (atlas_width + atlas_spacing))) / width
	v0 := (atlas_margin + (atlas_y * (atlas_height + atlas_spacing))) / height
	u1 := (atlas_margin + (atlas_x * (atlas_width + atlas_spacing)) + atlas_width) / width
	v1 := (atlas_margin + (atlas_y * (atlas_height + atlas_spacing)) + atlas_height) / height

	return [4][2]f32{{u0, v0}, {u0, v1}, {u1, v1}, {u1, v0}}
}
