package mathns

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:math"
import lua "vendor:lua/5.4"

MOVE_TOWARDS_FUNCTION :: lua_common.LuaFunction {
	name = "move_towards",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 3, "move_towards") do return 0

		if !lua_common.validate_number(L, 1, "move_towards") do return 0
		if !lua_common.validate_number(L, 2, "move_towards") do return 0
		if !lua_common.validate_number(L, 3, "move_towards") do return 0

		x := f32(lua.tonumber(L, 1))
		target := f32(lua.tonumber(L, 2))
		step := f32(lua.tonumber(L, 3))

		difference := target - x

		result: f32
		if math.abs(difference) <= step {
			result = target
		} else if difference > 0 {
			result = math.min(x + step, target)
		} else {
			result = math.max(x - step, target)
		}

		lua.pushnumber(L, lua.Number(result))
		return 1
	},
}
