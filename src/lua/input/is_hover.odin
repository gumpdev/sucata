package input

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

IS_HOVER_FUNCTION :: lua_common.LuaFunction {
	name = "is_hover",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count < 2 {
			lua.pushstring(L, "is_hover expects at least 2 argument (entity, table)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) && !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 2) {
			lua.pushstring(L, "Second argument must be a table")
			lua.error(L)
			return 0
		}

		id := lua_common.get_entity_id(L, 1)
		defer delete(id)
		x := lua_common.get_table_number(L, 2, "x", 0)
		y := lua_common.get_table_number(L, 2, "y", 0)
		width := lua_common.get_table_number(L, 2, "width", 0)
		height := lua_common.get_table_number(L, 2, "height", 0)
		fixed := lua_common.get_table_boolean(L, 2, "fixed", false)
		z_index := lua_common.get_table_number(L, 2, "z_index", 0)

		core.add_hoverable(id, f32(x), f32(y), f32(width), f32(height), i32(z_index), fixed)

		lua.pushboolean(L, id == core.hover)
		return 1
	},
}
