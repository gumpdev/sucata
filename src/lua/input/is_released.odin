package input

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

IS_RELEASED_FUNCTION :: lua_common.LuaFunction {
	name = "is_released",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "is_released") do return 0

		arg_count := lua.gettop(L)
		for i in 1 ..= arg_count {
			if !lua.isstring(L, c.int(i)) {
				lua.pushstring(L, "is_released expects all arguments to be strings")
				lua.error(L)
				return 0
			}

			key_name := string(lua.tostring(L, c.int(i)))

			if core.is_released(key_name) {
				lua.pushboolean(L, true)
				return 1
			}
		}

		lua.pushboolean(L, false)
		return 1
	},
}
