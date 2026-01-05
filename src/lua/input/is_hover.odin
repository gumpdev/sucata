package input

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

IS_HOVER_FUNCTION :: lua_common.LuaFunction {
	name = "is_hover",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "is_hover") do return 0
		if !lua_common.validate_table_or_string(L, 1, "is_hover") do return 0
		if !lua_common.validate_table(L, 2, "is_hover") do return 0

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
