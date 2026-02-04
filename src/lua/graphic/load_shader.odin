package graphic

import core "../../core"
import lua_common "../lua_common"
import "core:c"
import "core:crypto"
import "core:encoding/uuid"
import "core:strings"
import lua "vendor:lua/5.4"

LOAD_SHADER_FUNCTION :: lua_common.LuaFunction {
	name = "load_shader",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if !lua_common.validate_arg_count(L, 1, "load_shader") do return 0
		if !lua_common.validate_string(L, 1, "load_shader") do return 0

		shader_file := strings.clone_from_cstring(lua.tostring(L, 1))

		shader_name: string
		if lua.gettop(L) >= 2 {
			shader_name = strings.clone_from_cstring(lua.tostring(L, 2))
		} else {
			context.random_generator = crypto.random_generator()
			shader_name = uuid.to_string(uuid.generate_v4())
		}

		core.add_post_command(
			core.PostLoadShader{shader_name = shader_name, shader_path = shader_file},
		)

		shader_name_uuid := strings.clone_to_cstring(shader_name)
		defer delete(shader_name_uuid)
		lua.pushstring(L, shader_name_uuid)

		return 1
	},
}
