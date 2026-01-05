package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SET_KEEP_ASPECT_FUNCTION :: lua_common.LuaFunction {
	name = "set_keep_aspect",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_keep_aspect") do return 0
		if !lua_common.validate_number(L, 1, "set_keep_aspect") do return 0

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
