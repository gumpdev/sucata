package graphic

import sg "../../../sokol/gfx"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_BACKGROUND_FUNCTION :: lua_common.LuaFunction {
	name = "set_background_color",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_background_color") do return 0
		if !lua_common.validate_string(L, 1, "set_background_color") do return 0

		color_str := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(color_str)
		color := hex_to_rgba(color_str)

		core.clear_color = sg.Color {
			r = color[0],
			g = color[1],
			b = color[2],
			a = color[3],
		}

		return 0
	},
}
