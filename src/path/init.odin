package path

import "core:os"
import "core:path/filepath"

init_run_paths :: proc(file: string) {
	file_absolute, ok_file_absolute := filepath.abs(file)

	if os.is_file(file) {
		location.file = file_absolute
	} else {
		location.file = filepath.join({file_absolute, "main.lua"})
	}

	location.src = filepath.dir(location.file)
	location.build = filepath.dir(location.file)
	location.name = filepath.base(location.src)

	when ODIN_OS == .Windows {
		location.data = get_config_dir("windows")
		location.system = "windows"
	} else when ODIN_OS == .Darwin {
		location.data = get_config_dir("darwin")
		location.system = "darwin"
	} else when ODIN_OS == .Linux {
		location.data = get_config_dir("linux")
		location.system = "linux"
	}
}

init_build_paths :: proc(assets_file: string) {
	location.file = "main.lua"
	location.src = filepath.dir(assets_file)
	location.build = filepath.dir(assets_file)
	location.name = filepath.base(location.src)

	when ODIN_OS == .Windows {
		location.data = get_config_dir("windows")
		location.system = "windows"
	} else when ODIN_OS == .Darwin {
		location.data = get_config_dir("darwin")
		location.system = "darwin"
	} else when ODIN_OS == .Linux {
		location.data = get_config_dir("linux")
		location.system = "linux"
	}
}

get_config_dir :: proc(system: string) -> string {
	if system == "windows" {
		appdata := os.get_env("APPDATA")
		if appdata != "" {
			return appdata
		}
	}

	if system == "linux" {
		home := os.get_env("HOME")
		if home != "" {
			return filepath.join({home, ".local", "share"})
		}
	}

	if system == "darwin" {
		home := os.get_env("HOME")
		if home != "" {
			return filepath.join({home, "Library", "Application Support"})
		}
	}

	return "."
}
