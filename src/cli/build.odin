package cli

import build "../build"
import path "../path"
import "core:fmt"
import "core:os"
import "core:path/filepath"

BUILD_COMMAND :: CLICommand {
	name = "build",
	args_size = 1,
	info_msg = "sucata build <file> [--icon <path>] - Build a Sucata Lua script file",
	error_msg = "Error: 'build' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})

		path.init_run_paths(file_path)

		icon_path := ""
		for i := 1; i < len(args); i += 1 {
			if args[i] == "--icon" && i + 1 < len(args) {
				icon_path = filepath.join({os.get_current_directory(), args[i + 1]})
				i += 1
			}
		}

		fmt.println("Building Sucata script:", path.location.file)
		if icon_path != "" {
			fmt.println("Using icon:", icon_path)
		}

		build_path := filepath.join({path.location.build, "build"})
		os.make_directory(build_path)
		assets_hash := build.generate_assets(path.location.src, path.location.file, build_path)
		build.clone_engine(build_path, assets_hash, icon_path)

		fmt.println("Sucateado! Game builded on", build_path)
	},
}
