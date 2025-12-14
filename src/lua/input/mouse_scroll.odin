package input

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

GET_MOUSE_SCROLL_FUNCTION :: lua_common.LuaFunction {
	name = "get_mouse_scroll",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		x, y := core.mouse_scroll()

		lua.pushnumber(L, lua.Number(x))
		lua.pushnumber(L, lua.Number(y))

		return 2
	},
}
