package mathns

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

OVERLAPPING_FUNCTION :: lua_common.LuaFunction {
	name = "overlapping",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "overlapping expects 2 arguments (rect1, rect2)")
			lua.error(L)
			return 0
		}
		if !lua.istable(L, 1) || !lua.istable(L, 2) {
			lua.pushstring(L, "All arguments must be tables")
			lua.error(L)
			return 0
		}

		x1 := lua_common.get_table_number(L, 1, "x", 0)
		y1 := lua_common.get_table_number(L, 1, "y", 0)
		width1 := lua_common.get_table_number(L, 1, "width", 1)
		height1 := lua_common.get_table_number(L, 1, "height", 1)

		x2 := lua_common.get_table_number(L, 2, "x", 0)
		y2 := lua_common.get_table_number(L, 2, "y", 0)
		width2 := lua_common.get_table_number(L, 2, "width", 1)
		height2 := lua_common.get_table_number(L, 2, "height", 1)

		left1 := x1
		right1 := x1 + width1
		top1 := y1
		bottom1 := y1 + height1

		left2 := x2
		right2 := x2 + width2
		top2 := y2
		bottom2 := y2 + height2

		overlapping := !(right1 <= left2 || right2 <= left1 || bottom1 <= top2 || bottom2 <= top1)

		if !overlapping {
			lua.pushboolean(L, false)
			return 1
		}

		intersect_left := math.max(left1, left2)
		intersect_right := math.min(right1, right2)
		intersect_top := math.max(top1, top2)
		intersect_bottom := math.min(bottom1, bottom2)

		lua.pushboolean(L, true)
		lua.createtable(L, 0, 4)

		lua.pushnumber(L, lua.Number(intersect_left))
		lua.setfield(L, -2, "x")

		lua.pushnumber(L, lua.Number(intersect_top))
		lua.setfield(L, -2, "y")

		lua.pushnumber(L, lua.Number(intersect_right - intersect_left))
		lua.setfield(L, -2, "width")

		lua.pushnumber(L, lua.Number(intersect_bottom - intersect_top))
		lua.setfield(L, -2, "height")

		return 2
	},
}
