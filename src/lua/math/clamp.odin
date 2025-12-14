package mathns

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

CLAMP_FUNCTION :: lua_common.LuaFunction {
	name = "clamp",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 3 {
			lua.pushstring(L, "clamp expects 3 arguments (value, min, max)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) || !lua.isnumber(L, 3) {
			lua.pushstring(L, "All arguments must be numbers")
			lua.error(L)
			return 0
		}

		value := lua.tonumber(L, 1)
		min := lua.tonumber(L, 2)
		max := lua.tonumber(L, 3)

		lua.pushnumber(L, lua.Number(math.clamp(value, min, max)))
		return 1
	},
}
