package audio

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"

GET_PITCH_FUNCTION :: lua_common.LuaFunction {
	name = "get_pitch",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "get_pitch") do return 0
		if !lua_common.validate_number(L, 1, "get_pitch") do return 0

		sound_id := lua.tonumber(L, 1)

		lua.pushnumber(L, lua.Number(core.get_sound_pitch(u32(sound_id))))

		return 1
	},
}

SET_PITCH_FUNCTION :: lua_common.LuaFunction {
	name = "set_pitch",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 2, "set_pitch") do return 0
		if !lua_common.validate_number(L, 1, "set_pitch") do return 0
		if !lua_common.validate_number(L, 2, "set_pitch") do return 0

		sound_id := lua.tonumber(L, 1)
		pitch := lua.tonumber(L, 2)

		core.set_sound_pitch(u32(sound_id), f32(pitch))

		return 0
	},
}
