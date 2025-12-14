package scene

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

FIND_BY_ID_FUNCTION :: lua_common.LuaFunction {
	name = "find_by_id",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "find_by_id expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		entity_id := string(lua.tostring(L, 1))
		entity := core.find_by_id(entity_id)

		if entity == nil {
			lua.pushnil(L)
		} else {
			lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(entity.table))
		}

		return 1
	},
}
