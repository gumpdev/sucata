package graphic

import lua_common "../lua_common"

GRAPHIC_NAMESPACE :: lua_common.LuaNamespace {
	name      = "graphic",
	functions = []lua_common.LuaFunction{RECT_FUNCTION, TEXT_FUNCTION, SET_BACKGROUND_FUNCTION},
}
