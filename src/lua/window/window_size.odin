package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SET_WINDOW_SIZE_FUNCTION :: lua_common.LuaFunction {
	name = "set_window_size",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "set_window_size") do return 0
		if !lua_common.validate_number(L, 2, "set_window_size") do return 0
		if !lua_common.validate_number(L, 1, "set_window_size") do return 0

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
