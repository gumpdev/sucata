package timenamespace

import lua_common "../lua_common"

TIME_NAMESPACE :: lua_common.LuaNamespace {
	name      = "time",
	functions = []lua_common.LuaFunction {
		GET_TIME_FUNCTION,
		FPS_FUNCTION,
		CREATE_TIMER_FUNCTION,
		PAUSE_TIMER_FUNCTION,
		STOP_TIMER_FUNCTION,
		SET_TIME_SCALE_FUNCTION,
		GET_TIME_SCALE_FUNCTION,
	},
}
