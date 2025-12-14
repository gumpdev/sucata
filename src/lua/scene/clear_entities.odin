package scene

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

CLEAR_ENTITIES_FUNCTION :: lua_common.LuaFunction {
	name = "clear_entities",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		core.clear_scene()

		return 0
	},
}
