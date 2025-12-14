package audio

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"

UNPAUSE_FUNCTION :: lua_common.LuaFunction {
	name = "pause",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "unpause expects at least 1 argument (number)")
			lua.error(L)
			return 0
		}

		if !lua.isnumber(L, 1) {
			lua.pushstring(L, "First argument must be a number")
			lua.error(L)
			return 0
		}

		sound_id := lua.tonumber(L, 1)

		core.unpause_sound(u32(sound_id))

		return 0
	},
}
