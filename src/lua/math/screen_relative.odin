package mathns

import core "../../core"
import graphics "../../graphics"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

SCREEN_RELATIVE_FUNCTION :: lua_common.LuaFunction {
	name = "screen_relative",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "screen_relative expects 1 arguments (rect)")
			lua.error(L)
			return 0
		}
		if !lua.istable(L, 1) {
			lua.pushstring(L, "Argument must be a table")
			lua.error(L)
			return 0
		}

		top := lua_common.get_table_number(L, 1, "top", 0)
		left := lua_common.get_table_number(L, 1, "left", 0)
		right := lua_common.get_table_number(L, 1, "right", 0)
		bottom := lua_common.get_table_number(L, 1, "bottom", 0)

		x, y, width, height := graphics.screen_relative(left, top, right, bottom)

		lua.pushnumber(L, lua.Number(x))
		lua.pushnumber(L, lua.Number(y))
		lua.pushnumber(L, lua.Number(width))
		lua.pushnumber(L, lua.Number(height))

		return 4
	},
}
