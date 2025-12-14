package build

import "core:os"
import "core:path/filepath"
import "core:strings"

get_build :: proc(allocator := context.allocator) -> (hash: string, ok: bool) {
	context.allocator = allocator

	exe_path, _ := filepath.abs(os.args[0])

	file_data, read_ok := os.read_entire_file(exe_path)
	if !read_ok {
		return "", false
	}
	defer delete(file_data)

	if len(file_data) < 8 {
		return "", false
	}

	size_bytes := file_data[len(file_data) - 8:]
	header_size := (^u64)(raw_data(size_bytes))^

	total_metadata_size := int(header_size) + 8
	if total_metadata_size > len(file_data) || int(header_size) < len(BUILD_HEADER) {
		return "", false
	}

	header_start := len(file_data) - total_metadata_size
	header_end := len(file_data) - 8
	header_data := file_data[header_start:header_end]
	header_string := string(header_data)

	if !strings.has_prefix(header_string, BUILD_HEADER) {
		return "", false
	}

	hash_value := strings.clone(strings.trim_prefix(header_string, BUILD_HEADER))

	return hash_value, true
}
