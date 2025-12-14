package timenamespace

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

GET_TIME_SCALE_FUNCTION :: lua_common.LuaFunction {
	name = "get_time_scale",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushnumber(L, lua.Number(core.time_scale))

		return 1
	},
}

SET_TIME_SCALE_FUNCTION :: lua_common.LuaFunction {
	name = "set_time_scale",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "set_time_scale expects 1 argument (number)")
			lua.error(L)
			return 0
		}

		core.time_scale = f64(lua.tonumber(L, 1))

		return 0
	},
}
