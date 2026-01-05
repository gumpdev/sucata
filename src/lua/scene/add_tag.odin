package scene

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

ADD_TAG_FUNCTION :: lua_common.LuaFunction {
	name = "add_tag",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "add_tag") do return 0
		if !lua_common.validate_table_or_string(L, 1, "add_tag") do return 0
		if !lua_common.validate_string(L, 2, "add_tag") do return 0

		entity_id := lua_common.get_entity_id(L, 1)
		defer delete(entity_id)
		tag := strings.clone_from_cstring(lua.tostring(L, 2))
		defer delete(tag)
		entity := core.find_by_id(entity_id)

		if entity == nil {
			lua.pushboolean(L, false)
		} else {
			core.add_tag(entity_id, tag)
			lua.pushboolean(L, true)
		}

		return 1
	},
}
