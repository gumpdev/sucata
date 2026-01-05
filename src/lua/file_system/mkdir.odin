package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

MKDIR_FUNCTION :: lua_common.LuaFunction {
	name = "mkdir",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "mkdir") do return 0
		if !lua_common.validate_string(L, 1, "mkdir") do return 0

		dir_path := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(dir_path)
		fs.mkdir(dir_path)

		return 0
	},
}
