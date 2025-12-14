package file_system

import "../../fs"
import "core:strings"

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

READ_DIR_FUNCTION :: lua_common.LuaFunction {
	name = "read_dir",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "read_dir expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		dir_path := string(lua.tostring(L, 1))

		content, ok := fs.read_dir(dir_path)

		if ok {
			lua.newtable(L)
			for entry, i in content {
				cstring_entry := strings.clone_to_cstring(entry)
				defer delete(cstring_entry)
				lua.pushinteger(L, lua.Integer(i + 1))
				lua.pushstring(L, cstring_entry)
				lua.settable(L, -3)
			}
		} else {
			lua.pushnil(L)
		}

		return 1
	},
}
