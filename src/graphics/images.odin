package graphics

import "../fs"
import "../path"
import "core:image"
import "core:strings"
import sg "shared:sokol/gfx"
import stbi "vendor:stb/image"

DEFAULT_IMAGE_KEY :: "__default__"

Image :: struct {
	width:  i32,
	height: i32,
	view:   sg.View,
}

images_loaded: map[string]Image = map[string]Image{}
images_used: map[string]bool = map[string]bool{}

load_default_image :: proc() {
	white_pixel: [4]u8 = {255, 255, 255, 255}
	default_image := sg.make_image(
		{
			width = 1,
			height = 1,
			pixel_format = .RGBA8,
			data = {mip_levels = {0 = {ptr = &white_pixel[0], size = 4}}},
		},
	)
	images_loaded[DEFAULT_IMAGE_KEY] = Image {
		width  = 1,
		height = 1,
		view   = sg.make_view({texture = {image = default_image}}),
	}
}

load_image :: proc(file_path: string) -> Image {
	if value, ok := images_loaded[file_path]; ok {
		images_used[file_path] = true
		return value
	}

	w, h: i32
	pixels: [^]u8

	if asset_data, ok := fs.get_asset(file_path); ok && len(asset_data) > 0 {
		pixels = stbi.load_from_memory(&asset_data[0], i32(len(asset_data)), &w, &h, nil, 4)
	} else {
		path_cstr := strings.clone_to_cstring(path.get_path(file_path))
		defer delete_cstring(path_cstr)
		pixels = stbi.load(path_cstr, &w, &h, nil, 4)
	}

	if pixels == nil {
		return images_loaded[DEFAULT_IMAGE_KEY]
	}

	image := sg.make_image(
		{
			width = w,
			height = h,
			pixel_format = .DEFAULT,
			data = {mip_levels = {0 = {ptr = pixels, size = uint(w * h * 4)}}},
		},
	)

	stbi.image_free(pixels)

	path_cstr := strings.clone_to_cstring(file_path, context.temp_allocator)
	defer delete_cstring(path_cstr, context.temp_allocator)
	view := sg.make_view({texture = {image = image}, label = path_cstr})
	images_loaded[file_path] = Image {
		width  = w,
		height = h,
		view   = view,
	}
	images_used[file_path] = true
	return images_loaded[file_path]
}

destroy_images :: proc() {
	for file_path, view in images_loaded {
		destroy_image(file_path)
	}
}

destroy_image :: proc(file_path: string) {
	if value, ok := images_loaded[file_path]; ok {
		sg.destroy_image(sg.query_view_image(value.view))
		sg.destroy_view(value.view)
		delete_key(&images_loaded, file_path)
		delete_key(&images_used, file_path)
	}
}

destroy_unused_images :: proc() {
	for file_path, used in images_used {
		if !used && file_path != DEFAULT_IMAGE_KEY {
			destroy_image(file_path)
		} else {
			images_used[file_path] = false
		}
	}
}
