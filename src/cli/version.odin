package cli

import "core:fmt"

VERSION_COMMAND :: Command {
	command = "version",
	args_size = 0,
	info_msg = "sucata version - Show the Sucata game engine version",
	error_msg = "Error: 'version' command does not take any arguments.",
	handler = proc(args: []string) {
		fmt.printfln("Version %s-%s", VERSION, VERSION_TYPE)
		fmt.println("Released on", RELEASED_ON)
	},
}
