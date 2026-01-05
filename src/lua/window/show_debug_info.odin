package window

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

SHOW_DEBUG_INFO_FUNCTION :: lua_common.LuaFunction {
	name = "show_debug_info",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "show_debug_info") do return 0
		if !lua_common.validate_boolean(L, 1, "show_debug_info") do return 0

		show := lua.toboolean(L, 1)
		core.windowConfig.draw_debug_info = bool(show)

		return 0
	},
}
