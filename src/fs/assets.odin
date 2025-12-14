package fs

import "../common"
import "core:encoding/json"
import "core:os"
import "core:strings"
import "vendor:compress/lz4"

assets: ^common.Asset_Archive = nil

load_assets :: proc(asset_path: string, allocator := context.allocator) -> bool {
	context.allocator = allocator

	file_data, read_ok := os.read_entire_file(asset_path)
	if !read_ok {
		return false
	}
	defer delete(file_data)

	if len(file_data) < 8 {
		return false
	}

	header_size := (^u64)(raw_data(file_data))^

	if int(header_size) > len(file_data) - 8 {
		return false
	}

	json_start := 8
	json_end := json_start + int(header_size)
	json_data := file_data[json_start:json_end]

	entries: []common.Asset_Entry
	unmarshal_err := json.unmarshal(json_data, &entries)
	if unmarshal_err != nil {
		return false
	}

	compressed_data := file_data[json_end:]

	total_uncompressed_size := 0
	if len(entries) > 0 {
		last_entry := entries[len(entries) - 1]
		total_uncompressed_size = last_entry.offset + last_entry.size
	}

	decompressed_buffer := make([]byte, total_uncompressed_size, allocator)

	decompressed_size := lz4.decompress_safe(
		raw_data(compressed_data),
		raw_data(decompressed_buffer),
		cast(i32)len(compressed_data),
		cast(i32)total_uncompressed_size,
	)

	if decompressed_size != cast(i32)total_uncompressed_size {
		delete(entries)
		delete(decompressed_buffer)
		return false
	}

	assets = new(common.Asset_Archive)
	assets.entries = entries
	assets.decompressed_data = decompressed_buffer

	return true
}

unload_assets :: proc(allocator := context.allocator) {
	context.allocator = allocator
	delete(assets.entries)
	delete(assets.decompressed_data)
	assets^ = {}
}

get_asset :: proc(path: string, allocator := context.allocator) -> (data: []byte, ok: bool) {
	context.allocator = allocator
	if assets == nil {
		return nil, false
	}

	clean_path := path
	if strings.has_prefix(path, "src://") {
		clean_path = path[6:]
	}

	for entry in assets.entries {
		if entry.path == clean_path || entry.path == path {
			start := entry.offset
			end := entry.offset + entry.size
			return assets.decompressed_data[start:end], true
		}
	}
	return nil, false
}

list_assets :: proc(allocator := context.allocator) -> []string {
	context.allocator = allocator
	paths := make([]string, len(assets.entries))
	for entry, i in assets.entries {
		paths[i] = entry.path
	}
	return paths
}

find_assets_with_prefix :: proc(prefix: string, allocator := context.allocator) -> []string {
	context.allocator = allocator

	matching := make([dynamic]string)
	for entry in assets.entries {
		if strings.has_prefix(entry.path, prefix) {
			append(&matching, entry.path)
		}
	}
	return matching[:]
}
