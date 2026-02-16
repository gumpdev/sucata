package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SET_CURSOR_FUNCTION :: lua_common.LuaFunction {
	name = "set_cursor",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "set_cursor") do return 0
		if !lua_common.validate_string(L, 1, "set_cursor") do return 0

		cursor_str := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(cursor_str)

		core.set_cursor(cursor_str)

		return 0
	},
}

GET_CURSOR_FUNCTION :: lua_common.LuaFunction {
	name = "get_cursor",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		str_cursor := strings.clone_to_cstring(core.get_cursor())
		defer delete(str_cursor)

		lua.pushstring(L, str_cursor)

		return 1
	},
}
