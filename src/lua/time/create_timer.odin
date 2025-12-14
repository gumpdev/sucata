package timenamespace

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

CREATE_TIMER_FUNCTION :: lua_common.LuaFunction {
	name = "create_timer",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(
				L,
				"create_timer expects at least 2 arguments (function, table or number)",
			)
			lua.error(L)
			return 0
		}

		if !lua.isfunction(L, 1) {
			lua.pushstring(L, "First argument must be a function")
			lua.error(L)
			return 0
		}

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
		timer_id_cstring := strings.clone_to_cstring(timer_id)
		lua.pushstring(L, timer_id_cstring)
		delete(timer_id_cstring)

		return 1
	},
}
