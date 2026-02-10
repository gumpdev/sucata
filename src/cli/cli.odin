package cli

import "../common"

parse_cli :: proc(cmds: Command, args: []string) {
	if len(args) == 0 {
		help_commands(cmds, args)
		return
	}

	command, ok := find_command(cmds, args[0])
	if !ok {
		help_commands(cmds, args)
		return
	}

	if len(command.subcommands) > 0 {
		parse_cli(command, args[1:])
		return
	}

	if command.args_size > len(args) - 1 {
		error_command(command)
		return
	}

	command.handler(args[1:])
}

error_command :: proc(cmd: Command) {
	common.print_error(cmd.error_msg)
}

help_commands :: proc(cmds: Command, args: []string) {
	if len(args) > 1 {
		common.print_error("Command '%s' not found", args[0])
	}
	if cmds.command == "" {
		common.print("Available commands:")
	} else {
		common.print("Available %s commands:", cmds.command)
	}
	for cmd in cmds.subcommands {
		common.print("  %s", cmd.info_msg)
	}
}

find_command :: proc(cmds: Command, cmd_name: string) -> (Command, bool) {
	for cmd in cmds.subcommands {
		if cmd.command == cmd_name {
			return cmd, true
		}
	}
	return {}, false
}
