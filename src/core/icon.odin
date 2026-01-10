package core

import sapp "../../sokol/app"
import common "../common"
import "../fs"
import "../path"
import "core:fmt"
import "core:strings"
import stbi "vendor:stb/image"

load_window_icon :: proc(icon_path: string) -> sapp.Icon_Desc {
	icon_desc := sapp.Icon_Desc{}

	if icon_path == "" {
		icon_desc.sokol_default = true
		return icon_desc
	}

	w, h: i32
	pixels: [^]u8

	if asset_data, ok := fs.get_asset(icon_path); ok && len(asset_data) > 0 {
		pixels = stbi.load_from_memory(raw_data(asset_data), i32(len(asset_data)), &w, &h, nil, 4)
	} else {
		path_cstr := strings.clone_to_cstring(path.get_path(icon_path))
		defer delete_cstring(path_cstr)
		pixels = stbi.load(path_cstr, &w, &h, nil, 4)
	}

	if pixels == nil {
		fmt.printfln("Falha ao carregar ícone: %s, usando padrão", icon_path)
		icon_desc.sokol_default = true
		return icon_desc
	}

	pixel_count := w * h * 4
	icon_desc.images[0] = sapp.Image_Desc {
		width = w,
		height = h,
		pixels = {ptr = pixels, size = uint(pixel_count)},
	}

	return icon_desc
}

free_icon_desc :: proc(icon_desc: ^sapp.Icon_Desc) {
	if icon_desc.sokol_default {
		return
	}

	for i := 0; i < 8; i += 1 {
		if icon_desc.images[i].pixels.ptr != nil {
			stbi.image_free(icon_desc.images[i].pixels.ptr)
		}
	}
}

set_window_icon :: proc(icon_path: string) {
	if windowConfig.icon != "" {
		delete(windowConfig.icon)
	}
	windowConfig.icon = strings.clone(icon_path)

	if !sapp.isvalid() {
		return
	}

	icon_desc := sapp.Icon_Desc{}

	if icon_path == "" {
		sapp.set_icon(icon_desc)
		return
	}

	w, h: i32
	pixels: [^]u8

	if asset_data, ok := fs.get_asset(icon_path); ok && len(asset_data) > 0 {
		pixels = stbi.load_from_memory(raw_data(asset_data), i32(len(asset_data)), &w, &h, nil, 4)
	} else {
		path_cstr := strings.clone_to_cstring(path.get_path(icon_path))
		defer delete_cstring(path_cstr)
		pixels = stbi.load(path_cstr, &w, &h, nil, 4)
	}

	if pixels == nil {
		fmt.printfln("Failed to load the icon: %s", icon_path)
		return
	}

	pixel_count := w * h * 4
	icon_desc.images[0] = sapp.Image_Desc {
		width = w,
		height = h,
		pixels = {ptr = pixels, size = uint(pixel_count)},
	}

	sapp.set_icon(icon_desc)

	stbi.image_free(pixels)
}
