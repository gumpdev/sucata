package build

import "../path"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:strings"

BUILD_HEADER :: "SUCATA_BUILD_"
LUA_DLL_FILE_NAME :: "lua54.dll"

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

clone_engine :: proc(output_dir: string, assets_hash: string, icon_path: string = "") {
	engine_path := get_executable_path()
	fmt.println("Cloning engine from:", engine_path)

	engine_data, read_ok := os.read_entire_file(engine_path)
	defer delete(engine_data)

	engine_name := path.location.name
	if path.location.system == "windows" {
		engine_name = fmt.tprintf("{0}.exe", engine_name)
	}
	output_path := filepath.join({output_dir, engine_name})

	if path.location.system == "darwin" {
		create_macos_app_bundle(output_dir, engine_name, engine_data, assets_hash, icon_path)
		return
	}

	output_handle, open_err := os.open(output_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o755)
	defer os.close(output_handle)

	os.write(output_handle, engine_data)
	write_build_header(output_handle, assets_hash)

	if path.location.system == "windows" {
		remove_console_window(output_path)
		clone_lua_dll(output_dir)
		if icon_path != "" {
			embed_windows_icon(output_path, icon_path)
		}
	} else if path.location.system == "linux" && icon_path != "" {
		icon_output := filepath.join({output_dir, "icon.png"})
		if icon_data, ok := os.read_entire_file(icon_path); ok {
			os.write_entire_file(icon_output, icon_data)
			delete(icon_data)
		}
	}
}

clone_lua_dll :: proc(output_dir: string) {
	executable_path := get_executable_path()
	source_path := filepath.dir(executable_path)
	lua_dll_path := filepath.join({source_path, LUA_DLL_FILE_NAME})

	lua_dll_data, read_ok := os.read_entire_file(lua_dll_path)
	defer delete(lua_dll_data)

	output_path := filepath.join({output_dir, LUA_DLL_FILE_NAME})

	output_handle, open_err := os.open(output_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o755)
	defer os.close(output_handle)

	os.write(output_handle, lua_dll_data)
}

write_build_header :: proc(output_handle: os.Handle, assets_hash: string) {
	build_header_hash := fmt.aprintf("{0}{1}", BUILD_HEADER, assets_hash)
	defer delete(build_header_hash)

	header_bytes := transmute([]byte)build_header_hash
	header_size := u64(len(header_bytes))

	os.write(output_handle, header_bytes)
	os.write(output_handle, mem.ptr_to_bytes(&header_size))
}

create_macos_app_bundle :: proc(
	output_dir: string,
	engine_name: string,
	engine_data: []byte,
	assets_hash: string,
	icon_path: string = "",
) {
	app_name := fmt.tprintf("{0}.app", engine_name)
	app_path := filepath.join({output_dir, app_name})

	contents_path := filepath.join({app_path, "Contents"})
	macos_path := filepath.join({contents_path, "MacOS"})
	resources_path := filepath.join({contents_path, "Resources"})

	os.make_directory(app_path, 0o755)
	os.make_directory(contents_path, 0o755)
	os.make_directory(macos_path, 0o755)
	os.make_directory(resources_path, 0o755)

	executable_path := filepath.join({macos_path, engine_name})
	exe_handle, open_err := os.open(executable_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o755)
	if open_err != 0 {
		fmt.println("Error opening executable for writing:", open_err)
		return
	}

	bytes_written, write_err := os.write(exe_handle, engine_data)
	if write_err != 0 {
		fmt.println("Error writing engine data:", write_err)
		os.close(exe_handle)
		return
	}
	fmt.println("Written", bytes_written, "bytes of engine data")

	write_build_header(exe_handle, assets_hash)
	os.close(exe_handle)

	assets_src := filepath.join({output_dir, DEFAULT_ASSETS_PATH})
	assets_dst := filepath.join({macos_path, DEFAULT_ASSETS_PATH})
	if assets_data, ok := os.read_entire_file(assets_src); ok {
		os.write_entire_file(assets_dst, assets_data)
		delete(assets_data)
		os.remove(assets_src)
	}

	icon_file_name := ""
	if icon_path != "" && os.exists(icon_path) {
		if strings.has_suffix(icon_path, ".icns") {
			icon_file_name = "app.icns"
			if icon_data, ok := os.read_entire_file(icon_path); ok {
				icns_path := filepath.join({resources_path, icon_file_name})
				os.write_entire_file(icns_path, icon_data)
				delete(icon_data)
			}
		} else if strings.has_suffix(icon_path, ".png") {
			icon_file_name = "app.png"
			if icon_data, ok := os.read_entire_file(icon_path); ok {
				png_path := filepath.join({resources_path, icon_file_name})
				os.write_entire_file(png_path, icon_data)
				delete(icon_data)
			}
		}
	}

	icon_plist_entry :=
		icon_file_name != "" ? fmt.tprintf(`
	<key>CFBundleIconFile</key>
	<string>{0}</string>`, icon_file_name) : ""
	defer if icon_plist_entry != "" do delete(icon_plist_entry)

	info_plist_content := fmt.aprintf(
		`<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>{0}</string>
	<key>CFBundleIdentifier</key>
	<string>dev.sucata.{0}</string>
	<key>CFBundleName</key>
	<string>{0}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.15</string>
	<key>NSHighResolutionCapable</key>
	<true/>{1}
</dict>
</plist>`,
		engine_name,
		icon_plist_entry,
	)
	defer delete(info_plist_content)

	info_plist_path := filepath.join({contents_path, "Info.plist"})
	os.write_entire_file(info_plist_path, transmute([]byte)info_plist_content)
}

embed_windows_icon :: proc(exe_path: string, icon_path: string) {
	if !os.exists(icon_path) {
		fmt.println("Warning: Icon file not found:", icon_path)
		return
	}

	if !strings.has_suffix(icon_path, ".ico") {
		fmt.println("Warning: Windows requires .ico format for icons")
		return
	}

	exe_dir := filepath.dir(exe_path)
	icon_output := filepath.join({exe_dir, "icon.ico"})
	if icon_data, ok := os.read_entire_file(icon_path); ok {
		os.write_entire_file(icon_output, icon_data)
		delete(icon_data)
		fmt.println("Icon copied to:", icon_output)
		fmt.println("Note: To embed icon in .exe, use ResourceHacker or similar tool")
	}
}

remove_console_window :: proc(exe_path: string) {
	data, read_ok := os.read_entire_file(exe_path)
	if !read_ok {
		fmt.println("Warning: Could not read executable to remove console")
		return
	}
	defer delete(data)

	if len(data) < 0x40 {
		return
	}

	pe_offset :=
		u32(data[0x3C]) | u32(data[0x3D]) << 8 | u32(data[0x3E]) << 16 | u32(data[0x3F]) << 24

	if pe_offset + 4 >= u32(len(data)) {
		return
	}
	if data[pe_offset] != 'P' || data[pe_offset + 1] != 'E' {
		return
	}

	machine_offset := pe_offset + 4
	opt_hdr_size_offset := pe_offset + 20
	optional_header_offset := pe_offset + 24
	subsystem_offset := optional_header_offset + 68

	if subsystem_offset + 2 >= u32(len(data)) {
		return
	}

	if data[subsystem_offset] == 3 {
		data[subsystem_offset] = 2
		os.write_entire_file(exe_path, data)
	}
}
