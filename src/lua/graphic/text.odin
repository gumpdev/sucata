package graphic

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

TEXT_FUNCTION :: lua_common.LuaFunction {
	name = "draw_text",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "text expects at least 1 argument (table)")
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
		font_size := f32(lua_common.get_table_number(L, 1, "size", 16.0))
		color := lua_common.get_table_string(L, 1, "color", "#ffffff")
		zIndex := lua_common.get_table_number(L, 1, "z_index", 0)
		text := lua_common.get_table_string(L, 1, "text", "")
		font := lua_common.get_table_string(L, 1, "font", "")
		scale := f32(lua_common.get_table_number(L, 1, "scale", 1.0))
		scale_x := f32(lua_common.get_table_number(L, 1, "scale_x", 1.0))
		scale_y := f32(lua_common.get_table_number(L, 1, "scale_y", 1.0))
		origin := f32(lua_common.get_table_number(L, 1, "origin", 0.0))
		origin_x := f32(lua_common.get_table_number(L, 1, "origin_x", 0.0))
		origin_y := f32(lua_common.get_table_number(L, 1, "origin_y", 0.0))
		rotation := f32(lua_common.get_table_number(L, 1, "rotation", 0.0))
		fixed := lua_common.get_table_boolean(L, 1, "fixed", false)
		align := lua_common.get_table_string(L, 1, "align", "left")
		max_width := f32(lua_common.get_table_number(L, 1, "max_width", 0.0))

		if scale != 1.0 && (scale_x == 1.0 && scale_y == 1.0) {
			scale_x = scale
			scale_y = scale
		}

		if origin != 0.0 && (origin_x == 0.0 && origin_y == 0.0) {
			origin_x = origin
			origin_y = origin
		}

		text_align := common.TextAlign.Left
		switch align {
		case "center":
			text_align = .Center
		case "right":
			text_align = .Right
		case "left":
			text_align = .Left
		}

		props := common.TextObjectProps {
			position = [2]f32{x, y},
			color    = hex_to_rgba(color),
			zIndex   = i32(zIndex),
			font     = font,
			size     = font_size,
			scale    = [2]f32{scale_x, scale_y},
			origin   = [2]f32{origin_x, origin_y},
			rotation = rotation,
			text     = text,
			fixed    = fixed,
			align    = text_align,
			maxWidth = max_width,
		}

		core.add_to_render_queue(props)

		return 0
	},
}
