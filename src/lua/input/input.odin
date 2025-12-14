package input

import lua_common "../lua_common"

INPUT_NAMESPACE :: lua_common.LuaNamespace {
	name      = "input",
	functions = []lua_common.LuaFunction {
		GET_MOUSE_POSITION_FUNCTION,
		GET_MOUSE_SCROLL_FUNCTION,
		GET_KEY_FUNCTION,
		IS_PRESSED_FUNCTION,
		IS_HELD_FUNCTION,
		IS_HOVER_FUNCTION,
		IS_RELEASED_FUNCTION,
	},
}
