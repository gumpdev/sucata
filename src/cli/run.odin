package cli

import core "../core"
import lua "../lua"
import path "../path"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

RUN_COMMAND :: CLICommand {
	name = "run",
	args_size = 1,
	info_msg = "sucata run <file> [--entity <entity_file>] - Run a Sucata Lua script file",
	error_msg = "Error: 'run' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		entity_file: string = ""
		for i := 1; i < len(args); i += 1 {
			if args[i] == "--entity" && i + 1 < len(args) {
				entity_file = args[i + 1]
				i += 1
			}
		}

		path.init_run_paths(file_path)

		if entity_file != "" {
			fmt.println(
				"Running entity file:",
				entity_file,
				"on the Sucata project:",
				path.location.file,
			)
		} else {
			fmt.println("Running Sucata project: ", path.location.file)
		}

		lua.init_lua(path.location.file, strings.trim_suffix(entity_file, ".lua"))
		core.main()
	},
}
