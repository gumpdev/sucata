package window

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

QUIT_FUNCTION :: lua_common.LuaFunction {
	name = "quit",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		core.quit()

		return 0
	},
}
