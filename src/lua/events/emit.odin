package events

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

EMIT_FUNCTION :: lua_common.LuaFunction {
	name = "emit",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "emit") do return 0
		if !lua_common.validate_string(L, 1, "emit") do return 0
		if !lua_common.validate_table(L, 2, "emit") do return 0

		event := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(event)
		data_ref := lua.L_ref(L, lua.REGISTRYINDEX)

		core.emit_event(event, data_ref)
		defer lua.L_unref(L, lua.REGISTRYINDEX, data_ref)

		return 0
	},
}
