package cli

import "../path"
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:path/filepath"

RUN_COMMAND :: Command {
	command = "run",
	args_size = 1,
	info_msg = "sucata run <file> - Run a Sucata Lua script file",
	error_msg = "Error: 'run' command requires a <file> argument.",
	handler = proc(args: []string) {
		file_path := args[0]
		file_path = filepath.join({os.get_current_directory(), file_path})
		sucata_path := path.get_sucata_player_path()

		process_desc := os2.Process_Desc {
			command = {"cmd", "/C", sucata_path, file_path},
			stdout  = os2.stdout,
			stderr  = os2.stderr,
		}
		process, _ := os2.process_start(process_desc)
		state, _ := os2.process_wait(process)
		if state.exited {
			fmt.printfln("Process exited with code: %d", state.exit_code)
		}
	},
}
