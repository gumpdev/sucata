package gamepad

import lua_common "../lua_common"

GAMEPAD_NAMESPACE :: lua_common.LuaNamespace {
	name      = "gamepad",
	functions = []lua_common.LuaFunction {
		GET_COUNT_FUNCTION,
		IS_PRESSED_FUNCTION,
		IS_HELD_FUNCTION,
		IS_RELEASED_FUNCTION,
		GET_AXIS_FUNCTION,
	},
}
