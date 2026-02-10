package cli

import "../common"
import "core:os"

VERSION :: "0.1.2"
VERSION_TYPE :: "nightly"
RELEASED_ON :: "2026-02"
ROOT_COMMAND :: Command {
	subcommands = {RUN_COMMAND, BUILD_COMMAND, VERSION_COMMAND, SHADER_COMMAND},
}

main :: proc() {
	welcome_message()

	args := os.args
	parse_cli(ROOT_COMMAND, args[1:])
}

welcome_message :: proc() {
	common.print("Sucata Game Engine - %s-%s", VERSION, VERSION_TYPE)
}
