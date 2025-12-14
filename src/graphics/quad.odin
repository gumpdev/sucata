package graphics

import "../camera"
import "../common"
import shader_quad "../shaders/quad"
import "core:c"
import sg "shared:sokol/gfx"

quad_ib: sg.Buffer
quad_buffers_inited: bool
quad_pipeline: sg.Pipeline
quad_sampler: sg.Sampler

init_quad_indices :: proc() {
	if quad_buffers_inited {
		return
	}
	quad_shader := shader_quad.load_rect_shader()
	quad_pipeline = sg.make_pipeline(
		{
			shader = quad_shader,
			layout = {
				buffers = {0 = {stride = c.int(size_of(Vertex_Data))}},
				attrs = {
					shader_quad.ATTR_quad_position = {
						format = .FLOAT2,
						buffer_index = 0,
						offset = 0,
					},
					shader_quad.ATTR_quad_col = {format = .FLOAT4, buffer_index = 0, offset = 8},
					shader_quad.ATTR_quad_uv = {format = .FLOAT2, buffer_index = 0, offset = 24},
				},
			},
			index_type = .UINT16,
			colors = {
				0 = {
					blend = {
						enabled = true,
						src_factor_rgb = .SRC_ALPHA,
						dst_factor_rgb = .ONE_MINUS_SRC_ALPHA,
						src_factor_alpha = .ONE,
						dst_factor_alpha = .ONE_MINUS_SRC_ALPHA,
						op_rgb = .ADD,
						op_alpha = .ADD,
					},
				},
			},
		},
	)
	indices := []u16{0, 1, 2, 0, 2, 3}
	quad_ib = sg.make_buffer(
		{usage = {index_buffer = true, immutable = true}, data = sg_range(indices)},
	)

	quad_sampler = sg.make_sampler(
		{
			min_filter = .NEAREST,
			mag_filter = .NEAREST,
			wrap_u = .CLAMP_TO_EDGE,
			wrap_v = .CLAMP_TO_EDGE,
		},
	)

	quad_buffers_inited = true
}

shutdown_quad_buffers :: proc() {
	if quad_buffers_inited {
		sg.destroy_buffer(quad_ib)
		sg.destroy_pipeline(quad_pipeline)
		sg.destroy_sampler(quad_sampler)
		quad_buffers_inited = false
	}
}

quad :: proc(props: common.QuadObjectProps) {
	init_quad_indices()

	position := props.position
	size := props.size
	color := props.color
	z_index := props.zIndex
	texture := props.texture
	scale := props.scale
	origin := props.origin
	rotation := props.rotation
	atlas := props.atlas
	fixed := props.fixed

	if texture == "" {
		texture = "__default__"
	}
	image := load_image(texture)

	points := to_world_space_2d(position, size, scale, origin, rotation)

	quad_color := Vec4{color[0], color[1], color[2], color[3]}
	uv_pos := calculate_atlas_uv(atlas, f32(image.width), f32(image.height))

	vertices: [4]Vertex_Data
	vertices[0] = Vertex_Data {
		position = points[0],
		col      = quad_color,
		uv       = uv_pos[0],
	}
	vertices[1] = Vertex_Data {
		position = points[1],
		col      = quad_color,
		uv       = uv_pos[1],
	}
	vertices[2] = Vertex_Data {
		position = points[2],
		col      = quad_color,
		uv       = uv_pos[2],
	}
	vertices[3] = Vertex_Data {
		position = points[3],
		col      = quad_color,
		uv       = uv_pos[3],
	}

	mvp: matrix[4, 4]f32
	if props.fixed {
		mvp = get_fixed_mvp()
	} else {
		mvp = camera.get_view_projection_matrix(game_width, game_height)
	}

	quad_vb := sg.make_buffer(
		{size = uint(4 * size_of(Vertex_Data)), data = sg_range(vertices[:])},
	)
	sg.apply_pipeline(quad_pipeline)
	sg.apply_uniforms(0, {ptr = &mvp, size = size_of(mvp)})

	quad_image := image.view
	bindings := sg.Bindings {
		vertex_buffers = {0 = quad_vb},
		index_buffer = quad_ib,
		views = {shader_quad.VIEW_tex = quad_image},
		samplers = {shader_quad.SMP_smp = quad_sampler},
	}

	sg.apply_bindings(bindings)
	sg.draw(0, 6, 1)

	sg.destroy_buffer(quad_vb)
}
