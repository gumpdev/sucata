package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

MKDIR_FUNCTION :: lua_common.LuaFunction {
	name = "mkdir",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "mkdir expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		dir_path := string(lua.tostring(L, 1))
		fs.mkdir(dir_path)

		return 0
	},
}
