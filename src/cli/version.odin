package cli

import "../common"

VERSION_COMMAND :: Command {
	command = "version",
	args_size = 0,
	info_msg = "sucata version - Show the Sucata game engine version",
	error_msg = "Error: 'version' command does not take any arguments.",
	handler = proc(args: []string) {
		common.print("Version %s-%s", VERSION, VERSION_TYPE)
		common.print_info("Released on %s", RELEASED_ON)
	},
}
