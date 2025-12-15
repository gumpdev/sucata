package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_WINDOW_TITLE_FUNCTION :: lua_common.LuaFunction {
	name = "set_window_title",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count < 1 {
			lua.pushstring(L, "set_window_title expects at least 1 argument (title)")
			lua.error(L)
			return 0
		}
		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		core.set_window_title(string(lua.tostring(L, 1)))

		return 0
	},
}

GET_WINDOW_TITLE_FUNCTION :: lua_common.LuaFunction {
	name = "get_window_title",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		title_cstring := strings.clone_to_cstring(core.windowConfig.title)
		defer delete(title_cstring)

		lua.pushstring(L, title_cstring)

		return 1
	},
}
