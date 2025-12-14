package cli

import "core:fmt"

VERSION_COMMAND :: CLICommand {
	name = "version",
	args_size = 0,
	info_msg = "sucata version - Show the Sucata game engine version",
	error_msg = "Error: 'version' command does not take any arguments.",
	handler = proc(args: []string) {
		fmt.println("Version", VERSION)
		fmt.println("Released on", RELEASED_ON)
	},
}
