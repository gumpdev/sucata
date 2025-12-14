package mathns

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

SMOOTH_INDEX_FUNCTION :: lua_common.LuaFunction {
	name = "smooth_index",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 3 {
			lua.pushstring(L, "smooth_index expects 3 arguments (actual_time, time, max_time?)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) {
			lua.pushstring(L, "All arguments must be numbers")
			lua.error(L)
			return 0
		}

		a := f32(lua.tonumber(L, 1))
		b := f32(lua.tonumber(L, 2))
		c := math.floor(f32(lua.tonumber(L, 3)))

		v := math.floor(a / b)
		for v > c {
			v -= c
		}

		lua.pushnumber(L, lua.Number(v))
		return 1
	},
}
