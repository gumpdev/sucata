package scene

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SPAWN_FUNCTION :: lua_common.LuaFunction {
	name = "spawn",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "spawn expects at least 1 arguments (entity)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a table")
			lua.error(L)
			return 0
		}

		entity := lua_common.create_entity_by_lua(L, 1)
		core.spawn(entity)

		entity_id := strings.clone_to_cstring(entity.id)
		defer delete(entity_id)
		lua.pushstring(L, entity_id)

		return 1
	},
}
