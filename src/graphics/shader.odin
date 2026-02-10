package graphics

import sg "../../sokol/gfx"
import "../common"
import "../fs"
import "../path"
import "core:c"
import "core:os"

CustomShader :: struct {
	ib:              sg.Buffer,
	shader:          sg.Shader,
	pipeline:        sg.Pipeline,
	attributes:      [16]ShaderAttribute,
	attributes_size: int,
}

custom_shaders := map[string]CustomShader{}

get_shader_path :: proc(shader_path: string) -> ([]byte, bool) {
	if asset_data, ok := fs.get_asset(shader_path); ok && len(asset_data) > 0 {
		return asset_data, true
	}
	schd_data, ok := os.read_entire_file_from_filename(path.get_path(shader_path))
	if !ok {
		return {}, false
	}

	return schd_data, true
}

DEFAULT_BUFFER :: [3]string{"position", "col", "uv"}

get_shader_attributes_to_sokol_format :: proc(
	attributes: [16]ShaderAttribute,
) -> [16]sg.Vertex_Attr_State {
	formats := [16]sg.Vertex_Attr_State {
		0 = {format = .FLOAT2, buffer_index = 0, offset = 0},
		1 = {format = .FLOAT4, buffer_index = 0, offset = 8},
		2 = {format = .FLOAT2, buffer_index = 0, offset = 24},
	}
	i := 3
	for attr in attributes {
		formats[i] = sg.Vertex_Attr_State {
			format       = attr.type,
			buffer_index = 1,
			offset       = c.int(attr.offset),
		}
		i += 1
		if i >= 16 {
			break
		}
	}
	return formats
}

get_shader_vertex_size :: proc(attributes: [16]ShaderAttribute) -> int {
	size := 0
	for attr in attributes {
		size += attr.size
	}
	return size / 4
}

get_custom_shader_vertex_data :: proc(shader: CustomShader, props: common.ShaderArgs) -> []f32 {
	vertex_size := shader.attributes_size

	data := make([]f32, vertex_size)
	parameters := shader.attributes
	i := 0

	for param in parameters {
		if value, ok := props[param.name]; ok {
			#partial switch v in value {
			case f32:
				data[i] = value.(f32)
			case [2]f32:
				data[i] = value.([2]f32)[0]
				data[i + 1] = value.([2]f32)[1]
			case [3]f32:
				data[i] = value.([3]f32)[0]
				data[i + 1] = value.([3]f32)[1]
				data[i + 2] = value.([3]f32)[2]
			case [4]f32:
				data[i] = value.([4]f32)[0]
				data[i + 1] = value.([4]f32)[1]
				data[i + 2] = value.([4]f32)[2]
				data[i + 3] = value.([4]f32)[3]
			}
		}
		i += param.size / 4
	}

	return data
}

create_shader_from_schd :: proc(schd_data: []byte) -> (sg.Shader, [16]ShaderAttribute) {
	backend := sg.query_backend()
	desc, attributes := create_shader_desc_from_schd(backend, schd_data)
	return sg.make_shader(desc), attributes
}

init_shader :: proc(name: string, schd_path: string) -> bool {
	if vlr, ok := custom_shaders[name]; ok {
		return true
	}

	schd_data, ok := get_shader_path(schd_path)
	if !ok {
		common.print_warning(
			"Failed to read shader definition file: %s, unable to create the shader",
			schd_path,
		)
		return false
	}

	shader, attributes := create_shader_from_schd(schd_data)

	pipeline := sg.make_pipeline(
		{
			shader = shader,
			layout = {
				buffers = {0 = {stride = c.int(size_of(Vertex_Data))}},
				attrs = get_shader_attributes_to_sokol_format(attributes),
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
	ib := sg.make_buffer(
		{usage = {index_buffer = true, immutable = true}, data = sg_range(indices)},
	)

	custom_shaders[name] = CustomShader {
		shader          = shader,
		pipeline        = pipeline,
		ib              = ib,
		attributes      = attributes,
		attributes_size = get_shader_vertex_size(attributes),
	}

	return true
}

destroy_shaders :: proc() {
	for _, shader in custom_shaders {
		sg.destroy_buffer(shader.ib)
		sg.destroy_pipeline(shader.pipeline)
		sg.destroy_shader(shader.shader)
	}
	custom_shaders = map[string]CustomShader{}
}
