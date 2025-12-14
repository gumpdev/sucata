package cam

import camera "../../camera"
import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"

CAMERA_NAMESPACE :: lua_common.LuaNamespace {
	name      = "camera",
	functions = []lua_common.LuaFunction {
		GET_CAMERA_POSITION_FUNCTION,
		SET_CAMERA_POSITION_FUNCTION,
		GET_CAMERA_ROTATION_FUNCTION,
		SET_CAMERA_ROTATION_FUNCTION,
		GET_CAMERA_ZOOM_FUNCTION,
		SET_CAMERA_ZOOM_FUNCTION,
	},
}
