package path

import "core:fmt"
import "core:strings"

location := PathLocation{}

PathLocation :: struct {
	file:   string,
	src:    string,
	data:   string,
	build:  string,
	name:   string,
	system: string,
}

get_path :: proc(location_path: string) -> string {
	if strings.has_prefix(location_path, "src:/") {
		return fmt.tprintf("%s/%s", location.src, strings.trim_prefix(location_path, "src://"))
	}

	if strings.has_prefix(location_path, "data:/") {
		return fmt.tprintf("%s/%s", location.data, strings.trim_prefix(location_path, "data://"))
	}

	if strings.has_prefix(location_path, "build:/") {
		return fmt.tprintf("%s/%s", location.build, strings.trim_prefix(location_path, "build://"))
	}

	return location_path
}
