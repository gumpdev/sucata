package events

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

EMIT_FUNCTION :: lua_common.LuaFunction {
	name = "emit",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "emit expects 2 arguments (event, data)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 2) {
			lua.pushstring(L, "Second argument must be a table")
			lua.error(L)
			return 0
		}

		event := string(lua.tostring(L, 1))
		data_ref := lua.L_ref(L, lua.REGISTRYINDEX)

		core.emit_event(event, data_ref)

		return 0
	},
}
