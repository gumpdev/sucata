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

	if header_size == 0 || int(header_size) > len(file_data) - 8 {
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

	assets = new(common.Asset_Archive)
	assets.entries = entries
	assets.path = asset_path

	return true
}

get_entry :: proc(path: string) -> ^common.Asset_Entry {
	if assets == nil {
		return nil
	}
	for &entry in assets.entries {
		if strings.equal_fold(entry.path, path) {
			return &entry
		}
	}
	return nil
}

unload_asset :: proc(file_path: string, allocator := context.allocator) {
	if assets == nil {
		return
	}

	clean_path := file_path
	if strings.has_prefix(file_path, "src://") {
		clean_path = file_path[6:]
	}

	entry := get_entry(clean_path)
	if entry == nil {
		return
	}
	delete(entry.cache)
}

load_asset :: proc(path: string, allocator := context.allocator) -> (data: []byte, ok: bool) {
	if assets == nil {
		return nil, false
	}

	entry := get_entry(path)
	if entry == nil {
		return nil, false
	}

	if entry.cache != nil {
		return entry.cache, true
	}

	file_data, read_ok := os.read_entire_file(assets.path)
	if !read_ok {
		return nil, false
	}
	defer delete(file_data)

	if len(file_data) < 8 {
		return nil, false
	}

	header_size := (^u64)(raw_data(file_data))^

	if header_size == 0 || int(header_size) > len(file_data) - 8 {
		return nil, false
	}

	json_start := 8
	json_end := json_start + int(header_size)
	compressed_data := file_data[json_end:]

	total_uncompressed_size := 0
	if len(assets.entries) > 0 {
		last_entry := assets.entries[len(assets.entries) - 1]
		total_uncompressed_size = last_entry.offset + last_entry.size
	}

	decompressed_buffer := make([]byte, total_uncompressed_size, allocator)
	defer delete(decompressed_buffer)
	decompressed_size := lz4.decompress_safe(
		raw_data(compressed_data),
		raw_data(decompressed_buffer),
		cast(i32)len(compressed_data),
		cast(i32)total_uncompressed_size,
	)

	decompressed_data := decompressed_buffer[entry.offset:entry.offset + entry.size]
	entry_data := make([]byte, len(decompressed_data))
	copy(entry_data, decompressed_data)

	entry.cache = entry_data

	return entry_data, true
}

unload_assets :: proc(allocator := context.allocator) {
	context.allocator = allocator
	if assets != nil {
		delete(assets.entries)
		free(assets)
		assets = nil
	}
}

get_asset :: proc(file_path: string, allocator := context.allocator) -> (data: []byte, ok: bool) {
	context.allocator = allocator
	if assets == nil {
		return nil, false
	}

	clean_path := file_path
	if strings.has_prefix(file_path, "src://") {
		clean_path = file_path[6:]
	}

	vlr, vlr_ok := load_asset(clean_path, allocator)
	return vlr, vlr_ok
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
	defer delete(matching)
	for entry in assets.entries {
		if strings.has_prefix(entry.path, prefix) {
			append(&matching, entry.path)
		}
	}
	return matching[:]
}
