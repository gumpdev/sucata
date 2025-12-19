package graphics

import sg "../../sokol/gfx"
import "../fs"
import "../path"
import "core:fmt"
import "core:os"
import "core:strings"
import stbt "vendor:stb/truetype"

Font :: struct {
	bitmap:        [^]byte,
	char_data:     []stbt.bakedchar,
	image:         sg.View,
	bitmap_width:  i32,
	bitmap_height: i32,
}

get_default_system_font :: proc() -> string {
	when ODIN_OS == .Windows {
		return "C:/Windows/Fonts/arial.ttf"
	} else when ODIN_OS == .Darwin {
		macos_fonts := []string {
			"/System/Library/Fonts/Supplemental/Arial.ttf",
			"/System/Library/Fonts/Supplemental/Courier New.ttf",
			"/System/Library/Fonts/Supplemental/Times New Roman.ttf",
			"/Library/Fonts/Arial.ttf",
			"/System/Library/Fonts/Helvetica.ttc",
		}
		for font_path in macos_fonts {
			if os.exists(font_path) {
				return font_path
			}
		}
		return "/System/Library/Fonts/Supplemental/Arial.ttf"
	} else when ODIN_OS == .Linux {
		linux_fonts := []string {
			"/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
			"/usr/share/fonts/TTF/DejaVuSans.ttf",
			"/usr/share/fonts/liberation/LiberationSans-Regular.ttf",
		}
		for font_path in linux_fonts {
			if os.exists(font_path) {
				return font_path
			}
		}
		return "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
	} else {
		return ""
	}
}

loaded_fonts := map[string]^Font{}

load_font :: proc(file_path: string, font_size: f32) -> ^Font {
	font_path := file_path
	if font_path == "" {
		font_path = get_default_system_font()
	}
	font_name := fmt.aprintf("%s_%f", font_path, font_size, allocator = context.allocator)

	if font, exists := loaded_fonts[font_name]; exists {
		delete(font_name)
		return loaded_fonts[font_name]
	}

	ttf_data: []byte
	read_ok: bool

	if asset_data, ok := fs.get_asset(font_path); ok && len(asset_data) > 0 {
		ttf_data = make([]byte, len(asset_data))
		copy(ttf_data, asset_data)
		read_ok = true
	} else {
		ttf_data, read_ok = os.read_entire_file(path.get_path(font_path))
	}

	if !read_ok {
		return nil
	}
	defer delete(ttf_data)

	font_info: stbt.fontinfo
	if !stbt.InitFont(&font_info, raw_data(ttf_data), 0) {
		return nil
	}

	bitmap_width: i32 = 512
	bitmap_height: i32 = 512
	bitmap := make([^]byte, bitmap_width * bitmap_height)

	char_data := make([]stbt.bakedchar, 96)
	result := stbt.BakeFontBitmap(
		raw_data(ttf_data),
		0,
		font_size,
		bitmap,
		bitmap_width,
		bitmap_height,
		32,
		96,
		raw_data(char_data),
	)

	if result <= 0 {
		free(bitmap)
		delete(char_data)
		return nil
	}

	image := sg.make_image(
		sg.Image_Desc {
			width = bitmap_width,
			height = bitmap_height,
			pixel_format = .R8,
			data = {mip_levels = {0 = {ptr = bitmap, size = uint(bitmap_width * bitmap_height)}}},
		},
	)

	path_cstr := strings.clone_to_cstring(font_name)
	defer delete_cstring(path_cstr)

	view := sg.make_view({texture = {image = image}, label = path_cstr})

	font := new(Font)
	font.bitmap = bitmap
	font.char_data = char_data
	font.bitmap_width = bitmap_width
	font.bitmap_height = bitmap_height
	font.image = view

	loaded_fonts[font_name] = font

	return font
}

unload_fonts :: proc() {
	for font_name, font in loaded_fonts {
		sg.destroy_image(sg.query_view_image(font.image))
		sg.destroy_view(font.image)
		free(font.bitmap)
		delete(font.char_data)
		free(font)
		delete(font_name)
	}
	delete(loaded_fonts)
	loaded_fonts = {}
}

unload_font :: proc(font_name: string) {
	if font, exists := loaded_fonts[font_name]; exists {
		sg.destroy_image(sg.query_view_image(font.image))
		sg.destroy_view(font.image)
		free(font.bitmap)
		delete(font.char_data)
		free(font)
		for key in loaded_fonts {
			if key == font_name {
				delete(key)
				break
			}
		}
		delete_key(&loaded_fonts, font_name)
	}
}
