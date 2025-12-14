package timenamespace

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

FPS_FUNCTION :: lua_common.LuaFunction {
	name = "get_fps",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushnumber(L, lua.Number(core.fps))

		return 1
	},
}
