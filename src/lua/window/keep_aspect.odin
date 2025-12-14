package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

SET_KEEP_ASPECT_FUNCTION :: lua_common.LuaFunction {
	name = "set_keep_aspect",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count == 0 {
			lua.pushstring(L, "set_keep_aspect expects at least 1 argument (number)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) {
			lua.pushstring(L, "First argument must be a number")
			lua.error(L)
			return 0
		}

		core.windowConfig.keep_aspect = i32(lua.tonumber(L, 1))

		return 0
	},
}

GET_KEEP_ASPECT_FUNCTION :: lua_common.LuaFunction {
	name = "get_keep_aspect",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushboolean(L, b32(core.windowConfig.keep_aspect))

		return 1
	},
}
