package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_WINDOW_SIZE_FUNCTION :: lua_common.LuaFunction {
	name = "set_window_size",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count < 2 {
			lua.pushstring(L, "set_window_size expects at least 2 argument (x,y)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) {
			lua.pushstring(L, "Both arguments must be numbers")
			lua.error(L)
			return 0
		}

		core.set_window_size(i32(lua.tointeger(L, 1)), i32(lua.tointeger(L, 2)))

		return 0
	},
}

GET_WINDOW_SIZE_FUNCTION :: lua_common.LuaFunction {
	name = "get_window_size",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushinteger(L, lua.Integer(core.windowConfig.width))
		lua.pushinteger(L, lua.Integer(core.windowConfig.height))

		return 2
	},
}
