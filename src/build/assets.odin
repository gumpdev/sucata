package build

import "../common"
import "core:bytes"
import "core:crypto/hash"
import "core:encoding/hex"
import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "vendor:compress/lz4"

generate_assets :: proc(src_path: string, main_file: string, output_path: string) -> string {
	files := make([dynamic]string)
	defer delete(files)

	collect_files(src_path, &files)

	fmt.println("Found", len(files), "files to package. src:", src_path)

	entries := make([dynamic]common.Asset_Entry)
	defer delete(entries)

	buf: bytes.Buffer
	bytes.buffer_init_allocator(&buf, 0, 0, context.allocator)
	defer bytes.buffer_destroy(&buf)

	total_size := 0

	for file in files {
		if strings.has_suffix(file, ".exe") {
			continue
		}
		if strings.has_suffix(file, ".dll") {
			continue
		}
		if strings.has_suffix(file, ".scta") {
			continue
		}

		data, read_ok := os.read_entire_file(file)
		defer delete(data)

		rel_path, rel_err := filepath.rel(src_path, file)
		if rel_err != nil {
			rel_path = file
		}
		if main_file == file {
			rel_path = "main.lua"
		}

		normalized_path, was_allocated := strings.replace_all(rel_path, "\\", "/")
		if was_allocated {
			delete(rel_path)
			rel_path = normalized_path
		}

		entry := common.Asset_Entry {
			path   = rel_path,
			size   = len(data),
			offset = total_size,
		}
		append(&entries, entry)

		bytes.buffer_write(&buf, data)
		total_size += len(data)
	}

	uncompressed_data := bytes.buffer_to_bytes(&buf)

	max_compressed_size := lz4.compressBound(cast(i32)len(uncompressed_data))
	compressed_buffer := make([]byte, max_compressed_size)
	defer delete(compressed_buffer)

	compressed_size := lz4.compress_default(
		raw_data(uncompressed_data),
		raw_data(compressed_buffer),
		cast(i32)len(uncompressed_data),
		max_compressed_size,
	)

	archive_data := compressed_buffer[:compressed_size]

	output_file_path := filepath.join({output_path, DEFAULT_ASSETS_PATH})
	output_handle, open_err := os.open(
		output_file_path,
		os.O_WRONLY | os.O_CREATE | os.O_TRUNC,
		0o644,
	)
	defer os.close(output_handle)

	json_data, json_err := json.marshal(entries[:])
	defer delete(json_data)

	header_size := u64(len(json_data))
	header_bytes := mem.ptr_to_bytes(&header_size)

	os.write(output_handle, header_bytes)
	os.write(output_handle, json_data)
	os.write(output_handle, archive_data)

	hash_string := get_assets_hash(output_file_path)

	return string(hash_string)
}

get_assets_hash :: proc(assets_path: string) -> string {
	file_data, read_ok := os.read_entire_file(assets_path)
	defer delete(file_data)

	hash_bytes: [32]byte
	hash.hash(hash.Algorithm.SHA256, file_data, hash_bytes[:])

	hash_string := hex.encode(hash_bytes[:])

	return string(hash_string)
}

collect_files :: proc(dir_path: string, files: ^[dynamic]string) -> os.Errno {
	if (strings.has_suffix(dir_path, ".git") ||
		   strings.has_suffix(dir_path, "node_modules") ||
		   strings.has_suffix(dir_path, "build")) {
		return os.ERROR_NONE
	}
	dir_handle, open_err := os.open(dir_path, os.O_RDONLY, 0)
	if open_err != os.ERROR_NONE {
		return open_err
	}
	defer os.close(dir_handle)

	file_infos, read_err := os.read_dir(dir_handle, -1)
	if read_err != os.ERROR_NONE {
		return read_err
	}
	defer os.file_info_slice_delete(file_infos)

	for info in file_infos {
		full_path := filepath.join({dir_path, info.name})
		defer delete(full_path)

		if info.is_dir {
			if err := collect_files(full_path, files); err != os.ERROR_NONE {
				return err
			}
		} else {
			append(files, filepath.clean(full_path))
		}
	}

	return os.ERROR_NONE
}
