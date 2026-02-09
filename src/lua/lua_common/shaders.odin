package lua_common

import "../../common"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

get_shader_args :: proc(L: ^lua.State, table_index: c.int) -> common.ShaderArgs {
	lua.getfield(L, table_index, "shader_args")

	if lua.type(L, -1) != lua.Type.TABLE {
		lua.pop(L, 1)
		return common.ShaderArgs{}
	}

	shader_args := common.ShaderArgs{}

	lua.pushnil(L)
	for lua.next(L, -2) != 0 {
		key_type := lua.type(L, -2)
		if key_type != lua.Type.STRING {
			lua.pop(L, 1)
			continue
		}
		key := strings.clone_from_cstring(lua.tostring(L, -2))

		value_type := lua.type(L, -1)
		#partial switch value_type {
		case .NUMBER:
			shader_args[key] = f32(lua.tonumber(L, -1))
		case .STRING:
			shader_args[key] = strings.clone_from_cstring(lua.tostring(L, -1))
		case .TABLE:
			count := 0
			result := [4]f32{}

			lua.pushnil(L)
			for lua.next(L, -2) != 0 {
				value_type := lua.type(L, -1)
				if value_type == lua.Type.NUMBER && count < 4 {
					result[count] = f32(lua.tonumber(L, -1))
					count += 1
				}
				lua.pop(L, 1)
			}

			if count == 2 {
				shader_args[key] = [2]f32{result[0], result[1]}
			} else if count == 3 {
				shader_args[key] = [3]f32{result[0], result[1], result[2]}
			} else if count == 4 {
				shader_args[key] = [4]f32{result[0], result[1], result[2], result[3]}
			}
		}

		lua.pop(L, 1)
	}

	lua.pop(L, 1)
	return shader_args
}
