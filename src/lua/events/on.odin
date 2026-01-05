package events

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

ON_FUNCTION :: lua_common.LuaFunction {
	name = "on",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 3, "on") do return 0
		if !lua_common.validate_table_or_string(L, 1, "on") do return 0
		if !lua_common.validate_string(L, 2, "on") do return 0
		if !lua_common.validate_function(L, 3, "on") do return 0

		owner_id := lua_common.get_entity_id(L, 1)
		defer delete(owner_id)
		event := strings.clone_from_cstring(lua.tostring(L, 2))
		defer delete(event)
		func_ref := lua.L_ref(L, lua.REGISTRYINDEX)

		core.add_handler(owner_id, event, func_ref)

		return 0
	},
}
