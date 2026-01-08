package cli

import path "../path"
import "../shaderbuilder"
import "core:fmt"
import "core:os"
import "core:path/filepath"

SHADER_COMMAND :: CLICommand {
	name = "shader",
	args_size = 1,
	info_msg = "sucata shader <file> - Build shader to sucata shader file",
	error_msg = "Error: 'shader' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		path.init_run_paths(file_path)

		fmt.println("Building shader:", path.location.file)

		shaderbuilder.build_shader(file_path)
	},
}
