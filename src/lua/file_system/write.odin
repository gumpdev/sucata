package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

WRITE_FUNCTION :: lua_common.LuaFunction {
	name = "write",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "write expects at least 2 arguments (string, string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) || !lua.isstring(L, 2) {
			lua.pushstring(L, "Both arguments must be strings")
			lua.error(L)
			return 0
		}

		file_path := string(lua.tostring(L, 1))
		content := string(lua.tostring(L, 2))

		ok := fs.write_file(file_path, transmute([]u8)content)
		lua.pushboolean(L, b32(ok))

		return 1
	},
}
