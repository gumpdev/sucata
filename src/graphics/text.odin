package graphics

import "../camera"
import "../common"
import shader_text "../shaders/text"
import "core:c"
import sg "shared:sokol/gfx"

text_ib: sg.Buffer
text_shader: sg.Shader
text_buffers_inited: bool
text_pipeline: sg.Pipeline
text_sampler: sg.Sampler

init_text_indices :: proc() {
	if text_buffers_inited {
		return
	}
	text_shader = shader_text.load_text_shader()
	text_pipeline = sg.make_pipeline(
		{
			shader = text_shader,
			layout = {
				buffers = {0 = {stride = c.int(size_of(Vertex_Data))}},
				attrs = {
					shader_text.ATTR_text_position = {
						format = .FLOAT2,
						buffer_index = 0,
						offset = 0,
					},
					shader_text.ATTR_text_col = {format = .FLOAT4, buffer_index = 0, offset = 8},
					shader_text.ATTR_text_uv = {format = .FLOAT2, buffer_index = 0, offset = 24},
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
	text_ib = sg.make_buffer(
		{usage = {index_buffer = true, immutable = true}, data = sg_range(indices)},
	)

	text_sampler = sg.make_sampler(
		{
			min_filter = .NEAREST,
			mag_filter = .NEAREST,
			wrap_u = .CLAMP_TO_EDGE,
			wrap_v = .CLAMP_TO_EDGE,
		},
	)

	text_buffers_inited = true
}

shutdown_text_buffers :: proc() {
	if text_buffers_inited {
		sg.destroy_buffer(text_ib)
		sg.destroy_pipeline(text_pipeline)
		sg.destroy_sampler(text_sampler)
		sg.destroy_shader(text_shader)
		text_buffers_inited = false
	}
}

calculate_text_width :: proc(text: string, font: ^Font, scale: [2]f32) -> f32 {
	width: f32 = 0
	for i in 0 ..< len(text) {
		char := text[i]
		if char < 32 || char >= 128 {
			continue
		}
		baked_char := font.char_data[char - 32]
		width += f32(baked_char.xadvance) * scale[0]
	}
	return width
}

calculate_alignment_offset :: proc(
	line_width: f32,
	max_width: f32,
	align: common.TextAlign,
) -> f32 {
	switch align {
	case .Left:
		return 0
	case .Center:
		if max_width > 0 {
			return (max_width - line_width) / 2
		}
		return -line_width / 2
	case .Right:
		if max_width > 0 {
			return max_width - line_width
		}
		return -line_width
	}
	return 0
}

wrap_text :: proc(text: string, font: ^Font, scale: [2]f32, max_width: f32) -> [dynamic]string {
	lines := make([dynamic]string)

	if max_width <= 0 {
		append(&lines, text)
		return lines
	}

	current_line: string
	current_width: f32 = 0
	word_start := 0

	for i in 0 ..< len(text) {
		char := text[i]

		if char == '\n' {
			if i > word_start {
				line_text := text[word_start:i]
				append(&lines, line_text)
			} else if len(current_line) > 0 {
				append(&lines, current_line)
			}
			current_line = ""
			current_width = 0
			word_start = i + 1
			continue
		}

		if char < 32 || char >= 128 {
			continue
		}

		baked_char := font.char_data[char - 32]
		char_width := f32(baked_char.xadvance) * scale[0]

		if current_width + char_width > max_width && current_width > 0 {
			last_space := -1
			for j := i - 1; j >= word_start; j -= 1 {
				if text[j] == ' ' {
					last_space = j
					break
				}
			}

			if last_space >= word_start {
				append(&lines, text[word_start:last_space])
				word_start = last_space + 1
				current_width = 0

				for k in word_start ..< i + 1 {
					c := text[k]
					if c >= 32 && c < 128 {
						bc := font.char_data[c - 32]
						current_width += f32(bc.xadvance) * scale[0]
					}
				}
			} else {
				append(&lines, text[word_start:i])
				word_start = i
				current_width = char_width
			}
		} else {
			current_width += char_width
		}
	}

	if word_start < len(text) {
		append(&lines, text[word_start:len(text)])
	}

	return lines
}

text :: proc(props: common.TextObjectProps) {
	init_text_indices()

	font_path := props.font
	font_size := props.size
	font := load_font(font_path, font_size)
	position := props.position
	color := props.color
	z_index := props.zIndex
	scale := props.scale
	origin := props.origin
	rotation := props.rotation
	fixed := props.fixed
	align := props.align
	max_width := props.maxWidth

	position[1] += font_size / 2

	sg.apply_pipeline(text_pipeline)

	lines := wrap_text(props.text, font, scale, max_width)
	defer delete(lines)

	line_height := font_size * scale[1]
	current_y := position[1]

	for line in lines {
		if len(line) == 0 {
			current_y += line_height
			continue
		}

		line_width := calculate_text_width(line, font, scale)
		alignment_offset := calculate_alignment_offset(line_width, max_width, align)

		cursor_pos := [2]f32{position[0] + alignment_offset, current_y}

		for i in 0 ..< len(line) {
			char := line[i]
			if char < 32 || char >= 128 {
				continue
			}
			baked_char := font.char_data[char - 32]

			char_width := f32(baked_char.x1 - baked_char.x0)
			char_height := f32(baked_char.y1 - baked_char.y0)
			char_size := [2]f32{char_width, char_height}

			char_pos := [2]f32 {
				cursor_pos[0] + f32(baked_char.xoff),
				cursor_pos[1] + f32(baked_char.yoff),
			}

			points := to_world_space_2d(char_pos, char_size, scale, origin, rotation)

			text_color := Vec4{color[0], color[1], color[2], color[3]}
			uv_pos := to_uv_space_2d(
				f32(baked_char.x0),
				f32(baked_char.y0),
				f32(baked_char.x1),
				f32(baked_char.y1),
				f32(font.bitmap_width),
				f32(font.bitmap_height),
			)

			vertices: [4]Vertex_Data
			vertices[0] = Vertex_Data {
				position = points[0],
				col      = text_color,
				uv       = uv_pos[0],
			}
			vertices[1] = Vertex_Data {
				position = points[1],
				col      = text_color,
				uv       = uv_pos[1],
			}
			vertices[2] = Vertex_Data {
				position = points[2],
				col      = text_color,
				uv       = uv_pos[2],
			}
			vertices[3] = Vertex_Data {
				position = points[3],
				col      = text_color,
				uv       = uv_pos[3],
			}

			mvp: matrix[4, 4]f32
			if props.fixed {
				mvp = get_fixed_mvp()
			} else {
				mvp = camera.get_view_projection_matrix(game_width, game_height)
			}

			text_vb := sg.make_buffer(
				{size = uint(4 * size_of(Vertex_Data)), data = sg_range(vertices[:])},
			)
			sg.apply_uniforms(0, {ptr = &mvp, size = size_of(mvp)})

			bindings := sg.Bindings {
				vertex_buffers = {0 = text_vb},
				index_buffer = text_ib,
				views = {shader_text.VIEW_tex = font.image},
				samplers = {shader_text.SMP_smp = text_sampler},
			}

			sg.apply_bindings(bindings)
			sg.draw(0, 6, 1)

			sg.destroy_buffer(text_vb)

			cursor_pos[0] += f32(baked_char.xadvance) * scale[0]
		}

		current_y += line_height
	}
}
