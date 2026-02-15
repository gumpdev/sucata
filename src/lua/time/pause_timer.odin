package timenamespace

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

PAUSE_TIMER_FUNCTION :: lua_common.LuaFunction {
	name = "pause_timer",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "pause_timer") do return 0
		if !lua_common.validate_number(L, 1, "pause_timer") do return 0

		timer_id := u64(lua.tonumber(L, 1))
		core.pause_timer(timer_id)

		return 0
	},
}
