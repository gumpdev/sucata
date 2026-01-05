package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SET_FULLSCREEN_FUNCTION :: lua_common.LuaFunction {
	name = "set_fullscreen",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_fullscreen") do return 0
		if !lua_common.validate_boolean(L, 1, "set_fullscreen") do return 0

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
