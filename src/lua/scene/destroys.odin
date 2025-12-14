package scene

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

DESTROYS_FUNCTION :: lua_common.LuaFunction {
	name = "destroys",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "destroy expects at least 1 argument (array)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a array")
			lua.error(L)
			return 0
		}

		lua.len(L, 1)
		table_length := lua.tointeger(L, -1)
		lua.pop(L, 1)

		lua.newtable(L)
		undestroyed_ids_table := lua.gettop(L)

		for i in 1 ..= table_length {
			lua.rawgeti(L, 1, lua.Integer(i))
			if lua.istable(L, -1) {
				entity_id := lua_common.get_entity_id(L, lua.gettop(L))
				entity := core.find_by_id(entity_id)

				if entity != nil {
					core.add_to_destroy_queue(entity)
				} else {
					entity_id_c := strings.clone_to_cstring(entity_id)
					defer delete(entity_id_c)
					lua.pushstring(L, entity_id_c)
					lua.rawseti(L, undestroyed_ids_table, lua.Integer(i))
				}
			}
			lua.pop(L, 1)
		}
		return 1
	},
}
