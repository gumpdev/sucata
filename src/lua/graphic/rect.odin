package graphic

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

RECT_FUNCTION :: lua_common.LuaFunction {
	name = "draw_rect",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "rect expects at least 1 argument (table)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a table")
			lua.error(L)
			return 0
		}

		x := f32(lua_common.get_table_number(L, 1, "x", 0.0))
		y := f32(lua_common.get_table_number(L, 1, "y", 0.0))
		width := f32(lua_common.get_table_number(L, 1, "width", 50.0))
		height := f32(lua_common.get_table_number(L, 1, "height", 50.0))
		color := lua_common.get_table_string(L, 1, "color", "#ffffff")
		zIndex := lua_common.get_table_number(L, 1, "z_index", 0)
		texture_path := lua_common.get_table_string(L, 1, "texture", "")
		scale := f32(lua_common.get_table_number(L, 1, "scale", 1.0))
		scale_x := f32(lua_common.get_table_number(L, 1, "scale_x", 1.0))
		scale_y := f32(lua_common.get_table_number(L, 1, "scale_y", 1.0))
		origin := f32(lua_common.get_table_number(L, 1, "origin", 0.0))
		origin_x := f32(lua_common.get_table_number(L, 1, "origin_x", 0.0))
		origin_y := f32(lua_common.get_table_number(L, 1, "origin_y", 0.0))
		rotation := f32(lua_common.get_table_number(L, 1, "rotation", 0.0))
		fixed := lua_common.get_table_boolean(L, 1, "fixed", false)

		atlas_width := f32(lua_common.get_table_number(L, 1, "atlas_width", 0.0))
		atlas_height := f32(lua_common.get_table_number(L, 1, "atlas_height", 0.0))
		atlas_size := f32(lua_common.get_table_number(L, 1, "atlas_size", 0.0))
		atlas_spacing := f32(lua_common.get_table_number(L, 1, "atlas_spacing", 0.0))
		atlas_margin := f32(lua_common.get_table_number(L, 1, "atlas_margin", 0.0))
		atlas_x := f32(lua_common.get_table_number(L, 1, "atlas_x", 0.0))
		atlas_y := f32(lua_common.get_table_number(L, 1, "atlas_y", 0.0))

		if scale != 1.0 && (scale_x == 1.0 && scale_y == 1.0) {
			scale_x = scale
			scale_y = scale
		}

		if origin != 0.0 && (origin_x == 0.0 && origin_y == 0.0) {
			origin_x = origin
			origin_y = origin
		}

		if atlas_size != 0.0 && (atlas_width == 0.0 && atlas_height == 0.0) {
			atlas_width = atlas_size
			atlas_height = atlas_size
		}

		props := common.QuadObjectProps {
			position = [2]f32{x, y},
			size = [2]f32{width, height},
			color = hex_to_rgba(color),
			zIndex = i32(zIndex),
			texture = texture_path,
			scale = [2]f32{scale_x, scale_y},
			origin = [2]f32{origin_x, origin_y},
			rotation = rotation,
			atlas = common.AtlasProps {
				width = atlas_width,
				height = atlas_height,
				spacing = atlas_spacing,
				margin = atlas_margin,
				x = atlas_x,
				y = atlas_y,
			},
			fixed = fixed,
		}

		core.add_to_render_queue(props)

		return 0
	},
}
