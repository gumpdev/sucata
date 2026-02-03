package cli

import path "../path"
import "../shaderbuilder"
import "core:fmt"
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

		path.init_run_paths(file_path)

		fmt.println("Building shader:", path.location.file)

		shaderbuilder.build_shader(file_path)
	},
}

SHADER_CREATE_COMMAND :: Command {
	command = "create",
	args_size = 1,
	info_msg = "sucata shader create <file> [--post-procesing] - Create a base .glsl shader file",
	error_msg = "Error: 'create' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		aditional_flags := args[1:]
		is_post_processing := false
		for flag in aditional_flags {
			if flag == "--post-processing" {
				is_post_processing = true
				break
			}
			if flag == "-pp" {
				is_post_processing = true
				break
			}
		}

		file_name := filepath.base(file_path)
		if is_post_processing {
			shaderbuilder.create_default_post_processing(file_path)
			fmt.printfln("%s post processing shader created!", file_name)
		} else {
			shaderbuilder.create_default_quad(file_path)
			fmt.printfln("%s custom shader created!", file_name)
		}
	},
}
