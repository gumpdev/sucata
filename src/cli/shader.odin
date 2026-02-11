package cli

import "../common"
import path "../path"
import "../shaderbuilder"
import "core:os"
import "core:path/filepath"

SHADER_COMMAND :: Command {
	command     = "shader",
	info_msg    = "sucata shader - Util to shaders on sucata",
	subcommands = {SHADER_BUILD_COMMAND, SHADER_CREATE_COMMAND},
}

SHADER_BUILD_COMMAND :: Command {
	command = "build",
	args_size = 1,
	info_msg = "sucata shader build <file> - Builds a .glsl file to sucata shader file",
	error_msg = "Error: 'build' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		path.init_run_paths(file_path, "shader.glsl")

		common.print_info("Building shader: %s", path.location.file)

		output_path, success := shaderbuilder.build_shader(file_path)
		if success {
			common.print_success("Generated sucata shader: %s", output_path)
		} else {
			common.print_error("Failed to build shader: %s", path.location.file)
		}
	},
}

SHADER_CREATE_COMMAND :: Command {
	command = "create",
	args_size = 1,
	info_msg = "sucata shader create <file> [--post-procesing] [--font] - Create a base .glsl shader file",
	error_msg = "Error: 'create' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		aditional_flags := args[1:]
		is_post_processing := false
		is_font_shader := false
		for flag in aditional_flags {
			if flag == "--post-processing" {
				is_post_processing = true
				break
			}
			if flag == "-pp" {
				is_post_processing = true
				break
			}
			if flag == "--font" {
				is_font_shader = true
				break
			}
			if flag == "-f" {
				is_font_shader = true
				break
			}
		}

		file_name := filepath.base(file_path)
		if is_post_processing {
			shaderbuilder.create_default_post_processing(file_path)
			common.print_success("%s post processing shader created!", file_name)
		} else if is_font_shader {
			shaderbuilder.create_default_font_shader(file_path)
			common.print_success("%s font shader created!", file_name)
		} else {
			shaderbuilder.create_default_quad(file_path)
			common.print_success("%s custom shader created!", file_name)
		}
	},
}
