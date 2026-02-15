package src

import build "./build"
import "./common"
import core "./core"
import lua "./lua"
import path "./path"
import "core:log"
import "core:os"

main :: proc() {
	context.logger = log.create_console_logger()
	core.DEFAULT_CONTEXT = context
	core.init_temp_arena()

	build_hash, is_build := build.get_build()
	core.is_build_mode = is_build

	if core.is_build_mode {
		build.run(build_hash)
		return
	}

	args := os.args
	if len(args) < 2 {
		common.print_error("You need to pass at least one argument to run it.")
		return
	}

	run(args[1:])
}

run :: proc(args: []string) {
	file_path := args[0]

	path.init_run_paths(file_path)
	common.print("Running Sucata project: %s", path.location.file)

	lua.init_lua(path.location.file)
	core.main()
}
