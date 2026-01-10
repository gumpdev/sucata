package gamepad

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

GET_COUNT_FUNCTION :: lua_common.LuaFunction {
	name = "get_count",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		count := core.get_gamepad_count()
		lua.pushnumber(L, lua.Number(count))

		return 1
	},
}
