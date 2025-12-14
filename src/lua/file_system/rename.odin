package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

RENAME_FUNCTION :: lua_common.LuaFunction {
	name = "rename",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "rename expects at least 2 arguments (string, string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}
		if !lua.isstring(L, 2) {
			lua.pushstring(L, "Second argument must be a string")
			lua.error(L)
			return 0
		}

		old_path := string(lua.tostring(L, 1))
		new_path := string(lua.tostring(L, 2))

		fs.rename(old_path, new_path)

		return 0
	},
}
