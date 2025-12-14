package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

SET_VSYNC_FUNCTION :: lua_common.LuaFunction {
	name = "set_vsync",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count == 0 {
			lua.pushstring(L, "set_vsync expects at least 1 argument (number)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) {
			lua.pushstring(L, "First argument must be a number")
			lua.error(L)
			return 0
		}

		core.set_window_vsync(i32(lua.tointeger(L, 1)))

		return 0
	},
}

GET_VSYNC_FUNCTION :: lua_common.LuaFunction {
	name = "get_vsync",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushnumber(L, lua.Number(core.windowConfig.vsync))

		return 1
	},
}
