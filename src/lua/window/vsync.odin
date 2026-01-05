package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SET_VSYNC_FUNCTION :: lua_common.LuaFunction {
	name = "set_vsync",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_vsync") do return 0
		if !lua_common.validate_number(L, 1, "set_vsync") do return 0

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
