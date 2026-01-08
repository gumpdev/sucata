package shader_builder

import "../path"
import "base:runtime"
import "core:fmt"
import "core:os/os2"
import "core:path/filepath"

build_sokol_shader :: proc(input_file: string) -> (bool, string) {
	sucata_path := filepath.dir(path.get_executable_path())
	if !os2.exists(input_file) {
		fmt.eprintln("Shader file does not exist:", input_file)
		return false, ""
	}
	if !os2.exists(filepath.join({sucata_path, "temp"})) {
		os2.make_directory(filepath.join({sucata_path, "temp"}))
	}
	temp_shader_path := filepath.join({sucata_path, "temp", "shader"})

	sokol_shdc_path := get_sokol_shdc_path()

	if sokol_shdc_path == "" {
		return false, ""
	}

	process_desc := os2.Process_Desc {
		command = {
			sokol_shdc_path,
			"-i",
			input_file,
			"-o",
			temp_shader_path,
			"-l",
			"glsl430:hlsl5:metal_macos:wgsl",
			"-f",
			"bare_yaml",
		},
	}

	process_state, stdout_file, stderr_file, err := os2.process_exec(
		process_desc,
		context.allocator,
	)
	if err != nil {
		fmt.eprintln("Failed to execute process:", err)
		os2.exit(1)
	}

	defer delete(stdout_file)
	defer delete(stderr_file)

	output_temp_path := fmt.aprintf("{}_reflection.yaml", temp_shader_path)
	return true, output_temp_path
}

remove_temp :: proc() {
	sucata_path := filepath.dir(path.get_executable_path())
	temp_path := filepath.join({sucata_path, "temp"})
	if os2.exists(temp_path) {
		os2.remove_all(temp_path)
	}
}

get_sokol_shdc_path :: proc() -> string {
	sucata_path := filepath.dir(path.get_executable_path())

	shdc_path := ""

	when ODIN_OS == .Windows {
		shdc_path = filepath.join({sucata_path, "sokol-shdc", "sokol-shdc-win.exe"})
	} else when ODIN_OS == .Darwin {
		when ODIN_ARCH == .arm64 {
			shdc_path = filepath.join({sucata_path, "sokol-shdc", "sokol-shdc-osx-arm"})
		} else {
			shdc_path = filepath.join({sucata_path, "sokol-shdc", "sokol-shdc-osx"})
		}
	} else when ODIN_OS == .Linux {
		when ODIN_ARCH == .arm64 {
			shdc_path = filepath.join({sucata_path, "sokol-shdc", "sokol-shdc-linux-arm"})
		} else {
			shdc_path = filepath.join({sucata_path, "sokol-shdc", "sokol-shdc-linux"})
		}
	}

	return shdc_path
}
