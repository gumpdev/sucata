package input

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

IS_PRESSED_FUNCTION :: lua_common.LuaFunction {
	name = "is_pressed",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count == 0 {
			lua.pushstring(L, "is_pressed expects at least 1 argument (key/button name)")
			lua.error(L)
			return 0
		}

		for i in 1 ..= arg_count {
			if !lua.isstring(L, c.int(i)) {
				lua.pushstring(L, "All arguments must be strings")
				lua.error(L)
				return 0
			}

			key_name := strings.clone_from_cstring(lua.tostring(L, c.int(i)))
			defer delete(key_name)

			if core.is_pressed(key_name) {
				lua.pushboolean(L, true)
				return 1
			}
		}

		lua.pushboolean(L, false)
		return 1
	},
}
