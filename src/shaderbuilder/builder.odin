package shader_builder

import "core:fmt"
import "core:os/os2"
import "core:path/filepath"
import "core:strings"

build_shader :: proc(input_file: string) -> bool {
	ok, temp_path := build_sokol_shader(input_file)

	shader_name := strings.split(filepath.base(input_file), ".")[0]
	output_path := filepath.join({filepath.dir(input_file), fmt.aprintf("%s.schd", shader_name)})

	if ok {
		generate_json(temp_path, output_path)
		remove_temp_folder(filepath.dir(temp_path))

		fmt.println("Generated sucata shader:", output_path)
	}

	return ok
}

remove_temp_folder :: proc(temp_path: string) {
	if os2.exists(temp_path) {
		os2.remove_all(temp_path)
	}
}
