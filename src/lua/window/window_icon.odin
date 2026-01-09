package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_WINDOW_ICON_FUNCTION :: lua_common.LuaFunction {
	name = "set_window_icon",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_window_icon") do return 0
		if !lua_common.validate_string(L, 1, "set_window_icon") do return 0

		icon_path := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(icon_path)

		core.set_window_icon(icon_path)

		return 0
	},
}

GET_WINDOW_ICON_FUNCTION :: lua_common.LuaFunction {
	name = "get_window_icon",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		icon_cstring := strings.clone_to_cstring(core.windowConfig.icon)
		defer delete(icon_cstring)

		lua.pushstring(L, icon_cstring)

		return 1
	},
}
