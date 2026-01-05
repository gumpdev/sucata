package cam

import camera "../../camera"
import core "../../core"
import lua_common "../lua_common"
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

		if !lua_common.validate_arg_count(L, 1, "set_camera_rotation") do return 0
		if !lua_common.validate_number(L, 1, "set_camera_rotation") do return 0

		rotation := f32(lua.tonumber(L, 1))
		camera.set_camera_rotation(rotation)

		return 0
	},
}
