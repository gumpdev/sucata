package events

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

ON_FUNCTION :: lua_common.LuaFunction {
	name = "on",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 3 {
			lua.pushstring(L, "on expects 3 arguments (owner, event, function)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) && !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a string or table")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 2) {
			lua.pushstring(L, "Second argument must be a string")
			lua.error(L)
			return 0
		}

		if !lua.isfunction(L, 3) {
			lua.pushstring(L, "Third argument must be a function")
			lua.error(L)
			return 0
		}

		owner_id := lua_common.get_entity_id(L, 1)
		defer delete(owner_id)
		event := strings.clone_from_cstring(lua.tostring(L, 2))
		defer delete(event)
		func_ref := lua.L_ref(L, lua.REGISTRYINDEX)

		core.add_handler(owner_id, event, func_ref)

		return 0
	},
}
