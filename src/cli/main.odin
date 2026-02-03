package cli

import "core:fmt"
import "core:os"

VERSION :: "0.1.1"
VERSION_TYPE :: "stable"
RELEASED_ON :: "2026-01"
ROOT_COMMAND :: Command {
	subcommands = {RUN_COMMAND, BUILD_COMMAND, VERSION_COMMAND, SHADER_COMMAND},
}

main :: proc() {
	welcome_message()

	args := os.args
	parse_cli(ROOT_COMMAND, args[1:])
}

welcome_message :: proc() {
	fmt.printfln("Sucata Game Engine - %s-%s", VERSION, VERSION_TYPE)
}
