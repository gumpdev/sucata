package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SHOW_DEBUG_INFO_FUNCTION :: lua_common.LuaFunction {
	name = "show_debug_info",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count == 0 {
			lua.pushstring(L, "show_debug_info expects at least 1 argument (boolean)")
			lua.error(L)
			return 0
		}

		show := lua.toboolean(L, 1)
		core.windowConfig.draw_debug_info = bool(show)

		return 0
	},
}
