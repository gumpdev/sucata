package mathns

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

CLAMP_FUNCTION :: lua_common.LuaFunction {
	name = "clamp",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 3, "clamp") do return 0
		if !lua_common.validate_table(L, 1, "clamp") do return 0
		if !lua_common.validate_table(L, 2, "clamp") do return 0
		if !lua_common.validate_table(L, 3, "clamp") do return 0

		value := lua.tonumber(L, 1)
		min := lua.tonumber(L, 2)
		max := lua.tonumber(L, 3)

		lua.pushnumber(L, lua.Number(math.clamp(value, min, max)))
		return 1
	},
}
