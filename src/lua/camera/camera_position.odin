package cam

import camera "../../camera"
import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

GET_CAMERA_POSITION_FUNCTION :: lua_common.LuaFunction {
	name = "get_camera_position",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushnumber(L, lua.Number(camera.camera.position.x))
		lua.pushnumber(L, lua.Number(camera.camera.position.y))

		return 2
	},
}

SET_CAMERA_POSITION_FUNCTION :: lua_common.LuaFunction {
	name = "set_camera_position",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count < 2 {
			lua.pushstring(L, "set_camera_position expects 2 arguments (x, y)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) {
			lua.pushstring(L, "Both arguments must be numbers")
			lua.error(L)
			return 0
		}

		x := f32(lua.tonumber(L, 1))
		y := f32(lua.tonumber(L, 2))
		camera.set_camera_position(x, y)

		return 0
	},
}
