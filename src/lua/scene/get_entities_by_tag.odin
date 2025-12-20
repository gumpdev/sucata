package scene

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

GET_ENTITIES_BY_TAG_FUNCTION :: lua_common.LuaFunction {
	name = "get_entities_by_tag",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "get_entities expects 1 argument (string or table)")
			lua.error(L)
			return 0
		}

		if !lua.isstring(L, 1) {
			lua.pushstring(L, "First argument must be a string")
			lua.error(L)
			return 0
		}

		tag := strings.clone_from_cstring(lua.tostring(L, 1))
		defer delete(tag)

		entitys := core.get_entities(tag)

		lua.newtable(L)

		if entitys != nil {
			for i := 0; i < len(entitys); i += 1 {
				id := strings.clone_to_cstring(entitys[i])
				defer delete(id)
				lua.pushinteger(L, lua.Integer(i + 1))
				lua.pushstring(L, id)
				lua.settable(L, -3)
			}
		}

		return 1
	},
}
