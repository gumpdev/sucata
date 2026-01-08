package graphics

import sg "../../sokol/gfx"
import "core:encoding/json"
import "core:fmt"
import "core:strings"

get_shader_attr_type :: proc(attr_type: string) -> sg.Shader_Attr_Base_Type {
	switch attr_type {
	case "Float":
		return .FLOAT
	case "Int":
		return .UINT
	}
	return .FLOAT
}

get_shader_stage :: proc(shader_stage: string) -> sg.Shader_Stage {
	switch shader_stage {
	case "compute":
		return .COMPUTE
	case "vertex":
		return .VERTEX
	case "fragment":
		return .FRAGMENT
	}
	return .NONE
}

get_uniform_layout :: proc(layout: string) -> sg.Uniform_Layout {
	switch layout {
	case "std140":
		return .STD140
	case "native":
		return .NATIVE
	}
	return .DEFAULT
}

get_uniform_type :: proc(uniform_type: string) -> sg.Uniform_Type {
	switch uniform_type {
	case "float":
		return .FLOAT
	case "int":
		return .INT
	case "mat4":
		return .MAT4
	case "vec2":
		return .FLOAT2
	case "vec3":
		return .FLOAT3
	case "vec4":
		return .FLOAT4
	}
	return .INVALID
}

get_image_type :: proc(image_type: string) -> sg.Image_Type {
	switch image_type {
	case "2d":
		return ._2D
	case "3d":
		return ._3D
	case "cube":
		return .CUBE
	case "array":
		return .ARRAY
	}
	return .DEFAULT
}

get_image_sample_type :: proc(sample_type: string) -> sg.Image_Sample_Type {
	switch sample_type {
	case "float":
		return .FLOAT
	case "sint":
		return .SINT
	case "uint":
		return .UINT
	case "depth":
		return .DEPTH
	}
	return .DEFAULT
}

get_sampler_type :: proc(sampler_type: string) -> sg.Sampler_Type {
	switch sampler_type {
	case "filtering":
		return .FILTERING
	case "comparison":
		return .COMPARISON
	case "nonfiltering":
		return .NONFILTERING
	}
	return .DEFAULT
}


find_program_in_schd :: proc(schd_data: json.Value, program_name: string) -> json.Object {
	shaders := schd_data.(json.Object)["shaders"].(json.Array)

	for shader in shaders {
		if shader.(json.Object)["slang"].(json.String) == program_name {
			return shader.(json.Object)["programs"].(json.Array)[0].(json.Object)
		}
	}

	return nil
}

get_attr_vertex_format :: proc(format: string) -> sg.Vertex_Attr_State {
	switch format {
	case "float":
		return {format = .FLOAT}
	case "vec2":
		return {format = .FLOAT2}
	case "vec3":
		return {format = .FLOAT3}
	case "vec4":
		return {format = .FLOAT4}
	}
	return {format = .INVALID}
}

