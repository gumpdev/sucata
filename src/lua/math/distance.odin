package mathns

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

DISTANCE_FUNCTION :: lua_common.LuaFunction {
	name = "distance",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "distance expects 2 arguments (table, table)")
			lua.error(L)
			return 0
		}
		if !lua.istable(L, 1) || !lua.istable(L, 2) {
			lua.pushstring(L, "Both arguments must be tables")
			lua.error(L)
			return 0
		}

		x1 := lua_common.get_table_number(L, 1, "x", 0.0)
		y1 := lua_common.get_table_number(L, 1, "y", 0.0)
		x2 := lua_common.get_table_number(L, 2, "x", 0.0)
		y2 := lua_common.get_table_number(L, 2, "y", 0.0)

		dist_x := x2 - x1
		dist_y := y2 - y1
		distance := math.sqrt((dist_x * dist_x) + (dist_y * dist_y))

		lua.pushnumber(L, lua.Number(distance))
		return 1
	},
}
