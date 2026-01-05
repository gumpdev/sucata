package file_system

import core "../../core"
import "../../fs"
import lua_common "../lua_common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

WRITE_FUNCTION :: lua_common.LuaFunction {
	name = "write",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "write") do return 0
		if !lua_common.validate_string(L, 1, "write") do return 0
		if !lua_common.validate_string(L, 2, "write") do return 0

		file_path := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(file_path)
		content := strings.clone_from_cstring(lua.tostring(L, 2))
		defer delete(content)

		ok := fs.write_file(file_path, transmute([]u8)content)
		lua.pushboolean(L, b32(ok))

		return 1
	},
}
