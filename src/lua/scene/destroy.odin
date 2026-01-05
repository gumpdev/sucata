package scene

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

DESTROY_FUNCTION :: lua_common.LuaFunction {
	name = "destroy",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "destroy") do return 0
		if !lua_common.validate_table_or_string(L, 1, "destroy") do return 0

		entity_id := lua_common.get_entity_id(L, 1)
		defer delete(entity_id)
		entity := core.find_by_id(entity_id)

		if entity != nil {
			core.add_to_destroy_queue(entity)
			lua.pushboolean(L, true)
		} else {
			lua.pushboolean(L, false)
		}

		return 1
	},
}
