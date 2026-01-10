package cli

import "core:fmt"
import "core:os"

VERSION :: "0.1.0"
VERSION_TYPE :: "stable"
RELEASED_ON :: "2026-01"
CLI_COMMANDS :: []CLICommand{RUN_COMMAND, BUILD_COMMAND, VERSION_COMMAND, SHADER_COMMAND}

main :: proc() {
	welcome_message()

	args := os.args

	if len(args) < 2 {
		help()
		return
	}

	for command in CLI_COMMANDS {
		if args[1] == command.name {
			if len(args) - 2 < command.args_size {
				fmt.println(command.error_msg)
				return
			}
			command.handler(args[2:])
			return
		}
	}

	fmt.println("Unknown command:", args[1])
	help()
}

welcome_message :: proc() {
	fmt.printfln("Sucata Game Engine - %s-%s", VERSION, VERSION_TYPE)
}

help :: proc() {
	fmt.println("Available commands:")
	for command in CLI_COMMANDS {
		fmt.println(" - ", command.info_msg)
	}
}
