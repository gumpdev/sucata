package main

import build "./src/build"
import cli "./src/cli"
import core "./src/core"
import "base:runtime"
import "core:log"

main :: proc() {
	context.logger = log.create_console_logger()
	core.DEFAULT_CONTEXT = context

	build_hash, is_build := build.get_build()
	core.is_build_mode = is_build

	if core.is_build_mode {
		build.run(build_hash)
		return
	}

	cli.main()
}
