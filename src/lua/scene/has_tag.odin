package scene

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

HAS_TAG_FUNCTION :: lua_common.LuaFunction {
	name = "has_tag",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "has_tag expects 2 arguments (entity or id, tag)")
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

		entity_id := lua_common.get_entity_id(L, 1)
		tag := string(lua.tostring(L, 2))
		entity := core.find_by_id(entity_id)

		if entity == nil {
			lua.pushboolean(L, false)
		} else {
			lua.pushboolean(L, b32(core.has_tag(entity_id, tag)))
		}

		return 1
	},
}
