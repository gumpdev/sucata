package audio

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"

GET_VOLUME_FUNCTION :: lua_common.LuaFunction {
	name = "get_volume",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "get_volume expects at least 1 argument (number)")
			lua.error(L)
			return 0
		}

		if !lua.isnumber(L, 1) {
			lua.pushstring(L, "First argument must be a number")
			lua.error(L)
			return 0
		}

		sound_id := lua.tonumber(L, 1)

		lua.pushnumber(L, lua.Number(core.get_sound_volume(u32(sound_id))))

		return 1
	},
}

SET_VOLUME_FUNCTION :: lua_common.LuaFunction {
	name = "set_volume",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 2 {
			lua.pushstring(L, "set_volume expects at least 2 argument (number, number)")
			lua.error(L)
			return 0
		}

		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) {
			lua.pushstring(L, "Both argument must be a number")
			lua.error(L)
			return 0
		}

		sound_id := lua.tonumber(L, 1)
		volume := lua.tonumber(L, 2)

		core.set_sound_volume(u32(sound_id), f32(volume))

		return 0
	},
}
