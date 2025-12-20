package timenamespace

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

STOP_TIMER_FUNCTION :: lua_common.LuaFunction {
	name = "stop_timer",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "stop_timer expects at least 1 argument (timer_id)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		timer_id := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(timer_id)
		core.stop_timer(timer_id)

		return 0
	},
}
