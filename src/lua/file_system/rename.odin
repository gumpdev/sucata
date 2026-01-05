package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

RENAME_FUNCTION :: lua_common.LuaFunction {
	name = "rename",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "rename") do return 0
		if !lua_common.validate_string(L, 1, "rename") do return 0
		if !lua_common.validate_string(L, 2, "rename") do return 0

		old_path := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(old_path)
		new_path := strings.clone_from_cstring(lua.tostring(L, 2))
		defer delete(new_path)

		fs.rename(old_path, new_path)

		return 0
	},
}
