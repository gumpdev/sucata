package graphic

import sg "../../../sokol/gfx"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SET_BACKGROUND_FUNCTION :: lua_common.LuaFunction {
	name = "set_background_color",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "set_background_color expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		color_str := string(lua.tostring(L, 1))
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
