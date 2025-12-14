package file_system

import "../../fs"
import "core:strings"

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

READ_FILE_FUNCTION :: lua_common.LuaFunction {
	name = "read_file",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "read_file expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		file_path := string(lua.tostring(L, 1))

		content, ok := fs.read_file_as_string(file_path)

		if ok {
			cstring_content := strings.clone_to_cstring(content)
			defer delete(cstring_content)
			lua.pushstring(L, cstring_content)
		} else {
			lua.pushnil(L)
		}

		return 1
	},
}
