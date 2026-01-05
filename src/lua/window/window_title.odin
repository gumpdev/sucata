package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_WINDOW_TITLE_FUNCTION :: lua_common.LuaFunction {
	name = "set_window_title",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_window_title") do return 0
		if !lua_common.validate_string(L, 1, "set_window_title") do return 0

		title := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(title)

		core.set_window_title(title)

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
