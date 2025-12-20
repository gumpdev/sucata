package scene

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

SPAWNS_FUNCTION :: lua_common.LuaFunction {
	name = "spawns",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "spawns expects at least 1 arguments (array of entitys)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a table")
			lua.error(L)
			return 0
		}

		lua.len(L, 1)
		table_length := lua.tointeger(L, -1)
		lua.pop(L, 1)

		lua.newtable(L)
		spawned_ids_table := lua.gettop(L)

		for i in 1 ..= table_length {
			lua.rawgeti(L, 1, lua.Integer(i))
			if lua.istable(L, -1) {
				entity := lua_common.create_entity_by_lua(L, lua.gettop(L))
				spawned_id := core.spawn(entity)

				if spawned_id != "" {
					entity_id_c := strings.clone_to_cstring(spawned_id)
					defer delete(entity_id_c)
					lua.pushstring(L, entity_id_c)
					lua.rawseti(L, spawned_ids_table, lua.Integer(i))
				}
			}
			lua.pop(L, 1)
		}

		return 1
	},
}
