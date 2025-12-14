package audio

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"

PLAY_FUNCTION :: lua_common.LuaFunction {
	name = "play",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "play expects at least 1 argument (table)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a table")
			lua.error(L)
			return 0
		}

		audio_path := lua_common.get_table_string(L, 1, "sound", "")
		volume := f32(lua_common.get_table_number(L, 1, "volume", 1.0))
		pitch := f32(lua_common.get_table_number(L, 1, "pitch", 1.0))
		group := lua_common.get_table_string(L, 1, "group", "default")
		loop := lua_common.get_table_boolean(L, 1, "loop", false)

		if audio_path == "" {
			lua.pushstring(L, "Sound cannot be empty")
			lua.error(L)
			return 0
		}

		audio_id, ok := core.load_sound(audio_path, group)

		if ok {
			core.play_sound(audio_id, volume, pitch, b32(loop))
		}

		lua.pushnumber(L, lua.Number(audio_id))

		return 1
	},
}
