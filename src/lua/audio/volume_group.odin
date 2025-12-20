package audio

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"

GET_GROUP_VOLUME_FUNCTION :: lua_common.LuaFunction {
	name = "get_group_volume",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "get_group_volume expects at least 1 argument (string)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		group_id := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(group_id)

		lua.pushnumber(L, lua.Number(core.get_group_volume(group_id)))

		return 1
	},
}

SET_GROUP_VOLUME_FUNCTION :: lua_common.LuaFunction {
	name = "set_group_volume",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "set_group_volume expects at least 2 argument (string, number)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		if !lua.isnumber(L, 2) {
			lua.pushstring(L, "Both argument must be a number")
			lua.error(L)
			return 0
		}

		group_id := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(group_id)
		volume := lua.tonumber(L, 2)

		core.set_group_volume(group_id, f32(volume))

		return 0
	},
}
