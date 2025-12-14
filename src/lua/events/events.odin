package events

import lua_common "../lua_common"

EVENTS_NAMESPACE :: lua_common.LuaNamespace {
	name      = "events",
	functions = []lua_common.LuaFunction{ON_FUNCTION, EMIT_FUNCTION},
}