create_shader_desc_from_schd :: proc(
	backend: sg.Backend,
	schd_data: []byte,
) -> (
	sg.Shader_Desc,
	[16]sg.Vertex_Attr_State,
) {
	json_data, json_ok := json.parse(schd_data)
	desc: sg.Shader_Desc
	formats := [16]sg.Vertex_Attr_State{}

	#partial switch backend {
	case .GLCORE:
		program := find_program_in_schd(json_data, "glsl430")

		desc.label = strings.clone_to_cstring(program["name"].(json.String))
		desc.vertex_func.source = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["data"].(json.String),
		)
		desc.vertex_func.entry = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["entry_point"].(json.String),
		)
		desc.fragment_func.source = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["data"].(json.String),
		)
		desc.fragment_func.entry = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["entry_point"].(json.String),
		)

		for attr, attr_index in program["attrs"].(json.Array) {
			attr_obj := attr.(json.Object)
			attr_type := attr_obj["type"].(json.String)
			formats[attr_index] = get_attr_vertex_format(attr_type)

			desc.attrs[attr_index].base_type = get_shader_attr_type(attr_type)
			desc.attrs[attr_index].glsl_name = strings.clone_to_cstring(
				attr_obj["glsl_name"].(json.String),
			)
		}

		for uniform_block, uniform_index in program["uniform_blocks"].(json.Array) {
			uniform_block_obj := uniform_block.(json.Object)

			desc.uniform_blocks[uniform_index].stage = get_shader_stage(
				uniform_block_obj["stage"].(json.String),
			)
			desc.uniform_blocks[uniform_index].layout = .STD140
			desc.uniform_blocks[uniform_index].size = u32(uniform_block_obj["size"].(json.Integer))

			glsl_uniforms := uniform_block_obj["glsl_uniforms"].(json.Array)
			for glsl_uniform, glsl_index in glsl_uniforms {
				glsl_uniform_obj := glsl_uniform.(json.Object)

				desc.uniform_blocks[uniform_index].glsl_uniforms[glsl_index].type =
					get_uniform_type(glsl_uniform_obj["type"].(json.String))
				desc.uniform_blocks[uniform_index].glsl_uniforms[glsl_index].array_count = u16(
					glsl_uniform_obj["array_count"].(json.Integer),
				)
				desc.uniform_blocks[uniform_index].glsl_uniforms[glsl_index].glsl_name =
					strings.clone_to_cstring(glsl_uniform_obj["struct_name"].(json.String))
			}
		}

		for view, view_index in program["views"].(json.Array) {
			view_obj := view.(json.Object)

			desc.views[view_index].texture.stage = get_shader_stage(
				view_obj["stage"].(json.String),
			)
			desc.views[view_index].texture.image_type = get_image_type(
				view_obj["type"].(json.String),
			)
			desc.views[view_index].texture.sample_type = get_image_sample_type(
				view_obj["sample_type"].(json.String),
			)
			desc.views[view_index].texture.multisampled = view_obj["multisampled"].(json.Boolean)
		}

		for sampler, sampler_index in program["samplers"].(json.Array) {
			sampler_obj := sampler.(json.Object)

			desc.samplers[sampler_index].stage = get_shader_stage(
				sampler_obj["stage"].(json.String),
			)
			desc.samplers[sampler_index].sampler_type = get_sampler_type(
				sampler_obj["sampler_type"].(json.String),
			)
		}

		for pair, pair_index in program["texture_sampler_pairs"].(json.Array) {
			pair_obj := pair.(json.Object)

			desc.texture_sampler_pairs[pair_index].stage = get_shader_stage(
				pair_obj["stage"].(json.String),
			)
			desc.texture_sampler_pairs[pair_index].view_slot = u8(
				pair_obj["view_slot"].(json.Integer),
			)
			desc.texture_sampler_pairs[pair_index].sampler_slot = u8(
				pair_obj["sampler_slot"].(json.Integer),
			)
			desc.texture_sampler_pairs[pair_index].glsl_name = strings.clone_to_cstring(
				fmt.aprintf(
					"%s_%s",
					pair_obj["view_name"].(json.String),
					pair_obj["sampler_name"].(json.String),
				),
			)
		}
	case .D3D11:
		program := find_program_in_schd(json_data, "hlsl5")

		desc.label = strings.clone_to_cstring(program["name"].(json.String))
		desc.vertex_func.source = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["data"].(json.String),
		)
		desc.vertex_func.entry = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["d3d11_target"].(json.String),
		)
		desc.vertex_func.d3d11_target = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["entry_point"].(json.String),
		)
		desc.fragment_func.source = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["data"].(json.String),
		)
		desc.fragment_func.entry = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["entry_point"].(json.String),
		)
		desc.fragment_func.d3d11_target = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["d3d11_target"].(json.String),
		)

		for attr, attr_index in program["attrs"].(json.Array) {
			attr_obj := attr.(json.Object)
			attr_type := attr_obj["type"].(json.String)
			formats[attr_index] = get_attr_vertex_format(attr_type)

			desc.attrs[attr_index].base_type = get_shader_attr_type(attr_type)
			desc.attrs[attr_index].hlsl_sem_name = strings.clone_to_cstring(
				attr_obj["hlsl_sem_name"].(json.String),
			)
			desc.attrs[attr_index].hlsl_sem_index = u8(attr_obj["hlsl_sem_index"].(json.Integer))
		}

		for uniform_block, uniform_index in program["uniform_blocks"].(json.Array) {
			uniform_block_obj := uniform_block.(json.Object)

			desc.uniform_blocks[uniform_index].stage = get_shader_stage(
				uniform_block_obj["stage"].(json.String),
			)
			desc.uniform_blocks[uniform_index].layout = .STD140
			desc.uniform_blocks[uniform_index].size = u32(uniform_block_obj["size"].(json.Integer))
			desc.uniform_blocks[uniform_index].hlsl_register_b_n = u8(
				uniform_block_obj["hlsl_register_b_n"].(json.Integer),
			)
		}

		for view, view_index in program["views"].(json.Array) {
			view_obj := view.(json.Object)

			desc.views[view_index].texture.stage = get_shader_stage(
				view_obj["stage"].(json.String),
			)
			desc.views[view_index].texture.image_type = get_image_type(
				view_obj["type"].(json.String),
			)
			desc.views[view_index].texture.sample_type = get_image_sample_type(
				view_obj["sample_type"].(json.String),
			)
			desc.views[view_index].texture.multisampled = view_obj["multisampled"].(json.Boolean)
			desc.views[view_index].texture.hlsl_register_t_n = u8(
				view_obj["hlsl_register_t_n"].(json.Integer),
			)
		}

		for sampler, sampler_index in program["samplers"].(json.Array) {
			sampler_obj := sampler.(json.Object)

			desc.samplers[sampler_index].stage = get_shader_stage(
				sampler_obj["stage"].(json.String),
			)
			desc.samplers[sampler_index].sampler_type = get_sampler_type(
				sampler_obj["sampler_type"].(json.String),
			)
			desc.samplers[sampler_index].hlsl_register_s_n = u8(
				sampler_obj["hlsl_register_s_n"].(json.Integer),
			)
		}

		for pair, pair_index in program["texture_sampler_pairs"].(json.Array) {
			pair_obj := pair.(json.Object)

			desc.texture_sampler_pairs[pair_index].stage = get_shader_stage(
				pair_obj["stage"].(json.String),
			)
			desc.texture_sampler_pairs[pair_index].view_slot = u8(
				pair_obj["view_slot"].(json.Integer),
			)
			desc.texture_sampler_pairs[pair_index].sampler_slot = u8(
				pair_obj["sampler_slot"].(json.Integer),
			)
		}
	case .METAL_MACOS:
		program := find_program_in_schd(json_data, "metal_macos")

		desc.label = strings.clone_to_cstring(program["name"].(json.String))
		desc.vertex_func.source = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["data"].(json.String),
		)
		desc.vertex_func.entry = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["entry_point"].(json.String),
		)
		desc.fragment_func.source = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["data"].(json.String),
		)
		desc.fragment_func.entry = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["entry_point"].(json.String),
		)

		for attr, attr_index in program["attrs"].(json.Array) {
			attr_obj := attr.(json.Object)
			attr_type := attr_obj["type"].(json.String)
			formats[attr_index] = get_attr_vertex_format(attr_type)

			desc.attrs[attr_index].base_type = get_shader_attr_type(attr_type)
		}

		for uniform_block, uniform_index in program["uniform_blocks"].(json.Array) {
			uniform_block_obj := uniform_block.(json.Object)

			desc.uniform_blocks[uniform_index].stage = get_shader_stage(
				uniform_block_obj["stage"].(json.String),
			)
			desc.uniform_blocks[uniform_index].layout = .STD140
			desc.uniform_blocks[uniform_index].size = u32(uniform_block_obj["size"].(json.Integer))
			desc.uniform_blocks[uniform_index].msl_buffer_n = u8(
				uniform_block_obj["msl_buffer_n"].(json.Integer),
			)
		}

		for view, view_index in program["views"].(json.Array) {
			view_obj := view.(json.Object)

			desc.views[view_index].texture.stage = get_shader_stage(
				view_obj["stage"].(json.String),
			)
			desc.views[view_index].texture.image_type = get_image_type(
				view_obj["type"].(json.String),
			)
			desc.views[view_index].texture.sample_type = get_image_sample_type(
				view_obj["sample_type"].(json.String),
			)
			desc.views[view_index].texture.multisampled = view_obj["multisampled"].(json.Boolean)
			desc.views[view_index].texture.msl_texture_n = u8(
				view_obj["msl_texture_n"].(json.Integer),
			)
		}

		for sampler, sampler_index in program["samplers"].(json.Array) {
			sampler_obj := sampler.(json.Object)

			desc.samplers[sampler_index].stage = get_shader_stage(
				sampler_obj["stage"].(json.String),
			)
			desc.samplers[sampler_index].sampler_type = get_sampler_type(
				sampler_obj["sampler_type"].(json.String),
			)
			desc.samplers[sampler_index].msl_sampler_n = u8(
				sampler_obj["msl_sampler_n"].(json.Integer),
			)
		}

		for pair, pair_index in program["texture_sampler_pairs"].(json.Array) {
			pair_obj := pair.(json.Object)

			desc.texture_sampler_pairs[pair_index].stage = get_shader_stage(
				pair_obj["stage"].(json.String),
			)
			desc.texture_sampler_pairs[pair_index].view_slot = u8(
				pair_obj["view_slot"].(json.Integer),
			)
			desc.texture_sampler_pairs[pair_index].sampler_slot = u8(
				pair_obj["sampler_slot"].(json.Integer),
			)
		}
	case .WGPU:
		program := find_program_in_schd(json_data, "wgsl")

		desc.label = strings.clone_to_cstring(program["name"].(json.String))
		desc.vertex_func.source = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["data"].(json.String),
		)
		desc.vertex_func.entry = strings.clone_to_cstring(
			program["vertex_func"].(json.Object)["entry_point"].(json.String),
		)
		desc.fragment_func.source = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["data"].(json.String),
		)
		desc.fragment_func.entry = strings.clone_to_cstring(
			program["fragment_func"].(json.Object)["entry_point"].(json.String),
		)

		for attr, attr_index in program["attrs"].(json.Array) {
			attr_obj := attr.(json.Object)
			attr_type := attr_obj["type"].(json.String)
			formats[attr_index] = get_attr_vertex_format(attr_type)

			desc.attrs[attr_index].base_type = get_shader_attr_type(attr_type)
		}

		for uniform_block, uniform_index in program["uniform_blocks"].(json.Array) {
			uniform_block_obj := uniform_block.(json.Object)

			desc.uniform_blocks[uniform_index].stage = get_shader_stage(
				uniform_block_obj["stage"].(json.String),
			)
			desc.uniform_blocks[uniform_index].layout = .STD140
			desc.uniform_blocks[uniform_index].size = u32(uniform_block_obj["size"].(json.Integer))
			desc.uniform_blocks[uniform_index].wgsl_group0_binding_n = u8(
				uniform_block_obj["wgsl_group0_binding_n"].(json.Integer),
			)
		}

		for view, view_index in program["views"].(json.Array) {
			view_obj := view.(json.Object)

			desc.views[view_index].texture.stage = get_shader_stage(
				view_obj["stage"].(json.String),
			)
			desc.views[view_index].texture.image_type = get_image_type(
				view_obj["type"].(json.String),
			)
			desc.views[view_index].texture.sample_type = get_image_sample_type(
				view_obj["sample_type"].(json.String),
			)
			desc.views[view_index].texture.multisampled = view_obj["multisampled"].(json.Boolean)
			desc.views[view_index].texture.wgsl_group1_binding_n = u8(
				view_obj["wgsl_group1_binding_n"].(json.Integer),
			)
		}

		for sampler, sampler_index in program["samplers"].(json.Array) {
			sampler_obj := sampler.(json.Object)

			desc.samplers[sampler_index].stage = get_shader_stage(
				sampler_obj["stage"].(json.String),
			)
			desc.samplers[sampler_index].sampler_type = get_sampler_type(
				sampler_obj["sampler_type"].(json.String),
			)
			desc.samplers[sampler_index].wgsl_group1_binding_n = u8(
				sampler_obj["wgsl_group1_binding_n"].(json.Integer),
			)
		}

		for pair, pair_index in program["texture_sampler_pairs"].(json.Array) {
			pair_obj := pair.(json.Object)

			desc.texture_sampler_pairs[pair_index].stage = get_shader_stage(
				pair_obj["stage"].(json.String),
			)
			desc.texture_sampler_pairs[pair_index].view_slot = u8(
				pair_obj["view_slot"].(json.Integer),
			)
			desc.texture_sampler_pairs[pair_index].sampler_slot = u8(
				pair_obj["sampler_slot"].(json.Integer),
			)
		}
	}
	return desc, formats
}
