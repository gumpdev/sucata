package mathns

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

LERP_FUNCTION :: lua_common.LuaFunction {
	name = "lerp",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 3 {
			lua.pushstring(L, "lerp expects 3 arguments (a, b, time)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) || !lua.isnumber(L, 3) {
			lua.pushstring(L, "All arguments must be numbers")
			lua.error(L)
			return 0
		}

		a := lua.tonumber(L, 1)
		b := lua.tonumber(L, 2)
		t := lua.tonumber(L, 3)

		lua.pushnumber(L, lua.Number(math.lerp(a, b, t)))
		return 1
	},
}
