package timenamespace

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

CREATE_TIMER_FUNCTION :: lua_common.LuaFunction {
	name = "create_timer",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "create_timer") do return 0
		if !lua_common.validate_function(L, 1, "create_timer") do return 0

		lua.pushvalue(L, 1)
		callback_ref: i32 = lua.L_ref(L, lua.REGISTRYINDEX)

		time: f64 = 1.0
		auto_start: bool = true
		one_shot: bool = true
		repeat: bool = false

		if lua.isnumber(L, 2) {
			time = f64(lua.tonumber(L, 2))
		} else if lua.istable(L, 2) {
			time = lua_common.get_table_number(L, 2, "time", 1.0)
			auto_start = lua_common.get_table_boolean(L, 2, "auto_start", true)
			one_shot = lua_common.get_table_boolean(L, 2, "one_shot", true)
			repeat = lua_common.get_table_boolean(L, 2, "loop", false)
		} else {
			lua.pushstring(L, "Second argument must be a table or a number")
			lua.error(L)
			return 0
		}

		timer_id := core.create_timer(callback_ref, time, auto_start, one_shot, repeat)
		lua.pushnumber(L, lua.Number(timer_id))

		return 1
	},
}
