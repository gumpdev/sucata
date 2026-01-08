package mathns

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

NORMALIZE_FUNCTION :: lua_common.LuaFunction {
	name = "normalize",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "normalize") do return 0
		arg_count := lua.gettop(L)

		for i in 1 ..= arg_count {
			if !lua_common.validate_number(L, i32(i), "normalize") do return 0
		}

		sum_of_squares: lua.Number = 0
		for i in 1 ..= arg_count {
			value := lua.tonumber(L, i32(i))
			sum_of_squares += value * value
		}
		length := math.sqrt(f32(sum_of_squares))

		if length == 0 {
			for i in 1 ..= arg_count {
				lua.pushnumber(L, 0)
			}
			return c.int(arg_count)
		}

		for i in 1 ..= arg_count {
			value := f32(lua.tonumber(L, i32(i)))
			lua.pushnumber(L, lua.Number(value / length))
		}

		return c.int(arg_count)
	},
}
