package path

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

init_run_paths :: proc(file: string, default_file: string = "main.lua") {
	file_absolute, ok_file_absolute := filepath.abs(file)

	if os.is_file(file) {
		location.file = file_absolute
	} else {
		location.file = filepath.join({file_absolute, default_file})
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

get_executable_path :: proc() -> string {
	arg0 := os.args[0]

	if filepath.is_abs(arg0) {
		return arg0
	}

	abs_path, ok := filepath.abs(arg0)
	if ok && os.exists(abs_path) {
		return abs_path
	}

	when ODIN_OS == .Windows {
		if !filepath.is_abs(arg0) {
			path_env := os.get_env("PATH")
			defer delete(path_env)

			paths := strings.split(path_env, ";")
			defer delete(paths)

			base_name := strings.trim_suffix(arg0, ".exe")

			for dir_path in paths {
				full_path_exe := filepath.join({dir_path, fmt.tprintf("{0}.exe", base_name)})
				if os.exists(full_path_exe) {
					return full_path_exe
				}

				full_path := filepath.join({dir_path, arg0})
				if os.exists(full_path) {
					return full_path
				}
			}
		}
	} else when ODIN_OS == .Darwin || ODIN_OS == .Linux || ODIN_OS == .FreeBSD {
		if !filepath.is_abs(arg0) && !strings.contains(arg0, "/") {
			path_env := os.get_env("PATH")
			defer delete(path_env)

			paths := strings.split(path_env, ":")
			defer delete(paths)

			for dir_path in paths {
				full_path := filepath.join({dir_path, arg0})
				if os.exists(full_path) {
					return full_path
				}
			}
		}
	}

	return arg0
}
