package mathns

import lua_common "../lua_common"

MATH_NAMESPACE :: lua_common.LuaNamespace {
	name      = "math",
	functions = []lua_common.LuaFunction {
		CLAMP_FUNCTION,
		DISTANCE_FUNCTION,
		LERP_FUNCTION,
		OVERLAPPING_FUNCTION,
		SCREEN_RELATIVE_FUNCTION,
		SMOOTH_INDEX_FUNCTION,
	},
}
