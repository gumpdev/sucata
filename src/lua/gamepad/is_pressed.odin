package gamepad

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

IS_PRESSED_FUNCTION :: lua_common.LuaFunction {
	name = "is_pressed",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "is_pressed") do return 0
		if !lua_common.validate_string(L, 1, "is_pressed") do return 0

		button := string(lua.tostring(L, 1))

		slot := -1
		if lua.gettop(L) > 1 {
			if !lua_common.validate_number(L, 2, "is_pressed") do return 0
			slot = int(lua.tonumber(L, 2))
		}

		value, value_slot := core.gamepad_button_pressed(button, slot)

		lua.pushboolean(L, b32(value))
		lua.pushnumber(L, lua.Number(value_slot))

		return 2
	},
}
