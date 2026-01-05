package mathns

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

SMOOTH_INDEX_FUNCTION :: lua_common.LuaFunction {
	name = "smooth_index",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 3, "smooth_index") do return 0
		if !lua_common.validate_number(L, 1, "smooth_index") do return 0
		if !lua_common.validate_number(L, 2, "smooth_index") do return 0
		if !lua_common.validate_number(L, 3, "smooth_index") do return 0

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
