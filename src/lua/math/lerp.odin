package mathns

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

LERP_FUNCTION :: lua_common.LuaFunction {
	name = "lerp",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 3, "lerp") do return 0
		if !lua_common.validate_number(L, 1, "lerp") do return 0
		if !lua_common.validate_number(L, 2, "lerp") do return 0
		if !lua_common.validate_number(L, 3, "lerp") do return 0

		a := lua.tonumber(L, 1)
		b := lua.tonumber(L, 2)
		t := lua.tonumber(L, 3)

		lua.pushnumber(L, lua.Number(math.lerp(a, b, t)))
		return 1
	},
}
