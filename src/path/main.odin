package path

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
	result_path := location_path
	ok := false

	result_path, ok = strings.replace_all(result_path, "src:/", location.src)
	result_path, ok = strings.replace_all(result_path, "data:/", location.data)
	result_path, ok = strings.replace_all(result_path, "build:/", location.build)

	return result_path
}
