package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

EXISTS_FUNCTION :: lua_common.LuaFunction {
	name = "exists",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "exists") do return 0
		if !lua_common.validate_string(L, 1, "exists") do return 0

		fpath := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(fpath)

		exists := fs.exists(fpath)
		lua.pushboolean(L, b32(exists))

		return 1
	},
}
