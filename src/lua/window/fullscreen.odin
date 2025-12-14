package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

SET_FULLSCREEN_FUNCTION :: lua_common.LuaFunction {
	name = "set_fullscreen",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count == 0 {
			lua.pushstring(L, "set_fullscreen expects at least 1 argument (true/false)")
			lua.error(L)
			return 0
		}
		if !lua.isboolean(L, 1) {
			lua.pushstring(L, "First argument must be a boolean")
			lua.error(L)
			return 0
		}

		core.set_window_fullscreen(lua.toboolean(L, 1))

		return 0
	},
}

GET_FULLSCREEN_FUNCTION :: lua_common.LuaFunction {
	name = "get_fullscreen",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushboolean(L, b32(core.windowConfig.fullscreen))

		return 1
	},
}
