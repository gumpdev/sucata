package graphics

import sg "../../sokol/gfx"
import "core:c"
import "core:fmt"
import "core:os"

CustomShader :: struct {
	ib:       sg.Buffer,
	shader:   sg.Shader,
	pipeline: sg.Pipeline,
}

custom_shaders := map[string]CustomShader{}

create_shader_from_schd :: proc(schd_data: []byte) -> (sg.Shader, [16]sg.Vertex_Attr_State) {
	backend := sg.query_backend()
	desc, formats := create_shader_desc_from_schd(backend, schd_data)
	return sg.make_shader(desc), formats
}

// Render Shader
init_shader :: proc(name: string, schd_path: string) -> bool {
	if vlr, ok := custom_shaders[name]; ok {
		return true
	}

	schd_data, ok := os.read_entire_file_from_filename(schd_path)
	if !ok {
		fmt.println("Failed to read shader definition file: ", schd_path)
		return false
	}

	shader, formats := create_shader_from_schd(schd_data)

	pipeline := sg.make_pipeline(
		{
			shader = shader,
			layout = {buffers = {0 = {stride = c.int(size_of(Vertex_Data))}}, attrs = formats},
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
		shader   = shader,
		pipeline = pipeline,
		ib       = ib,
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

load_shader_from_path :: proc(path: string) -> (sg.Shader, [16]sg.Vertex_Attr_State) {
	data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		fmt.println("Failed to read shader file: ", path)
		return sg.Shader{}, [16]sg.Vertex_Attr_State{}
	}
	return create_shader_from_schd(data)
}
