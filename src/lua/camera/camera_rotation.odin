package cam

import camera "../../camera"
import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

GET_CAMERA_ROTATION_FUNCTION :: lua_common.LuaFunction {
	name = "get_camera_rotation",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		lua.pushnumber(L, lua.Number(camera.camera.rotation))

		return 1
	},
}

SET_CAMERA_ROTATION_FUNCTION :: lua_common.LuaFunction {
	name = "set_camera_rotation",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		arg_count := lua.gettop(L)
		if arg_count < 1 {
			lua.pushstring(L, "set_camera_rotation expects 1 argument (rotation)")
			lua.error(L)
			return 0
		}
		if !lua.isnumber(L, 1) {
			lua.pushstring(L, "Argument must be a number")
			lua.error(L)
			return 0
		}

		rotation := f32(lua.tonumber(L, 1))
		camera.set_camera_rotation(rotation)

		return 0
	},
}
